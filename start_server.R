#!/bin/R

r <- getOptions('repos')
r['CRAN'] <- 'https://cloud.r-project.org'
options(repos=r)

library(shiny)

shiny::runApp(getwd(), port=8080)