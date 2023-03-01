#!/bin/R

repos <- getOption('repos')
repos['CRAN'] <- 'https://cloud.r-project.org'

options(repos=repos)

library(shiny)

port <- 8080
host <- '127.0.0.1'

shiny::runApp(getwd(), host=host, port=port, launch.browser = T)