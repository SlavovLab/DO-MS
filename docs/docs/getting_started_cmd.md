---
layout: default
title: Command Line
nav_order: 2
permalink: docs/getting-started-command-line
parent: Getting Started
---

# Getting Started -- DO-MS Command Line

DO-MS can be run from the command-line to generate reports. Insert DO-MS into your own automated proteomics workflow to get hands-free, easily shareable generated reports.

**Table of Contents**

1. [Example Data](#example-data)
2. [`do-ms_cmd.R`](#do-ms_cmdr)
3. [Configuration File](#configuration-file)
4. [Command-line Arguments](#command-line-arguments)

## Example Data

We have provided an example data set online, SQC68, which was used for the Apex Offset figure in the DO-MS paper. You can download a .zip bundle of it here: [https://drive.google.com/open?id=1hcWDtnD9MzTZbF-qc0rGEFUBZgtlEQTv](https://drive.google.com/open?id=1hcWDtnD9MzTZbF-qc0rGEFUBZgtlEQTv). The contents of the archive are some of the outputs of the `txt` folder from a MaxQuant search.

The only constraint for data in DO-MS is that it must be from MaxQuant version >= 1.6.0.16.


## do-ms_cmd.R

The entry point for the command-line report generation is `do-ms_cmd.R`. To begin run this directly as an executable or with the Rscript program.

Windows:

```bash
Rscript.exe do-ms_cmd.R
```

Linux/Mac OS:

```bash
$ Rscript do-ms_cmd.R
```

If you are having trouble getting Rscript to run, please see [the Rscript section on the Known Issues Wiki page]({{site.baseurl}}/docs/known-issues#r-rscript-issues) for more details.

Running `do-ms_cmd.R` alone should give the following usage help text:

```
usage: do-ms_cmd.R [-h] [-v] [-i INPUT_FOLDERS [INPUT_FOLDERS ...]]
                     [-o OUTPUT] [-f LOAD_INPUT_FILES [LOAD_INPUT_FILES ...]]
                     [--include-files INCLUDE_FILES]
                     [--exclude-files EXCLUDE_FILES]
                     [--exp_names EXP_NAMES [EXP_NAMES ...]]
                     [--pep_thresh PEP_THRESH]
                     config_file
do-ms_cmd.R: error: the following arguments are required: config_file
```

## Configuration File

The command-line DO-MS uses a configuration file to apply all of the various settings used for the report generation. Many but not all of these settings are analogous to the fields in the interactive application. An annotated configuration file describing each of the fields is given [in the examples folder as config_file.yaml](https://github.com/SlavovLab/DO-MS/blob/master/example/config_file.yaml).

For the example data, we also provide a config file, [config_sqc68.yaml](https://github.com/SlavovLab/DO-MS/blob/master/example/config_sqc68.yaml). You may need to change the paths for both the input folder and output file, but the rest of the settings can be kept as-is.

Run DO-MS with the example configuration file with:

```
$ Rscript do-ms_cmd.R example/config_sqc68.yaml
...
Output created: ~/Downloads/SQC68_DO-MS_report.html
[1] "Report written to: ~/Downloads/SQC68_DO-MS_report.html"
[1] "Done!"
```

An example generated report using this configuration file is available online here: [https://drive.google.com/open?id=1SKB639JXFIk-rOAMA1vBXaxyheQv9-bu](https://drive.google.com/open?id=1SKB639JXFIk-rOAMA1vBXaxyheQv9-bu)

## Command-line Arguments

As displayed in the usage text, many settings can be passed to `do-ms_cmd.R` via. the command-line rather than via. the configuration file. This is useful for workflows that want to change inputs/outputs but are incapable/unwilling to create a new configuration file for each run. Command-line arguments will also override any setting in the configuration file.

```
$ Rscript do-ms_cmd.R example/config_sqc68.yaml -i ~/Downloads/example_data_SQC68 -o ~/Downloads/SQC68_DO-MS_report.html --include-files SQC68D[1-3] --exp_names "250ms IT" "500ms IT" "1000ms IT"
...
Output created: ~/Downloads/SQC68_DO-MS_report.html
[1] "Report written to: ~/Downloads/SQC68_DO-MS_report.html"
[1] "Done!"
```
