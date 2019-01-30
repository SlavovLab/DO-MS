# first, get pacman
if(!'pacman' %in% installed.packages()[,'Package']) {
  install.packages('pacman')
}
library(pacman)

# install/load dependencies
p_load(shiny, shinydashboard, shinyWidgets, dplyr, ggplot2, lattice, knitr,
       reshape2, readr, rmarkdown, stats, DT, stringr, yaml)

# load application settings
config <- read_yaml('settings.yaml')


# load tabs first
tabs <- list.dirs('modules', recursive=F, full.names=F)
# remove commented-out tabs (folders that start with "__")
tabs <- tabs[substr(tabs, 1, 2) != '__']

# sort tabs
tabs <- sort(tabs)
# store paths separately before we change names
tab_paths <- tabs
# remove ordering prefixes and prettify names
tabs <- gsub('([0-9])+(\\s|_)', '', tabs)
# also remove all underscores and replace with whitespace
tabs <- gsub('_', ' ', tabs)

modules <- list()
# loop thru tabs and populate modules
for(i in 1:length(tabs)) {
  tab_path <- tab_paths[i]
  
  # put modules for this tab in its own list
  modules[[i]] <- list()
  
  module_files <- list.files(file.path('modules', tab_path))
  for(j in 1:length(module_files)) {
    module_file <- module_files[j]
    
    # skip module if it begins with '__'
    if(substr(module_file, 1, 2) == '__') { next }
    
    # source module to load the init named list
    source(file.path('modules', tab_path, module_file))
    # load the module into the module list
    module_name <- gsub('.R', '', module_file)
    modules[[i]][[j]] <- init()
    modules[[i]][[j]][['id']] <- module_name
    
    # set module defaults
    
    # default type = 'plot'
    if(is.null(modules[[i]][[j]][['type']])) {
      modules[[i]][[j]][['type']] <- 'plot'
    }
  }
}


# to get custom panel heading colors for each tab,
config[['tab_colors']] <- rep(config[['tab_colors']], 10)

# load app.css into string
app_css <- paste(readLines(file.path('resources', 'app.css')), collapse='')
# load app.js into string
app_js <- paste(readLines(file.path('resources', 'app.js')), collapse='\n')

theme_base <- function(input=list(), show_legend=F) {
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
    axis.text.x = element_text(angle=45, hjust=1, margin=margin(r=45)),
    axis.title = element_text(size=title_font_size, face="bold"), 
    axis.text = element_text(size=axis_font_size),
    strip.text = element_text(size=facet_font_size)
  )
  if(!show_legend) {
    .theme <- .theme + theme(legend.position="none")
  }
  
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

merge_list <- function(a, b) {
  for(i in names(b)) {
    a[[i]] <- b[[i]]
  }
  return(a)
}
