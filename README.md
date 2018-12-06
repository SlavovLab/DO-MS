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

You will also need to install the ```shiny``` library via. R. In R, run:

```{r}
install.packages('shiny')
```

We are in the process of submitting this application to the CRAN for easier installation. Stay tuned!

## Running

You can run the application by running the script ```start_server.sh``` (OSX/Linux), or ```start_server.bat``` (Windows).
For OSX/Linux, ```Rscript``` must be available on the path, and for Windows, 
you will need to edit the ```start_server.bat``` script to point to the specific ```Rscript.exe``` executable.

If you are having trouble loading ```shiny```, please confirm that you have installed the package in the "Installation" step. If so, then you may need to define a new environment variable, ```R_LIBS_USER```, that points to the library path of your R installation. See [this StackOverflow answer](https://stackoverflow.com/a/19662905) for more details on this issue.

The app can also be run directly from RStudio by opening the ```SCoPE_QC.Rproj``` Rproject file 
and clicking the "Run App" button at the top of the application.

You can also run the application with an Rscript, by running the command:
```{r}
library(shiny)
runApp(appDir='/path/to/SCoPE_QC/')
```

## Customization

The UI for this application is generated dynamically from the contents of the ```modules``` folder. Users can add their own modules to this folder, following the template provided in ```modules/__template.R```. Modules can be disabled by appending two underscores to the filename, e.g., ```disable_module.R``` --> ```__disable_module.R```.

Currently modules are limited to plotting and providing data for download. More features, such as custom inputs are forthcoming.

## Hosting as a Server

Our lab is currently hosting a demo server of this application at [http://do-ms.tunnel.halfgrain.com:8081](http://do-ms.tunnel.halfgrain.com:8081). This version is a slightly custom-build that for example has password-protected file forms.

As this application requires a large amount of computational power (CPU), on-hand memory (RAM), and possibly the storage of large amounts of mass-spec data (Storage), we do not recommend running this on a standalone server, as it is not cost-efficient. 

We are hosting our server on a desktop machine, and making the server publicly available via. a reverse proxy. Instructions to do this yourself are upcoming. Still, by far the easiest way to use the application is to run it locally.

## Search Engines Other Than MaxQuant

This application is currently maintained for MaxQuant >= 1.6.0.16. Adapting this application to other search engines is straightfowards but does require some code editing. Please see [this document on implementing other search engines](https://github.com/SlavovLab/SCoPE_QC/blob/master/documentation/implement_other_search_engines.md) for more detailed instructions.

## Help!

For any bugs, questions, or feature requests, 
please use the [GitHub issue system](https://github.com/SlavovLab/SCoPE_QC/issues) to contact the developers.
