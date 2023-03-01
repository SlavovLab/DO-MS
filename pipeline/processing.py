#!/usr/bin/env python3

import argparse
import os
import pathlib
import shutil
import subprocess
import pandas as pd
from datetime import datetime
import pymzml
import numpy as np
from typing import List, Any

from pathlib import Path
from tqdm import tqdm

import multiprocessing

def generate_parser():
        
    # instantiate the parser
    parser = argparse.ArgumentParser(description=('Command line tool for feature detection in shotgun MS experiments. Can be used together '
    'with DIA-NN to provide additional information on the peptide like features identified in the MS1 spectra.'))
    
    # Required command line arguments
    parser.add_argument('report', type=pathlib.Path, default=os.getcwd(), help="Location of the report.tsv output from DIA-NN which should be used for analysis.")
    
    parser.add_argument("--raw-parser-location", type=pathlib.Path, required=True, help="Path pointing to the ThermoRawFileParser executeable.")
    
    # optional command line arguments
    parser.add_argument("--dinosaur-location", help="Path pointing to the dinosaur jar executeable.")

    parser.add_argument("-m","--mono", default=False, action='store_true',  help="Use mono for ThermoRawFileParser under Linux and OSX.")

    parser.add_argument("-d","--delete", default=False, action='store_true',  help="Delete generated mzML and copied raw files after successfull feature generation.")
    
    parser.add_argument("-v","--verbose", default=False, action='store_true',  help="Show verbose output.")
    
    parser.add_argument("-t","--temporary-folder", type=pathlib.Path, help="Input Raw files will be temporarilly copied to this folder. Required for use with Google drive.")

    parser.add_argument("-r","--raw-file-location", type=pathlib.Path, help="By default, raw files are loaded based on the File.Name column in the report.tsv. With this option, a different folder can be specified.")

    parser.add_argument("--no-feature-detection", default=False, action='store_true', help="All steps are performed as usual but Dinosaur feature detection is skipped. No features.tsv file will be generated.")

    parser.add_argument("--no-fill-times", default=False, action='store_true', help="All steps are performed as usual but fill times are not extracted. No fill_times.tsv file will be generated.")

    parser.add_argument("--no-tic", default=False, action='store_true', help="All steps are performed as usual but binned TIC is not extracted. No tic.tsv file will be generated.")

    parser.add_argument("--no-sn", default=False, action='store_true', help=('Signal to Noise ratio is not estimated for precursors'))

    parser.add_argument("--no-mzml-generation", default=False, action='store_true', help=('Raw files are not converted to .mzML. '
    'Nevertheless, mzML files are expected in their theoretical output location and loaded. Should be only be carefully used for repeated calulcations or debugging'))       

    parser.add_argument("--mz-bin-size", default=10.0,  type=float, help="Bin size over the mz dimension for TIC binning.")

    parser.add_argument("--rt-bin-size", default=1,  type=float, help="Bin size over the RT dimension for TIC binning in minutes. If a bin size of 0 is provided, binning will not be applied and TIC is given per scan.")

    parser.add_argument("--resolution", default=70000, help="Set the resolution used for estimating counts from S/N data")

    parser.add_argument("-p", "--processes", default=10, help="Number of Processes")

    parser.add_argument("--isotopes-sn", default=False, action='store_true', help="Use all isototopes from the same scan as the highest intensity datapoint for estimating the SN and copy number.")

    return parser

class MatchReport:
    # labels as found in the Precursor.Id
    def __init__(self, 
                mzml_list: List, 
                report: str, 
                scan_window = 5, 
                mass_error = 15,
                isotope_start = 0,
                isotope_stop = 3,
                add_isotopes = False,
                keep_all = False,
                resolution = 70000): 
        """
        The class can be used to match a DIA-NN report to an centroided or profile mode mzml file.
        After matching peaks to a certain region, features and data can be extracted.

        Processing order and steps for customization:

        1. The report dataframe is loaded and filtered based on the filter_report(report) function.

        2. The report dataframe is split into sub dataframes which are generated based on the Run column.

        3. Precursors are then matched to the mzml file based on the retation time. 
        For every precursors a list of potential hits is created based on the defined scan window, mass error and isotopes.
        For every hit the function build_scan_features(self, scan, scan_id, mz_id, precursor_id, j, mz) is called.

        4. The top hit is selected based on the intensity field in the feature dict. 
        If add_isotopes is set, all hits for different isotopes from the same scan as the top hit are passed to join_top_scans(self, feature_list) to combine the features.

        Args:
            mzml_list (list(str)): List of mzml input files. The file name has to match the Run column in the DIA-NN report.

            report (str): Location of the DIA-NN report.

            mass_error (float): Mass error in parts per million

            scan_window (int): Number of windows adjecent to the closest retention time.

            keep_all (bool): Keep all hits in the selected window.
        """ 

        self.mzml_list = mzml_list
        self.report = report

        # processing parameters
        self.scan_window = scan_window
        self.mass_error = mass_error
        self.isotope_start = isotope_start
        self.isotope_stop = isotope_stop
        self.add_isotopes = add_isotopes
        self.resolution = resolution
        self.keep_all = keep_all

    def __call__(self, *args: Any, **kwds: Any) -> Any:

        # get report.tsv
        report = pd.read_csv(self.report, sep='\t')
        report = self.filter_report(report)
        
        dfs = []
        for input_mzml in self.mzml_list:
            name = Path(input_mzml).stem

            # create subframe for the specific mzml
            subframe = report[report['Run'] == name]

            # load mzml file
            dfs.append(self.match_mzml(input_mzml, subframe))
        return pd.concat(dfs)

    def filter_report(self, report_df):
        """
        Apply filtering on the whole report, for example Ms1.Area
        """

        return report_df[report_df['Ms1.Area'] > 0]

    def build_scan_features(self, scan, scan_id, scan_window_center, mz_id, j, report_row):
        report_row = report_row.copy()

        noise = scan['noise'][mz_id]
        intensity = scan['spectrum_intensity'][mz_id]
        sn = intensity/noise
        copy_number = sn * 3.5 * np.sqrt(240000/self.resolution) / report_row['Precursor.Charge']

        report_row.update({
                'Scan.Id':scan_id,
                'Isotope': j,
                'Intensity': intensity,
                'Noise': noise,
                'Baseline': scan['baseline'][mz_id],
                'mz': scan['spectrum_mz'][mz_id],
                'Mass.Error': scan['delta_mz'][mz_id],
                'sn': sn,
                'Copy.Number': copy_number
                })

        return report_row

    def join_top_scans(self, feature_list):

        return {'Datapoints': feature_list[0]['Datapoints'],
                'Precursor.Id': feature_list[0]['Precursor.Id'],
                'Scan.Id':feature_list[0]['Scan.Id'],
                'Num.Isotopes': len(feature_list),
                'Intensity': np.mean([feature['Intensity'] for feature in feature_list]),
                'Noise': np.mean([feature['Noise'] for feature in feature_list]),
                'Baseline': np.mean([feature['Baseline'] for feature in feature_list]),
                'Mass.Error': np.mean([feature['Mass.Error'] for feature in feature_list]),
                'sn': np.mean([feature['sn'] for feature in feature_list]),
                'Copy.Number': np.sum([feature['Copy.Number'] for feature in feature_list])
                }

    def match_mzml(self, mzml, subframe):
        name = Path(mzml).stem
        run = pymzml.run.Reader(mzml)
        
        # generate RT index for MS1's
        indexed_ms1 = []

        print('Indexing Ms1 spectra')

        indexed_ms1 = []

        # initiate statistics
        statistics = {'precursors' : 0, 'identified': 0, 'failed': 0}

        # iterate all ms1 scans and extract retention times
        for i, spectrum in tqdm(enumerate(run)):
            ms_level = spectrum.ms_level

            if ms_level == 1:

                # Collect data from mzml
                row_dict = {'index': i,
                            'retention_time': spectrum['MS:1000016'],
                            'fill_time': spectrum['MS:1000927'],
                            'tic': spectrum['MS:1000285']}

                # collect different types of spectra
                try:
                    baseline_parameters = spectrum._get_encoding_parameters('sampled noise baseline array')
                    baseline = spectrum._decode(*baseline_parameters)
                    row_dict['baseline'] = np.array(baseline)

                    noise_parameters = spectrum._get_encoding_parameters('sampled noise intensity array')
                    noise = spectrum._decode(*noise_parameters)
                    row_dict['noise'] = np.array(noise)

                    mz_parameters = spectrum._get_encoding_parameters('sampled noise m/z array')
                    mz = spectrum._decode(*mz_parameters)
                    row_dict['mz'] = np.array(mz)
                except Exception as e:
                    print (e)

                    raise ValueError(f'Noise and baseline data could not be extracted from {name}. Please make sure the mzML files contains this data. Aborting')

                intensity_parameters = spectrum._get_encoding_parameters('intensity array')
                intensity = spectrum._decode(*intensity_parameters)
                row_dict['spectrum_intensity'] = np.array(intensity)

                rmz_parameters = spectrum._get_encoding_parameters('m/z array')
                rmz = spectrum._decode(*rmz_parameters)
                row_dict['spectrum_mz'] = np.array(rmz)

                indexed_ms1.append(row_dict)

        # create rt indexing for matching mzml
        rt_index = np.array([scan['retention_time'] for scan in indexed_ms1])
        
        out_df = []

        for i, row_dict in tqdm(zip(range(len(subframe)), subframe.to_dict(orient="records"))):
            delta_rt = np.abs(rt_index - row_dict['RT'])
            ms_idx = np.argmin(delta_rt)

            # define lower and upper indices
            ms_idx_lower = ms_idx - self.scan_window if (ms_idx - self.scan_window) >= 0 else 0
            ms_idx_upper = ms_idx + self.scan_window + 1 if (ms_idx + self.scan_window +1) < len(rt_index) else len(rt_index)-1

            sn_arr = []

            # Match scan and mz
            for scan_idx in range(ms_idx_lower, ms_idx_upper):
                scan = indexed_ms1[scan_idx]

                for j in range(self.isotope_start, self.isotope_stop):
                    isotope_mz = row_dict['Precursor.Mz'] + j/row_dict['Precursor.Charge']

                    scan['delta_mz'] = np.abs(scan['spectrum_mz'] - isotope_mz)/isotope_mz*1e6
                    mz_idx = np.flatnonzero(scan['delta_mz'] < self.mass_error)

                    for id in mz_idx:
                        sn_arr.append(self.build_scan_features(scan, scan_idx, ms_idx, id, j, row_dict))

            

            # Pick top hit
            statistics['precursors'] += 1
            if len(sn_arr) > 0:

                #print([el['intensity'] for el in sn_arr])
                intensity_arr = np.array([el['Intensity'] for el in sn_arr])
                hit_idx = np.argmax(intensity_arr)

                top_scan = sn_arr[hit_idx]

                for el in sn_arr:
                    el['Run'] = name
                    el['Datapoints'] = len(sn_arr)

                if self.keep_all:
                    out_df += sn_arr
                else:
                    if self.add_isotopes:
                        top_scan_id = top_scan['scan_id']
                        top_scans = [features for features in sn_arr if features['Scan.Id'] == top_scan_id]
                        top_scan = self.join_top_scans(top_scans)

                    
                    out_df.append(top_scan)

                statistics['identified'] += 1
            else:
                statistics['failed'] += 1
        
        # Calculate statistics on success of matching
        successrate = statistics['identified'] / statistics['precursors']*100
        print(f"{name} identified: {successrate:.2f}%")

        return pd.DataFrame(out_df)
def _validate_path(file_path, description):
    if not os.path.isfile(file_path): 
        raise ValueError(f'{description} \n {file_path} does not exist.')

def validate_path(list_or_str, description):
    if isinstance(list_or_str,str):
        _validate_path(list_or_str, description)

    if isinstance(list_or_str,List):
        for elem in list_or_str:
          _validate_path(elem, description)  

    else:
        raise TypeError('Provide a string or list of strings')

def _validate_filetype(file_path, description):
    filename, file_extension = os.path.splitext(file_path)
    if file_extension.lower() not in ['.raw','.mzml']:
        raise ValueError(f'{description} \n {file_extension} not supported.')

def validate_filetype(list_or_str, description):
    if isinstance(list_or_str,str):
        _validate_filetype(list_or_str, description)

    if isinstance(list_or_str,List):
        for elem in list_or_str:
          _validate_filetype(elem, description)  

    else:
        raise TypeError('Provide a string or list of strings')

class FeatureDetection():

    def __init__(self):
        pass

    def get_timestamp(self):
        # datetime object containing current date and time
        now = datetime.now()

        dt_string = now.strftime("%d/%m/%Y %H:%M:%S")  
        return "[" + dt_string + "] "

    def log(self, msg):
        print(self.get_timestamp() + msg)   

    def __call__(self):

        parser = generate_parser()
        self.args = parser.parse_args()       

        self.output_folder = pathlib.Path(self.args.report).parent.resolve()
        self.report_tsv = pd.read_csv(self.args.report, sep='\t')
        self.experiment_files = list(set(self.report_tsv['File.Name']))

        # Contains a list of the raw files in the report
        # will be converted to unix style pathlib objects
        self.experiment_files = [file.replace('\\','/') for file in self.experiment_files]
        self.experiment_files = [pathlib.Path(file) for file in self.experiment_files]

        # Source raw files from alternative folder
        if self.args.raw_file_location is not None:
            self.log('Raw files will be sourced from the specified folder')

            if not os.path.isdir(self.args.raw_file_location): 
                raise ValueError(f'{self.args.raw_file_location} does not exist.')

            for i, file_path in enumerate(self.experiment_files):
                file = os.path.basename(file_path)
                self.experiment_files[i] = os.path.join(self.args.raw_file_location, file)

        # Raw file strings are then valaidated
        self.log('Checking raw file locations')

        if not self.args.no_mzml_generation:
            validate_path(self.experiment_files, 'DO-MS DIA feature extraction relies on the raw file locations found in the File.Name column in the report.tsv.')
            validate_filetype(self.experiment_files, 'DO-MS DIA feature extraction relies on the raw file locations found in the File.Name column in the report.tsv.')

        self.experiment_names = [Path(path).stem for path in self.experiment_files]

        self.log('The following experiments were found:')
        for exp in self.experiment_names:
            self.log(exp)

        self.mzml_files = [os.path.join(self.output_folder,'.'.join([name,'mzML'])) for name in self.experiment_names]
        self.mzml_profile_files = [os.path.join(self.output_folder,'.'.join([name,'profile','mzML'])) for name in self.experiment_names]
        
        if self.args.temporary_folder is not None:
            #temporary folder is defined, copy files to temporary folder and change input path
            
            for i, experiment in enumerate(self.experiment_files):
        
                input_raw = experiment
                output_raw = os.path.join(self.args.temporary_folder, experiment.name)
                shutil.copy(input_raw, output_raw)
                self.log(f"{experiment.name} copied to {self.args.temporary_folder}")
                
                self.experiment_files[i] = output_raw
        
        # Check if --no-mzml-generation has been set
        if not self.args.no_mzml_generation:
            try:
                self.mzml_generation()
            except Exception as e: 
                self.log('mzml generation failed:')
                print(e)

        # Check if --no-fill-times has been set
        if not self.args.no_fill_times:
            try:
                self.fill_times()
            except Exception as e: 
                self.log('Fill time extraction failed:')
                print(e)

        # Check if --no-tic has been set
        if not self.args.no_tic:
            try:
                self.tic()
            except Exception as e: 
                self.log('Fill time extraction failed:')
                print(e)

        # Check if --no-sn has been set
        if not self.args.no_sn:
            try:
                self.sn()   
            except Exception as e: 
                self.log('SN extraction failed:')
                print(e)        

        # Check if --no-feature-detection has been set
        if not self.args.no_feature_detection:
            try:
                self.feature_detection()
            except Exception as e: 
                self.log('Feature detection failed:')
                print(e) 
        
        # delete temporary files if specified
        if self.args.delete:
            for input_mzml in self.mzml_files:
                self.log('delete' + str(input_mzml))
                if os.path.isfile(input_mzml):
                    os.remove(input_mzml)

            for input_mzml in self.mzml_profile_files:
                self.log('delete' + str(input_mzml))
                if os.path.isfile(input_mzml):
                    os.remove(input_mzml)
                    
            if self.args.temporary_folder is not None:
                for experiment in self.experiment_files:
                    self.log(str(experiment))
                    if os.path.isfile(experiment):
                        os.remove(experiment)
    def sn(self):
        matcher = MatchReport(self.mzml_files, self.args.report, add_isotopes=self.args.isotopes_sn)
        df = matcher()
        df.to_csv(os.path.join(self.output_folder,'sn.tsv') ,sep='\t', index=False)


    def mzml_generation(self):
        """
        The function converts the provided Thermo raw files to the open mzML format.
        Output files with centroided and profile mode spectra are created ad specified in self.mzml_files and self.mzml_profile_files
        """

        labels = ["-N"]*len(self.experiment_files)+["-p"]*len(self.experiment_files)
        mzmls = self.mzml_files + self.mzml_profile_files
        raw = self.experiment_files + self.experiment_files
        
        queue = list(zip(raw, mzmls, labels))

        with multiprocessing.Pool(processes = self.args.processes) as pool:
            pool.map(self.mzml_job, queue)

    def mzml_job(self, args):

        input_raw, mzml, label = args

        if self.args.mono:
            process = subprocess.Popen(['mono',str(self.args.raw_parser_location),label,'-i',str(input_raw),'-b',str(mzml)],shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        else:
            process = subprocess.Popen(['ThermoRawFileParser',label,'-i',str(input_raw),'-b',str(mzml)], executable=str(self.args.raw_parser_location), stdout=subprocess.PIPE, stderr=subprocess.PIPE)         

        process.wait()
        out, err = process.communicate()

        self.log(out.decode())
        self.log(err.decode())

    def feature_detection(self):

        # Dinosaur output columns are defined to make reordering of the Run column easier
        # Needs to be updated if any new columns are added 
        columns = ['mz','mostAbundantMz','charge','rtStart','rtApex','rtEnd','fwhm','nIsotopes','nScans','averagineCorr','mass','massCalib','intensityApex','intensitySum']

        # check if --dinosaur-location has been provided and is valid file path.
        if (self.args.dinosaur_location == None) or (not os.path.isfile(self.args.dinosaur_location)):
            self.log(f"Dinosaur location not valid: {self.args.dinosaur_location}")
            return
        process_list = []

        #perform feature detection based on mzml file
        for input_mzml in self.mzml_profile_files:
            process_list.append(subprocess.Popen(['java',
                                        '-jar',
                                        str(self.args.dinosaur_location),
                                        '--concurrency=10',
                                        
                                        str(input_mzml)], stdout=subprocess.PIPE, stderr=subprocess.PIPE))

        for process in process_list:
            process.wait()
            out, err = process.communicate()

            self.log(out.decode())
            self.log(err.decode())
        
        
        # convert outputs to dataframes
        dfs = []
        for i, experiment_name in enumerate(self.experiment_names):
            feature_file = '.'.join([experiment_name,'profile','features','tsv'])
            input_feature = os.path.join(self.output_folder, feature_file)
            
            df = pd.read_csv(input_feature, sep='\t', header=0)
            
            # create new Run column for DO-MS compatability
            df['Run'] = experiment_name
            dfs.append(df)

        # concatenate outputs to a single dataset    
        df = pd.concat(dfs, ignore_index=True)
        # reorder columns
        df = df.reindex(columns=['Run']+columns)
        
        output_features = os.path.join(self.output_folder, "features.tsv")
        df.to_csv(output_features,index=False, header=True, sep='\t')
        
        
        # delete dinosaur qc folder 
        qc_path = os.path.join(os.getcwd(),'QC')
        if os.path.isdir(qc_path):
            shutil.rmtree(qc_path)

    def fill_times(self):
        # List which will be used to collect datapoints
        df_to_be = []

        
        for input_mzml, name in zip(self.mzml_files, self.experiment_names):
            self.log(f'Collecting fill times for {name}')

            run = pymzml.run.Reader(input_mzml)
            for spectrum in run:

                ms_level = spectrum.ms_level

                cv_params = spectrum.get_element_by_path(['scanList', 'scan', 'cvParam'])
                for el in cv_params:
                    key_val = el.attrib
                    
                    # parse 
                    if key_val['name'] == 'scan start time':
                        scan_start_time = key_val['value']

                    if key_val['name'] == 'ion injection time':
                        injection_time = key_val['value']
                
                window_center = 0
                window_lower_delta = 0
                window_upper_delta = 0

                if ms_level == 2:

                    try:
                        window_center = spectrum['MS:1000827']
                        window_lower_delta = spectrum['MS:1000828']
                        window_upper_delta = spectrum['MS:1000828']
                    except:
                        pass

                window_lower = window_center - window_lower_delta
                window_upper = window_center + window_upper_delta

                df_to_be.append([name, ms_level, window_lower, window_upper, scan_start_time, injection_time])

        fill_times_df = pd.DataFrame(df_to_be, columns =['Run', 'Ms.Level', 'Window.Lower','Window.Upper','RT.Start', 'Fill.Time'])
        output_fill_times = os.path.join(self.output_folder, "fill_times.tsv")
        fill_times_df.to_csv(output_fill_times,index=False, header=True, sep='\t')

    def tic(self):
        collect_dfs = []

        for input_mzml, name in zip(self.mzml_files, self.experiment_names):
            self.log(f'Collecting TIC for {name}')
            # get tic for single run
            result = self.tic_single(input_mzml, name)

            # only sparse mode returns df
            if isinstance(result, pd.DataFrame):
                collect_dfs.append(result)
        
        # concat TIC dfs from multiple runs and export them as tsv
        if len(collect_dfs) > 0:
            out_df = pd.concat(collect_dfs)
            output_tic = os.path.join(self.output_folder, "tic.tsv")
            out_df.to_csv(output_tic,index=False, header=True, sep='\t')

    def tic_single(self, input_mzml, name):
        run = pymzml.run.Reader(input_mzml)

        ms1_id = -1

        # tic values are collected spectrum wise in a sparse format
        # contains lists of [[ms1_id, current_bin, current_tic], ... ]
        spectra_batch = []

        # contains retention times
        rt_label = []

        for spectrum in run:
            ms_level = spectrum.ms_level
            if ms_level == 1:        
                ms1_id += 1

                scan_start_time = spectrum['MS:1000016']
                total_ion_current = spectrum['MS:1000285']

                rt_label.append(scan_start_time)

                data = np.array(spectrum.peaks("raw"))           
                intensity = data[:,1]
                mz = data[:,0]

                bins = self.calc_sparse_binned_tic(mz, intensity, total_ion_current, ms1_id)
                spectra_batch.append(bins) 

        # list is converted to array and sublists are concatenated
        sparse_arr = np.concatenate(spectra_batch)

        # sparse tic matrix is converted to dense tic matrix
        rt_col = sparse_arr[:,0].astype(int)
        mz_col = sparse_arr[:,1]
        tic = sparse_arr[:,2]
        
        rt_col = [rt_label[i] for i in rt_col]
        # check if sparse output has been selected
        # Easier to handle in ggplot2
        
        raw_file = [name] * len(tic)
        data = {'Raw.File': raw_file, 
        'RT': rt_col,
        'MZ': mz_col,
        'TIC': tic}

        df = pd.DataFrame.from_dict(data)

        if self.args.rt_bin_size > 0:
            df['RT'] = np.round(df['RT']/self.args.rt_bin_size)*self.args.rt_bin_size
            df = df.groupby(['Raw.File','RT','MZ'])['TIC'].sum().reset_index()

        return df
        

    def calc_sparse_binned_tic(self, mz, intensity, total_ion_current, ms1_id):
        # Resolution, integer, number of mz / bin
        # the integral of the provided spectra is approximated by using the rectangle rule
        # This allows efficient binning by rounding without iterative calculation of integrals
        mz_diff = np.diff(mz)
        mz_diff = np.pad(mz_diff, (0, 1), 'constant')
 
        # The true integral is calculated as the dot product
        integral = np.dot(mz_diff,intensity)

        # rescaled to resample TIC provided in meta information
        scaling_factor = total_ion_current / integral
        scaled_intensity = intensity * scaling_factor
        binned_intensity = scaled_intensity * mz_diff
        
        binned_mz = np.round(mz/self.args.mz_bin_size)
        binned_mz = binned_mz * self.args.mz_bin_size
        
        sparse_binned_tic = []

        current_bin = binned_mz[0]
        current_tic = 0
        
        for mz_bin, int_bin in zip(binned_mz, binned_intensity):
            if mz_bin == current_bin:
                current_tic += int_bin

            else:
                # close last bin, check if bin has tic
                if current_tic > 0:
                    sparse_binned_tic.append((ms1_id, current_bin, current_tic))

                # open new bin
                current_bin = mz_bin
                current_tic = int_bin
                
        return np.array(sparse_binned_tic)


if __name__ == "__main__":
    feature_detection = FeatureDetection()
    feature_detection()
