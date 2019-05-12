# **DO-MS**

<u>D</u>ata-Driven <u>O</u>ptimization of <u>M</u>ass <u>S</u>pectrometry Methods

* [Get started now](#getting-started)
* [BioRxiv Preprint]({{site.preprint_link}})
* [GitHub Repository]({{site.github_link}})

## Getting Started

Please read our detailed getting started guides:
* [Getting started on the application](https://slavovlab.github.io/DO-MS/docs/getting-started-application)
* [Getting started on the command-line](https://slavovlab.github.io/DO-MS/docs/getting-started-command-line)

### Requirements

This application has been tested on R >= 3.5.0, OSX 10.14 / Windows 7/8/10. R can be downloaded from the main [R Project page](https://www.r-project.org/) or downloaded with the [RStudio Application](https://www.rstudio.com/products/rstudio/download/). All modules are maintained for MaxQuant >= 1.6.0.16.

The application suffers from visual glitches when displayed on unsupported older browsers (such as IE9 commonly packaged with RStudio on Windows). Please use IE >= 11, Firefox, or Chrome for the best user experience.

### Installation

Install this application by downloading it from the [release page](https://github.com/SlavovLab/DO-MS/releases).

### Running

The easiest way to run the app is directly through RStudio, by opening the `DO-MS.Rproj` Rproject file

<img src="https://github.com/SlavovLab/DO-MS/raw/master/docs/assets/images/do-ms-proj.png" height="100px">

and clicking the "Run App" button at the top of the application, after opening the `server.R` file. We recommend checking the "Run External" option to open the application in your default browser instead of the RStudio Viewer.

<img src="https://github.com/SlavovLab/DO-MS/raw/master/docs/assets/images/do-ms-run.png" height="100px">

You can also start the application by running the `start_server.R` script.

### Automated Report Generation

You can automatically generate PDF/HTML reports without having to launch the server by running the `do-ms_cmd.R` script, like so:

```
$ Rscript do-ms_cmd.R config_file.yaml
```

This requires a configuration file, and you can [find an example one here](https://github.com/SlavovLab/DO-MS/blob/master/example/config_file.yaml). See [Automating Report Generation](https://slavovlab.github.io/DO-MS/docs/automation) for more details and instructions.

### Customization

DO-MS is designed to be easily user-customizable for in-house proteomics workflows. Please see [Building Your Own Modules](https://slavovlab.github.io/DO-MS/docs/build-your-own) for more details.

### Hosting as a Server

Please see [Hosting as a Server](https://slavovlab.github.io/DO-MS/docs/hosting-as-server) for more details.

### Search Engines Other Than MaxQuant

This application is currently maintained for MaxQuant >= 1.6.0.16. Adapting to other search engines is possible but not provided out-of-the-box. Please see [Integrating Other Search Engines ](https://slavovlab.github.io/DO-MS/docs/other-search-engines) for more details.

### Can I use this for Metabolomics, Lipidomics, etc... ?

While the base library of modules are based around bottom-up proteomics by LC-MS/MS, this project is fundamentally compatible with _any delimited text files_ (CSV, TSV, etc). These implementations will require some programming work, but once it is done DO-MS gives you a extensible framework that can be used over-and-over again to generate shareable reports. See [Integrating Other Search Engines ](https://slavovlab.github.io/DO-MS/docs/other-search-engines) for more details

------------

## About the project

<!--
DART-ID is a project developed in the [Slavov Laboratory](https://web.northeastern.edu/slavovlab/) at [Northeastern University](https://www.northeastern.edu/) [Bioengineering](http://www.bioe.neu.edu/), and was authored by [Albert Tian Chen](https://atchen.me), [Alexander Franks](http://afranks.com/) (of [UCSB Statistics and Applied Probability](https://www.pstat.ucsb.edu/)), and [Nikolai Slavov](https://web.northeastern.edu/slavovlab/).
-->

The manuscript for this tool is available on bioRxiv: [{{site.preprint_link}}]({{site.preprint_link}}).

Contact the authors by email: [nslavov\{at\}northeastern.edu](mailto:nslavov@northeastern.edu).

### License

DO-MS is distributed by an [MIT license]({{site.github_link}}/blob/master/LICENSE).

### Contributing

Please feel free to contribute to this project by opening an issue or pull request in the [GitHub repository]({{site.github_link}}).

### Data

<!--
All data used for the manuscript is available on [UCSD's MassIVE Repository](https://massive.ucsd.edu/ProteoSAFe/dataset.jsp?task=ed5a1ab37dc34985bbedbf3d9a945535)
-->

### Figures/Analysis

<!--
Scripts for the figures in the DART-ID manuscript are available in a separate GitHub repository, [https://github.com/SlavovLab/DART-ID_2018](https://github.com/SlavovLab/DART-ID_2018) 
-->

-------------

## Help!

For any bugs, questions, or feature requests, 
please use the [GitHub issue system](https://github.com/SlavovLab/DO-MS/issues) to contact the developers.