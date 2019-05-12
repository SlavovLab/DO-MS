---
layout: default
title: Automating Report Generation
nav_order: 4
permalink: docs/automation
---

# Automating Report Generation

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

Adding more options via. the command-line can be done by editing the beginning of the ```do-ms_cmd.R``` script. Or, open a GitHub issue.