# DO-MS

Preprint: [https://www.biorxiv.org/content/early/2019/01/06/512152](https://www.biorxiv.org/content/early/2019/01/06/512152)

Please read our getting started guides on our wiki:
* [Getting started on the application](https://github.com/SlavovLab/DO-MS/wiki/Getting-Started-(Application))
* [Getting started on the command-line](https://github.com/SlavovLab/DO-MS/wiki/Getting-Started-(Command-Line))

## Requirements

This application has been tested on R >= 3.5.0, OSX 10.14 / Windows 7/8/10. R can be downloaded from the main [R Project page](https://www.r-project.org/) or downloaded with the [RStudio Application](https://www.rstudio.com/products/rstudio/download/). All modules are maintained for MaxQuant >= 1.6.0.16.

The application suffers from visual glitches when displayed on unsupported older browsers (such as IE9 commonly packaged with RStudio on Windows). Please use IE >= 11, Firefox, or Chrome for the best user experience.

## Installation

Install this application by downloading it from the [release page](https://github.com/SlavovLab/DO-MS/releases).

## Running

The easiest way to run the app is directly through RStudio, by opening the ```DO-MS.Rproj``` Rproject file

<img src="https://github.com/SlavovLab/DO-MS/raw/master/documentation/images/do-ms-proj.png" title="Open DO-MS.Rproj" height="100">

and clicking the "Run App" button at the top of the application, after opening the ```server.R``` file. We recommend checking the "Run External" option to open the application in your default browser instead of the RStudio Viewer.

<img src="https://github.com/SlavovLab/DO-MS/raw/master/documentation/images/do-ms-run.png" title="Run DO-MS" height="100">

You can also start the application by running the ```start_server.R``` script.

## Automated Report Generation

You can automatically generate PDF/HTML reports without having to launch the server by running the ```do-ms_cmd.R``` script, like so:

```
$ Rscript do-ms_cmd.R config_file.yaml
```

This requires a configuration file, and you can [find an example one here](https://github.com/SlavovLab/DO-MS/blob/master/example/config_file.yaml). See [the Automation Wiki page](https://github.com/SlavovLab/DO-MS/wiki/Automation) for more details and instructions.

## Customization

DO-MS is designed to be easily user-customizable for in-house proteomics workflows. Please see [the Building Your Own Modules Wiki page](hhttps://github.com/SlavovLab/DO-MS/wiki/Building-Your-Own-Modules) for more details.

## Hosting as a Server

Please see [the Hosting as a Server Wiki page](https://github.com/SlavovLab/DO-MS/wiki/Hosting-as-a-Server) for more details.

## Search Engines Other Than MaxQuant

This application is currently maintained for MaxQuant >= 1.6.0.16. Adapting to other search engines is possible but not provided out-of-the-box. Please see [the Implementing Other Search Engines Wiki page](https://github.com/SlavovLab/DO-MS/wiki/Implementing-Other-Search-Engines) for more details.

## Can I use this for Metabolomics, Lipidomics, etc... ?

While the base library of modules are based around bottom-up proteomics by LC-MS/MS, this project is fundamentally compatible with _any delimited text files_ (CSV, TSV, etc). These implementations will require some programming work, but once it is done DO-MS gives you a extensible framework that can be used over-and-over again to generate shareable reports. See [the Implementing Other Search Engines Wiki page](https://github.com/SlavovLab/DO-MS/wiki/Implementing-Other-Search-Engines) for more details

## Help!

For any bugs, questions, or feature requests, 
please use the [GitHub issue system](https://github.com/SlavovLab/DO-MS/issues) to contact the developers.
