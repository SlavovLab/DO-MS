#!/bin/R

repos <- getOption('repos')
repos['CRAN'] <- 'https://cloud.r-project.org'

options(repos=repos)

# look for pandoc
# stolen from https://github.com/r-lib/rappdirs/blob/master/R/utils.r
get_os <- function() {
  if (.Platform$OS.type == "windows") { 
    "win"
  } else if (Sys.info()["sysname"] == "Darwin") {
    "mac" 
  } else if (.Platform$OS.type == "unix") { 
    "unix"
  } else {
    stop("Unknown OS")
  }
}
os <- get_os()

pandoc_osx <- "/Applications/RStudio.app/Contents/MacOS/pandoc"
pandoc_windows <- "C:\\Program Files\\RStudio\\bin\\pandoc"
pandoc_linux <- "/usr/lib/rstudio/bin/pandoc"

# try and predict pandoc directories
if(os == 'mac' & file.exists(pandoc_osx)) {
  Sys.setenv(RSTUDIO_PANDOC=pandoc_osx)
} else if (os == 'win' & file.exists(pandoc_windows)) {
  Sys.setenv(RSTUDIO_PANDOC=pandoc_windows)
} else if (os == 'unix' & file.exists(pandoc_linux)) {
  Sys.setenv(RSTUDIO_PANDOC=pandoc_linux)
} else {
  print('pandoc could not be found in default directories. If it is not available on the system PATH then PDF report generation will fail.')
}

library(shiny)

port <- 8080
host <- '127.0.0.1'

shiny::runApp(getwd(), host=host, port=port, launch.browser = T)

