---
layout: default
title: Known Issues
nav_order: 10
permalink: docs/known-issues
---

# Known Issues

Please refer to this document for any issues you encounter during install or usage. If what you have is not listed here, then use the [GitHub issue system](https://github.com/SlavovLab/DO-MS/issues) to contact the developers.

## R, Rscript issues

If running the server with the `start_server` scripts, then you may run into the following issues:

- For OSX/Linux, `Rscript` must be available on the path, and for Windows, you will need to edit the `start_server.bat` script to point to the specific `Rscript.exe` executable.

- If you are having trouble loading `shiny`, please confirm that you have installed the package in the "Installation" step. If so, then you may need to define a new environment variable, `R_LIBS_USER`, that points to the library path of your R installation. See [this StackOverflow answer](https://stackoverflow.com/a/19662905) for more details on this issue.

## Rendering/Display issues

Some users have reported issues with the package opening within RStudio's viewer pane, rather than within a separate browser window. Please make sure that you have the appropriate option checked in the dropdown menu of the 'Run App' button, if using RStudio.


## pandoc not found

This app uses `rmarkdown` which in turn uses `pandoc` to generate HTML/PDF reports. If you are launching this app from RStudio, then `pandoc` should be provided and should work out of the box.

If not, then `pandoc` needs to be available either via an environment variable `RSTUDIO_PANDOC` or the system `PATH`. The application command line start script will attempt to find `pandoc` from some common paths, but will print a warning if it can't be found. It is then up to the user to link the binaries, and if RStudio is not installed, to install `pandoc` themselves.

Instructions on how to make `pandoc` available from an existing RStudio installation can be [found here](https://github.com/rstudio/rmarkdown/blob/master/PANDOC.md).

`pandoc` can also be installed from [its project page](http://pandoc.org/installing.html) 