# DO-MS

[https://www.biorxiv.org/content/early/2019/01/06/512152](https://www.biorxiv.org/content/early/2019/01/06/512152)

## Requirements

This application has been tested on R 3.4.4, OSX 10.14 / Windows 7/8/10.

R can be downloaded from the main [R Project page](https://www.r-project.org/)
or downloaded with the [RStudio Application](https://www.rstudio.com/products/rstudio/download/)

## Installation

DO-MS requires an R installation with the ```shiny``` package.

The easiest way to install and run is: ```shiny::runGitHub('DO-MS', 'SlavovLab')```

Or, install this application by downloading it from the GitHub page as a .zip archive, 
or from a bundle on the [release page](https://github.com/SlavovLab/DO-MS/releases).

## Running

The easiest way to run the app is directly through RStudio, by opening the ```DO-MS.Rproj``` Rproject file 
and clicking the "Run App" button at the top of the application.

You can also run the application by running the script ```start_server.sh``` (OSX/Linux), or ```start_server.bat``` (Windows).

## Automated Report Generation

You can automatically generate PDF/HTML reports without having to launch the server by running the ```do-ms_cmd.R``` script, like so:

```
$ Rscript do-ms_cmd.R config_file.yaml
```

This requires a configuration file, and you can [find an example one here](https://github.com/SlavovLab/DO-MS/blob/master/example/config_file.yaml).

See the document [automation.md](https://github.com/SlavovLab/DO-MS/blob/master/documentation/automation.md) for more details and instructions.

## Customization

DO-MS is designed to be easily user-customizable for in-house proteomics workflows. Please see this document for more details: [modules.md](https://github.com/SlavovLab/DO-MS/blob/master/documentation/modules.md)

## Hosting as a Server

Please see this document for more details: [hosting_as_server.md](https://github.com/SlavovLab/DO-MS/blob/master/documentation/hosting_as_server.md)

## Search Engines Other Than MaxQuant

This application is currently maintained for MaxQuant >= 1.6.0.16. Adapting to other search engines is possible but not provided out-of-the-box. Please see [implement_other_search_engines.md](https://github.com/SlavovLab/DO-MS/blob/master/documentation/implement_other_search_engines.md) for more details.

## Help!

For any bugs, questions, or feature requests, 
please use the [GitHub issue system](https://github.com/SlavovLab/DO-MS/issues) to contact the developers.
