#Packages to check for
packages.needed <- c("shiny","shinydashboard","shinyWidgets","dplyr","plyr","ggplot2","reshape2","RColorBrewer", "readr", 'rmarkdown', 'prettydoc')

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
library(readr)
library(rmarkdown)
library(prettydoc)

modules <- list()

module_files <- list.files('modules')
for(module in module_files) {
  # skip module if it begins with '__'
  if(substr(module, 1, 2) == '__') { next }
  
  # source module to load the init named list
  source(file.path('modules', module))
  # load the module into the module list
  module_name <- gsub('.R', '', module)
  modules[[module_name]] <- init()
  modules[[module_name]][['id']] <- module_name
}

# collect all tab names
tabs <- c()
for(module in modules) {
  tabs <- c(tabs, module$tab)
}
tabs <- sort(unique(tabs))

# to get custom panel heading colors for each tab,
# need to dynamically inject some CSS into the app_css string
tab_colors <- c(RColorBrewer::brewer.pal(5, 'Set1'), RColorBrewer::brewer.pal(8, 'Dark2'))
# repeat by 10 so we never run out of tab colors
tab_colors <- rep(tab_colors, 10)

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

# load app.css into string
app_css <- paste(readLines('app.css'), collapse='')

#textVar <- 1.1

theme_base <- function(input=list()) {
  
  # default values
  fontSize <- ifelse(is.null(input[['figure_font_size']]), 12, input[['figure_font_size']])
  
  theme(
    panel.background = element_rect(fill="white", colour = "white"), 
    panel.grid.major = element_line(size=0.25, linetype="solid", color="lightgrey"), 
    panel.grid.minor = element_line(size=0.25, linetype="solid", color="lightgrey"),
    legend.position="none",
    axis.text.x = element_text(angle=45, hjust=1, margin=margin(r=45)),
    axis.title = element_text(size=fontSize*1.1, face="bold"), 
    axis.text = element_text(size=fontSize),
    strip.text = element_text(size=fontSize)
  )
}

facetHist <- function(DF, X, num_bins=100) {
  ggplot(DF, aes_string(X)) + 
    facet_wrap(as.formula(paste("~", "Raw.file")), nrow = 1) + 
    geom_histogram(bins=num_bins) + 
    coord_flip() + 
    theme_base()
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

