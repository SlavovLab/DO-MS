#!/bin/R

r <- getOption('repos')
r['CRAN'] <- 'https://cloud.r-project.org'
options(repos=r)

library(shiny)

shiny::runApp(getwd(), port=8080)