# Implementing Outputs from Other Search Engines

This app was designed for and tested for MaxQuant >= 1.6.0.16. Much of the code is designed around the specific outputs from MaxQuant, such as the column names of the text output files, and the names of the files themselves (```evidence```, ```allPeptides```, etc). In addition, the modules for this app are designed to take advantage of the features of MaxQuant outputs, such as the full-width at half-maximum of elution peaks outputted when selecting the "Calculate peak properties" option. 


Adapting the core module technology of this application to the output of other search engines can conceptually be carried out in two ways:

## Option 1: Convert output into MaxQuant-like files

If you like the current modules and would like to keep their current display and features, the quickest strategy is to convert your search engine's output into tab-delimited text that shares the same structure (i.e., column names) as MaxQuant's output.

Our application mainly uses six tab-delimited files from MaxQuant (for non-DIA searches): 

1. ```allPeptides```, which describes ions on the MS1 level
2. ```msmsScans```, which describes MS2 scans
3. ```msms```, which describes PSMs
4. ```evidence```, which describes peptide-level data
4. ```parameters```, which describes MaxQuant search parameters
4. ```summary```, which summarizes search results per experiment

If your search engine has the same general hierarchy of outputs, then the files and column names can be renamed to fit the general shape of the MaxQuant output. Otherwise, modules may need to be tweaked or removed for total compatibility.

## Option 2: Rewrite Modules

Very little of the static, server code is dependent on the MaxQuant names. The core dependencies are:

1. In ```server.R```, much of the design around selecting, filtering on, and renaming raw files are hard-coded to recognize the "Raw.file" column of MaxQuant output. Simply ensure that your search engine output is outputting the raw file name in each file (most should), and then change the specific "Raw.file" reference in the server code.
2. In ```global.R```, the four files as described in Option 1 above are hardcoded into a list that is then displayed on the import page and available to all of the modules. Simply change the definitions here to the files you want to load from your search engine. There is no limit here, and the only restriction is, as described in point 1, the presence of a raw file column in the text file.

All of the modules provided in the application here reference column names from MaxQuant output files and expect data in the form provided by MaxQuant. For other search engines, the column references may need to just be renamed, but for others they may need a major overhaul. 

## Help!

For assistance on performing the above points, please open an issue on our [GitHub issues page](https://github.com/SlavovLab/SCoPE_QC/issues) to directly contact the developers.
