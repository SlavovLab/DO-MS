# AUTOMATION

Automated report generation is available via. the ```do-ms_cmd.R``` script. To generate a report, simply run:

```
Rscript do-ms_cmd.R config_file.yaml
```

### Configuration file

The configuration file is specified in the YAML file format. An annotated example can be [found here](https://github.com/SlavovLab/DO-MS/blob/master/example/config_file.yaml)

All files specified under ```input_files``` _must_ be specified in ```global.R``` as part of the available input file list. If you're using custom modules, or using a different search engine, please update the list in ```global.R``` first.

For the fields ```include_files```, ```exclude_files```, ```pep_thresh```, ```remove_decoy```, and ```remove_contam```, if you don't wish to apply these filters, simply comment out the line in the config file by appending with the ```#``` character.

Experiment short names specified in ```exp_names``` are applied _after_ filtering, i.e., to the list of raw files that survive the user-specified filters. If too few/too many names are listed, the program will assign them or ignore them accordingly. A map of short names to raw files can be outputted as a module.


### Command-line arguments

Some, but not all, of the fields in the configuration file can also be specified via. the command line. This is useful for automated pipelines where programatically editing the config file would be problematic. View the available arguments by running ```Rscript do-ms_cmd.R -h```

```
$ Rscript do-ms_cmd.R -h
usage: do-ms_cmd.R [-h] [-v] [-i INPUT_FOLDERS [INPUT_FOLDERS ...]]
                   [-o OUTPUT] [-f INPUT_FILE_TYPES [INPUT_FILE_TYPES ...]]
                   [--include_exps INCLUDE_EXPS] [--exclude_exps EXCLUDE_EXPS]
                   [--exp_names EXP_NAMES [EXP_NAMES ...]]
                   [--pep_threshold PEP_THRESHOLD]
                   config_file

Generate DO-MS report

positional arguments:
  config_file           Path to config file (YAML format). Required

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         Print detailed output (default: true)
  -i INPUT_FOLDERS [INPUT_FOLDERS ...], --input-folders INPUT_FOLDERS [INPUT_FOLDERS ...]
                        One or more folder paths to generate report from
  -o OUTPUT, --output OUTPUT
                        Path to report file output. e.g.,
                        "/path/to/report.html"
  -f INPUT_FILE_TYPES [INPUT_FILE_TYPES ...], --input-file-types INPUT_FILE_TYPES [INPUT_FILE_TYPES ...]
                        Names of MaxQuant text files to process. e.g.,
                        "summary evidence allPeptides"
  --include_exps INCLUDE_EXPS
                        Include raw files matching this regular expression.
                        e.g., "SQC98[ABC]"
  --exclude_exps EXCLUDE_EXPS
                        Exclude raw files matching this regular expression.
                        e.g., "SQC98[ABC]"
  --exp_names EXP_NAMES [EXP_NAMES ...]
                        Rename raw files with short names. e.g., "Control 2X
                        4X 10X"
  --pep_threshold PEP_THRESHOLD
                        PEP threshold for identified peptides, remove all
                        below this threshold. e.g., "0.01"
```

Adding more options via. the command-line can be done by editing the beginning of the ```do-ms_cmd.R``` script. Or, open an issue and we can take care of it.
