#Packages to check for

packages.needed <- c("shiny","shinydashboard","shinyWidgets","dplyr","plyr","ggplot2","reshape2","RColorBrewer", "readr", 'rmarkdown', 'prettydoc', "stats")
#packages.bioc<-c("impute")


#Checking installed packages against required ones
new.packages <- packages.needed[!(packages.needed %in% installed.packages()[,"Package"])]
#new.packages.bioc <- packages.bioc[!(packages.bioc %in% installed.packages()[,"Package"])]

#Install those which are absent
# if(length(new.packages)) install.packages(new.packages, dependencies = TRUE) 
# 
# if(length(new.packages.bioc)) {
#   
#   source("https://bioconductor.org/biocLite.R")
#   
#   for(X in new.packages.bioc){
#     
#     biocLite(X)
#   
#     }
# }

#Libraries to load
library(impute)
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
library(stats)

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
tabs <- gsub('([0-9])+(\\s|_)', '', tabs)

# to get custom panel heading colors for each tab,
# need to dynamically inject some CSS into the app_css string
tab_colors <- c(RColorBrewer::brewer.pal(5, 'Set1'), 
                RColorBrewer::brewer.pal(8, 'Dark2')[c(1, 4, 3, 5, 2)])
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
    help='MaxQuant allPeptides.txt file'),
  inc=list(
    name='inc',
    help='Inclusion list .txt file')
)

# load app.css into string
app_css <- paste(readLines('app.css'), collapse='')

# load app.js into string
app_js <- paste(readLines('app.js'), collapse='\n')

#textVar <- 1.1

theme_base <- function(input=list()) {
  
  # default values
  axis_font_size <- ifelse(is.null(input[['figure_axis_font_size']]), 
                     12, input[['figure_axis_font_size']])
  title_font_size <- ifelse(is.null(input[['figure_title_font_size']]),
                            16, input[['figure_title_font_size']])
  facet_font_size <- ifelse(is.null(input[['figure_facet_font_size']]),
                            12, input[['figure_facet_font_size']])
  
  show_grid <- ifelse(is.null(input[['figure_show_grid']]),
                      TRUE, input[['figure_show_grid']])
  
  .theme <- theme(
    panel.background = element_rect(fill="white", colour = "white"), 
    legend.position="none",
    axis.text.x = element_text(angle=45, hjust=1, margin=margin(r=45)),
    axis.title = element_text(size=title_font_size, face="bold"), 
    axis.text = element_text(size=axis_font_size),
    strip.text = element_text(size=facet_font_size)
  )
  
  if(show_grid) {
    .theme <- .theme + theme(
      panel.grid.major = element_line(size=0.25, linetype="solid", color="lightgrey"), 
      panel.grid.minor = element_line(size=0.25, linetype="solid", color="lightgrey")
    )
  } else {
    .theme <- .theme + theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()
    )
  }
  
  return(.theme)
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

