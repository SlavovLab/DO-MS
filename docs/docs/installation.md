---
layout: default
title: Installation
nav_order: 2
permalink: docs/getting-started-installation
---

**Table of Contents**

1. [Interactive DO-MS App](#interactive-do-ms-app)
    1. [Installation](#installation)
    2. [Running](#running)
2. [DIA Python Pipeline](#dia-python-pipeline)
    1. [Installation](#installation)
    2. [Running](#running)
    3. [Setup Custom Script ](#setup-custom-script)
        1. [Windows](#windows)
        2. [MacOS](#macos)

# Interactive DO-MS App

## Installation

This application has been tested on R >= 3.5.0, OSX >= 10.14 / Windows 7/8/10/11. Make sure you have the mos recent version of R and R Studio installed. R can be downloaded from the main [R Project page](https://www.r-project.org/) or downloaded with the [RStudio Application](https://www.rstudio.com/products/rstudio/download/). All modules are maintained for MaxQuant >= 1.6.0.16.

The application suffers from visual glitches when displayed on unsupported older browsers (such as IE9 commonly packaged with RStudio on Windows). Please use IE >= 11, Firefox, or Chrome for the best user experience.



## Running 

The easiest way to run the app is directly through RStudio, by opening the `DO-MS.Rproj` Rproject file

![]({{site.baseurl}}/assets/images/do-ms-proj.png){: width="70%" .center-image}

and clicking the "Run App" button at the top of the application, after opening the `server.R` file. We recommend checking the "Run External" option to open the application in your default browser instead of the RStudio Viewer.

![]({{site.baseurl}}/assets/images/do-ms-run.png){: width="70%" .center-image}

You can also start the application by running the `start_server.R` script. 

More information on using the DO-MS application is provided [here]({{site.baseurl}}/docs/getting-started-application).

# DIA Python Pipeline

## Installation

1. Please make sure that [Conda](https://docs.conda.io/en/latest/) or [Miniconda](https://docs.conda.io/en/latest/miniconda.html) are installed.
Use the provided conda configuration to create the environment with all required dependencies.
```
conda env create -f pipeline/env.yml
```

2. Activate the environment and check that the command can be run.
```
conda activate doms
python pipeline/processing.py -h
```

3. For automatic conversion of Thermo Raw files to the open mzML format ThermoRawFileParser (Hulstaert et al. 2020) is required. Download the latest release of the [ThermoRawFileParser](https://github.com/compomics/ThermoRawFileParser) (version v1.4.0 or newer) and note down the location of the ```ThermoRawFileParser.exe``` file. Under OSX and Linux, [Mono](https://www.mono-project.com/download/stable/). Please make sure to use the option ```-m``` with the feature detection which will tell the script to use Mono. 

4. For feature detection Dinosaur (Teleman et al. 2016) is used. Download the latest release of the Dinosaur from [Mono](https://github.com/fickludd/dinosaur) and install Java as recommended on your platform. Please note down the location of the ```Dinosaur-xx.jar``` file.

5. Optional, create a custom script for your system.

## Running

```python pipeline/processing.py -h```

More information on using the python pipeline is provided [here]({{site.baseurl}}/docs/getting-started-preprocessing).

## Setup Custom Script 

Using the feature detection requires the correct conda environment, ThermoRawFileParser and Dinosaur location. If the tool is used frequently its more convenient to package the configuration in a script which is added to the system ```PATH```. This will register a local command which can be used everywhere on the system and allows to set default options.

### Windows

1. Create a local folder for example under ```C:\Users\xxx\Documents\bin```.

2. Create a file named ```processing.bat``` with the following content. Make sure that all three file paths are changed to the corresponding locations on your system.
Further default options can be added to this file if needed. An overview of all command line options can be found [here]({{site.baseurl}}/docs/getting-started-preprocessing).

```
@echo off
conda activate doms & ^
python C:\Users\xxx\pipeline\processing.py %* ^
--dinosaur-location "C:\Users\xxx\dinosaur-1.2\Dinosaur-1.2.0.free.jar" ^
--raw-parser-location "C:\Users\xxx\thermo_raw_file_parser_1.3.4\ThermoRawFileParser.exe" 
```
 
3. Search ```environment variables``` in the windows search and click ```Edit the system environment variables```. 

4. Click ```Environment Variables``` in the bottom right.

5. Select the variable ```Path``` in the upper panel saying ```User variables ...``` and click ```Edit```.

6. Click ```New``` and enter the location of the directory containing the ```processing.bat``` script.

7. Now, the feature processing including the external tools can be called from anywhere on the machine with the ```processing``` command.


### MacOS


1. Create a local folder for example ```/Users/xxx/Documents/bin```.

2. Create a file named ```processing``` with the following content. Make sure that all three file paths are changed to the corresponding locations on your system.
```
#!/bin/bash
eval "$(conda shell.bash hook)"
conda activate doms
python /Users/xxx/pipeline/processing.py "$@" \
-m \
--dinosaur-location "/Users/xxx/Dinosaur/Dinosaur-1.2.0.free.jar" \
--raw-parser-location "/Users/xxx/ThermoRawFileParser/ThermoRawFileParser.exe"
```
The first line makes conda available to the script ([known issue](https://github.com/conda/conda/issues/7980)). Please note how the mono option ```-m``` is used by default. Further default options can be added to this file if needed. An overview of all command line options can be found [here]({{site.baseurl}}/docs/getting-started-preprocessing).

3. make the file executable with the following command ```chmod +x processing```.
 
4. Navigate to the location of your bash profile file in your home directory. This will be ```/Users/{username}/.zshrc``` for zsh and ```/Users/{username}/.bash_profile``` for bash on macOS and ```/home/xxx/.bashrc``` for bash on linux. Open the file in a text editor of choice, for example vim ```vim .bash_profile```. Go into edit mode by pressing ```i```.

5. Add the line ```export PATH="/Users/xxx/Documents/bin:$PATH"``` to the end of the file and save the file by pressing ```ESSC```, ```:wq```, ```Enter```.

6. Restart your terminal.
