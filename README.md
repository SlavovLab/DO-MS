# SCoPE_QC

Shiny app for SCoPE QC visualization

## Requirements

This application has been tested on R 3.4.4, OSX 10.14 / Windows 7/8/10, 
but should be supported on any platform that is supported by R and Shiny.

R can be downloaded from the main [R Project page](https://www.r-project.org/)
or downloaded with the [RStudio Application](https://www.rstudio.com/products/rstudio/download/)

This application uses some libraries, but is set up to download them on the first run. 
For a complete list of the dependencies of this application, view ```global.R```.

## Installation

Install this application by downloading it from the GitHub page as a .zip archive, 
or from a bundle on the [release page](https://github.com/SlavovLab/SCoPE_QC/releases).

Or, if you are comfortable from the command line and have ```git``` installed:

```{bash}
git clone https://github.com/SlavovLab/SCoPE_QC
```

We are in the process of submitting this application to the CRAN for easier installation. Stay tuned!

## Running

The app can be run directly from RStudio by opening the ```SCoPE_QC.Rproj``` Rproject file 
and clicking the "Run App" button at the top of the application.

You can also run the application with an Rscript, by running the command:
```{r}
library(shiny)
runApp(appDir='/path/to/SCoPE_QC/')
```

## Customization

WIP

## Help!

For any bugs, questions, or feature requests, 
please use the GitHub [issue system](https://github.com/SlavovLab/SCoPE_QC/issues) to contact the developers.
