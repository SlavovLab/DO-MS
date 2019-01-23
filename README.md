# DO-MS

[https://www.biorxiv.org/content/early/2019/01/06/512152](https://www.biorxiv.org/content/early/2019/01/06/512152)

## Requirements

This application has been tested on R 3.4.4, OSX 10.14 / Windows 7/8/10, 
but should be supported on any platform that is supported by R and Shiny.

R can be downloaded from the main [R Project page](https://www.r-project.org/)
or downloaded with the [RStudio Application](https://www.rstudio.com/products/rstudio/download/)

This application uses some libraries, but is set up to download them on the first run. 
For a complete list of the dependencies of this application, view ```global.R```.

## Installation

The easiest way to install and run is: ```shiny::runGitHub('DO-MS', 'SlavovLab')```

-----------------

Or, install this application by downloading it from the GitHub page as a .zip archive, 
or from a bundle on the [release page](https://github.com/SlavovLab/DO-MS/releases).

Alternatively, if you are comfortable from the command line and have ```git``` installed:

```{bash}
git clone https://github.com/SlavovLab/DO-MS
```

You will also need to install the ```shiny``` library via. R. In R, run:

```{r}
install.packages('shiny')
```

We are in the process of submitting this application to the CRAN for easier installation. Stay tuned!

## Running

The easiest way to run the app is directly through RStudio, by opening the ```DO-MS.Rproj``` Rproject file 
and clicking the "Run App" button at the top of the application.

You can also run the application by running the script ```start_server.sh``` (OSX/Linux), or ```start_server.bat``` (Windows). This option is less desirable as some of the dependencies bundled by RStudio have to be found or loaded manually (see [pandoc requirements](https://github.com/SlavovLab/DO-MS/blob/master/documentation/pandoc.md))
For OSX/Linux, ```Rscript``` must be available on the path, and for Windows, you will need to edit the ```start_server.bat``` script to point to the specific ```Rscript.exe``` executable.

If you are having trouble loading ```shiny```, please confirm that you have installed the package in the "Installation" step. If so, then you may need to define a new environment variable, ```R_LIBS_USER```, that points to the library path of your R installation. See [this StackOverflow answer](https://stackoverflow.com/a/19662905) for more details on this issue.

Also, some users have reported issues with the package opening within RStudio's viewer pane, rather than within a separate browser window. Please make sure that you have the appropriate option checked in the dropdown menu of the 'Run App' button, if using RStudio.

## Automated Report Generation

You can automatically generate PDF/HTML reports without having to launch the server by running the ```do-ms_cmd.R``` script, like so:

```
$ Rscript do-ms_cmd.R config_file.yaml
```

This requires a configuration file, and you can [find an example one here](https://github.com/SlavovLab/DO-MS/blob/master/example/config_file.yaml).

## Customization

The UI for this application is generated dynamically from the contents of the ```modules``` folder. Users can add their own modules to this folder, following the template provided in ```modules/__template.R```. Modules can be disabled by appending two underscores to the filename, e.g., ```disable_module.R``` --> ```__disable_module.R```.

Currently modules are limited to plotting and providing data for download. More features, such as custom inputs are forthcoming.

## Hosting as a Server

As this application requires a large amount of computational power (CPU), on-hand memory (RAM), and possibly the storage of large amounts of mass-spec data (Storage), we do not recommend running this on a standalone server, as it is not cost-efficient.

If you wish to host a server for internal usage, i.e., within an organizational intranet, you can change the host IP to "0.0.0.0" instead of "127.0.0.1", which exposes the server outside of the machine itself.

## Search Engines Other Than MaxQuant

This application is currently maintained for MaxQuant >= 1.6.0.16. Adapting this application to other search engines is straightfowards but does require some code editing. Please see [this document on implementing other search engines](https://github.com/SlavovLab/DO-MS/blob/master/documentation/implement_other_search_engines.md) for more detailed instructions.

## Help!

For any bugs, questions, or feature requests, 
please use the [GitHub issue system](https://github.com/SlavovLab/DO-MS/issues) to contact the developers.
