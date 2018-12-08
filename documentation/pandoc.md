# ```pandoc``` Issues

This app uses ```rmarkdown``` which in turn uses ```pandoc``` to generate HTML/PDF reports. If you are launching this app from RStudio, then ```pandoc``` should be provided and should work out of the box.

If not, then ```pandoc``` needs to be available either via an environment variable ```RSTUDIO_PANDOC``` or the system ```PATH```. The application command line start script will attempt to find ```pandoc``` from some common paths, but will print a warning if it can't be found. It is then up to the user to link the binaries, and if RStudio is not installed, to install ```pandoc``` themselves.

Instructions on how to make ```pandoc``` available from an existing RStudio installation can be [found here](https://github.com/rstudio/rmarkdown/blob/master/PANDOC.md).

```pandoc``` can also be installed from [its project page](http://pandoc.org/installing.html) 
