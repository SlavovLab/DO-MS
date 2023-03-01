# **DO-MS**

<u>D</u>ata-Driven <u>O</u>ptimization of <u>M</u>ass <u>S</u>pectrometry Methods

![Python Package](https://github.com/SlavovLab/DO-MS-DIA/actions/workflows/python-package.yml/badge.svg)
![GitHub release](https://img.shields.io/github/release/SlavovLab/DO-MS.svg)
![GitHub](https://img.shields.io/github/license/SlavovLab/DO-MS.svg)

* [Website](https://do-ms.slavovlab.net)
* [Get started now](#getting-started)
* [Download](https://github.com/SlavovLab/DO-MS/releases/latest)
* [BioArxiv Preprint](https://www.biorxiv.org/content/10.1101/2023.02.02.526809v1)

<img src="https://do-ms.slavovlab.net/assets/images/do-ms-dia_title_v2.png" width="70%">


## Getting Started

Please read our detailed getting started guides:
* [Getting started with DIA preprocessing](https://do-ms.slavovlab.net/docs/getting-started-preprocessing)
* [Getting started with DIA reports](https://do-ms.slavovlab.net/docs/getting-started-dia-app)
* [Getting started with DDA reports](https://do-ms.slavovlab.net/docs/getting-started-dda-app)

### Requirements
This application has been tested on R >= 3.5.0, OSX 10.14 / Windows 7/8/10/11. R can be downloaded from the main [R Project page](https://www.r-project.org/) or downloaded with the [RStudio Application](https://www.rstudio.com/products/rstudio/download/). All modules are maintained for MaxQuant >= 1.6.0.16 and DIA-NN > 1.8.1.

The application suffers from visual glitches when displayed on unsupported older browsers (such as IE9 commonly packaged with RStudio on Windows). Please use IE >= 11, Firefox, or Chrome for the best user experience.

### Running the Interactive Application

The easiest way to run the app is directly through RStudio, by opening the `DO-MS.Rproj` Rproject file

![](https://do-ms.slavovlab.net/assets/images/do-ms-proj.png){: width="70%" .center-image}

and clicking the "Run App" button at the top of the application, after opening the `server.R` file. We recommend checking the "Run External" option to open the application in your default browser instead of the RStudio Viewer.

![](https://do-ms.slavovlab.net/assets/images/do-ms-run.png){: width="70%" .center-image}

You can also start the application by running the `start_server.R` script.

### Customization

DO-MS is designed to be easily user-customizable for in-house proteomics workflows. Please see [Building Your Own Modules](https://do-ms.slavovlab.net/docs/build-your-own) for more details.

### Hosting as a Server

Please see [Hosting as a Server](https://do-ms.slavovlab.net/docs/hosting-as-server) for more details.

### Supporting other Search Engines

This application is currently maintained for (MaxQuant)[https://www.nature.com/articles/nbt.1511] >= 1.6.0.16 and  (DIA-NN)[https://www.nature.com/articles/s41592-019-0638-x] >= 1.8. Adapting to other search engines is possible but not provided out-of-the-box. Please see [Integrating Other Search Engines ](https://do-ms.slavovlab.net/docs/other-search-engines) for more details.

### Can I use this for Metabolomics, Lipidomics, etc... ?

While the base library of modules are based around bottom-up proteomics by LC-MS/MS, this project is fundamentally compatible with _any delimited text files_ (CSV, TSV, etc). These implementations will require some programming work, but once it is done DO-MS gives you a extensible framework that can be used over-and-over again to generate shareable reports. See [Integrating Other Search Engines ](https://do-ms.slavovlab.net/docs/other-search-engines) for more details

------------

## About the project

The manuscript for this tool is published at the Journal of Proteome Research: [https://pubs.acs.org/doi/10.1021/acs.jproteome.9b00039](https://pubs.acs.org/doi/10.1021/acs.jproteome.9b00039)
The manuscript for the extended version 2.0 can be found on bioArxiv: [https://www.biorxiv.org/content/10.1101/2023.02.02.526809v1](https://www.biorxiv.org/content/10.1101/2023.02.02.526809v1)

Contact the authors by email: [nslavov\{at\}northeastern.edu](mailto:nslavov@northeastern.edu).

### License

DO-MS is distributed by an [MIT license](https://github.com/SlavovLab/DO-MS/blob/master/LICENSE).

### Contributing

Please feel free to contribute to this project by opening an issue or pull request in the [GitHub repository](https://github.com/SlavovLab/DO-MS).

-------------

## Help!

For any bugs, questions, or feature requests,
please use the [GitHub issue system](https://github.com/SlavovLab/DO-MS/issues) to contact the developers.
