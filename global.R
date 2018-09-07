#Packages to check for
packages.needed <- c("shiny","shinydashboard","shinyWidgets","dplyr","plyr","ggplot2","reshape2","RColorBrewer")

#Checking installed packages against required ones
new.packages <- packages.needed[!(packages.needed %in% installed.packages()[,"Package"])]

#Install those which are absent
if(length(new.packages)) install.packages(new.packages, dependencies = TRUE) 

#Libraries to load
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(dplyr)
library(plyr)
library(ggplot2) 
library(reshape2)
library(RColorBrewer)

modules <- list()

module_files <- list.files('modules')
for(module in module_files) {
  source(file.path('modules', module))
  module_name <- gsub('.R', '', module)
  modules[[module_name]] <- init()
  modules[[module_name]][['id']] <- module_name
}

# collect all tab names
tabs <- c()
for(module in modules) {
  tabs <- c(tabs, module$tab)
}
tabs <- unique(tabs)

input_files <- list(
  evidence=list(
    name='evidence',
    help='MaxQuant evidence.txt file'),
  msms=list(
    name='msms',
    help='MaxQuant msms.txt file'),
  msmsScans=list(
    name='msmsScans',
    help='MaxQuant msmsScans.txt file'),
  allPeptides=list(
    name='allPeptides',
    help='MaxQuant allPeptides.txt file')
)



textVar <- 1.1

facetHist <- function(DF, X) {
  ggplot(DF, aes_string(X)) + 
    facet_wrap(as.formula(paste("~", "Raw.file")), nrow = 1) + 
    geom_histogram(bins=100) + 
    coord_flip() + 
    theme(
      panel.background = element_rect(fill="white", colour = "white"), 
      panel.grid.major = element_line(size=.25, linetype="solid", color="lightgrey"), 
      panel.grid.minor = element_line(size=.25, linetype="solid", color="lightgrey"),
      legend.position="none",
      axis.text.x = element_text(angle=45, hjust = 1, margin=margin(r=45)),
      axis.title = element_text(size=rel(1.2), face="bold"), 
      axis.text = element_text(size=rel(textVar)),
      strip.text = element_text(size=rel(textVar))
    ) 
}


downloadButtonFixed <- function(outputId, label = "Download", class = NULL, ...) {
  aTag <-
    tags$a(
      id = outputId,
      class = paste('btn btn-default shiny-download-link', class),
      href = '',
      target = NA, #'_blank',
      download = NA,
      icon("download"),
      label,
      ...
    )
}

