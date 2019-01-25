#!/usr/bin/env Rscript

## DO-MS, but on the command-line
##
## this is just a bunch of code cribbed from server.R and other dependent scripts
## instead of relying on user input via. the UI, all options are specified by a 
## config file that roughly follows the same structure as the UI.
##
## maybe goes without saying, but we have to be vigilant about changes to the
## server and make sure this is mirrored in this script, especially when it
## comes to the behavior/rendering of modules. neglecting this will definitely
## break this script since it makes a lot of assumptions
##
## Run with Rscript binary. example:
##
## $ Rscript do-ms_cmd.R config_file.yaml
## Windows: $ Rscript.exe do-ms_cmd.R config_file.yaml
##
## check out an example configuration file at example/config_file.yaml

# load packages, modules, tabs, helper functions --------------------------

source('global.R')
source(file.path('server', 'generate_report.R'))

p_load(argparse)

# helper functions

prnt <- function(message) {
  if(verbose) print(message)
}


# build command-line arguments --------------------------------------------

parser <- ArgumentParser(description='Generate DO-MS report')

parser$add_argument('config_file', type='character',
                    help='Path to config file (YAML format). Required')

parser$add_argument('-v', '--verbose', action='store_true', default=T, 
                    help='Print detailed output (default: true)')
parser$add_argument('-i', '--input-folders', type='character', nargs='+',
                    help='One or more folder paths to generate report from')
parser$add_argument('-o', '--output', type='character',
                    help='Path to report file output. e.g., "/path/to/report.html"')
parser$add_argument('-f', '--input-file-types', type='character', nargs='+',
                    help='Names of MaxQuant text files to process. e.g., "summary evidence allPeptides"')

parser$add_argument('--include_exps', type='character',
                    help='Include raw files matching this regular expression. e.g., "SQC98[ABC]"')
parser$add_argument('--exclude_exps', type='character',
                    help='Exclude raw files matching this regular expression. e.g., "SQC98[ABC]"')
parser$add_argument('--exp_names', type='character', nargs='+',
                    help='Rename raw files with short names. e.g., "Control 2X 4X 10X"')
parser$add_argument('--pep_threshold', type='double',
                    help='PEP threshold for identified peptides, remove all below this threshold. e.g., "0.01"')

# parser$print_help()
args <- parser$parse_args()

# load config file --------------------------------------------------------

config <- read_yaml(args$config_file)

# override config file items with command-line items, if they exist
if(!is.null(args$input_folders)) config$input_folders <- args$input_folders
if(!is.null(args$output)) config$output <- args$output
if(!is.null(args$input_file_types)) config$input_files <- args$input_file_types
if(!is.null(args$include_exps)) config$include_files <- args$include_exps
if(!is.null(args$exclude_exps)) config$exclude_files <- args$exclude_exps
if(!is.null(args$exp_names)) config$exp_names <- args$exp_names
if(!is.null(args$pep_threshold)) config$pep_thresh <- args$pep_threshold

# validate config file ----------------------------------------------------

verbose <- args$verbose
if(is.null(verbose)) verbose <- F # if not specified, set to false

input_folders <- config[['input_folders']]
if(is.null(input_folders)) stop('"input_folders" missing. Please provide list of folders to import and analyze')
if(length(input_folders) == 0) stop('No input folders specified in the "input_folders" list. Please provide list of folders to import and analyze')
if(class(input_folders) != 'character') stop('Folder paths in "input_folders" list must be strings')

load_input_files <- config[['input_files']]
if(is.null(load_input_files)) stop('"input_files" missing. Please provide list of files to load from each folder')
if(length(load_input_files) == 0) stop('No input files specified in the "input_files" list. Please provide list of files to load from each folder')
if(class(load_input_files) != 'character') stop('Input file list in "input_files" list must be strings')

load_misc_input_files <- config[['misc_input_files']]
if(is.null(load_misc_input_files)) load_misc_input_files <- c() # okay if empty, just set to empty vector for now
# if(class(misc_input_files) != 'character') stop('Misc. input file list in "misc_input_files" must be strings')

## Filters

# im lazy and don't want to write validators for all of these filters.
# i'll just trust the user to not screw this up.

# load folders ------------------------------------------------------------

prnt('Loading folders')

# create the data list
data <- list()

# loop thru input files
for(f in load_input_files) {
  # get the input file object as defined in global.R
  file <- input_files[[f]]
  
  # if it isn't defined, break out
  if(is.null(file)) {
    stop(paste0('File "', f, '" is not defined in the input_files list in global.R. Please check spelling in the config file or add this file type to the input_files list.'))
  }
  
  prnt(paste0('Loading file: ', file[['file']]))
  
  # loop thru folders
  for(folder in input_folders) {
  
    prnt(paste0('Loading file: ', file[['file']], ' from: ', folder))
    
    # if file doesn't exist, skip
    if(!file.exists(file.path(folder, file[['file']]))) {
      stop(paste0(file.path(folder, file[['file']]), ' does not exist'))
    }
    
    # read data into temporary data.frame
    .dat <- as.data.frame(read_tsv(file=file.path(folder, file[['file']])))
    
    # rename columns (replace whitespace or special characters with '.')
    colnames(.dat) <- gsub('\\s|\\(|\\)|\\/|\\[|\\]', '.', colnames(.dat))
    # coerce raw file names to a factor
    if('Raw.file' %in% colnames(.dat)) {
      .dat$Raw.file <- factor(.dat$Raw.file)
    }
    
    # if field is not initialized yet, set field
    if(is.null(data[[file$name]])) {
      data[[file$name]] <- .dat
    }
    # otherwise, append to existing data.frame
    else {
      
      # before we append, need to make sure that columns match up
      # if not, then take the intersection of the columns (only common columns)
      cols_prev <- colnames(data[[file$name]])
      cols_new  <- colnames(.dat)
      common_cols <- intersect(cols_prev, cols_new)
      
      # merge dataframes, with only common columns between the two frames
      data[[file$name]] <- rbind(data[[file$name]][,common_cols], .dat[,common_cols])
    }
  }
}

prnt('Finished loading folders')


# load misc files ---------------------------------------------------------

# loop thru all misc input files and add it to the data list
if(length(load_misc_input_files) > 0) {
for(i in 1:length(load_misc_input_files)) {
  
  name <- names(load_misc_input_files)[i]
  path <- load_misc_input_files[[i]]
  
  file <- misc_input_files[[name]]
  
  # if it isn't defined, break out
  if(is.null(file)) {
    stop(paste0('File "', f, '" is not defined in the misc_input_files list in global.R. Please check spelling in the config file or add this file type to the misc_input_files list.'))
  }
  
  prnt(paste0('Loading misc file: ', name))
  
  # read in as data frame (need to convert from tibble)
  data[[name]] <- as.data.frame(read_tsv(file=path))
  # rename columns (replace whitespace or special characters with '.')
  colnames(data[[name]]) <- gsub('\\s|\\(|\\)|\\/|\\[|\\]', '.', 
                                       colnames(data[[name]]))
  # coerce raw file names to a factor
  if('Raw.file' %in% colnames(data[[name]])) {
    data[[name]]$Raw.file <- factor(data[[name]]$Raw.file)
  }
}
  prnt('Finished loading misc input files')
}

# filter data -------------------------------------------------------------

prnt('Begin filtering data')

for(f in load_input_files) {
  file <- input_files[[f]]
  
  prnt(paste0('Filtering data for ', file$name))
  
  # for each file, check if it has a raw file column
  if('Raw.file' %in% colnames(data[[file$name]])) {
    
    # rename the levels of this file
    # data[[file$name]]$Raw.file <- factor(data[[file$name]]$Raw.file,
    #   levels=levels(data[[file$name]]$Raw.file), labels=file_levels())
    
    # Filter by raw file name, by matching against regular expressions in config_file
    
    if(!is.null(config[['include_files']])) {
      prnt(paste0('Filtering for raw files that match expression "', config[['include_files']], '"'))
      data[[file$name]] <- data[[file$name]] %>%
        filter(grepl(config[['include_files']], Raw.file))
    }
    
    if(!is.null(config[['exclude_files']])) {
      prnt(paste0('Filtering out raw files that match expression "', config[['exclude_files']], '"'))
      data[[file$name]] <- data[[file$name]] %>%
        filter(!grepl(config[['exclude_files']], Raw.file))
    }
    
  }
  
  ## Filter observations
  
  # Filter out decoys and contaminants, if the leading razor protein column exists
  if('Leading.razor.protein' %in% colnames(data[[file$name]])) {
    
    if(!is.null(config[['remove_decoy']])) {
      prnt(paste0('Filtering out decoy hits by matching "', config[['remove_decoy']], '"'))
      data[[file$name]] <- data[[file$name]] %>% 
        filter(!grepl(config[['remove_decoy']], Leading.razor.protein))
    }
    
    if(!is.null(config[['remove_contam']])) {
      prnt(paste0('Filtering out contaminant hits by matching "', config[['remove_contam']], '"'))
      data[[file$name]] <- data[[file$name]] %>% 
        filter(!grepl(config[['remove_contam']], Leading.razor.protein))
    }
      
  }
  
  # Filter by PEP
  if('PEP' %in% colnames(data[[file$name]])) {
    prnt(paste0('Filtering by PEP, with threshold ', config[['pep_thresh']]))
    data[[file$name]] <- data[[file$name]] %>%
      filter(PEP < config[['pep_thresh']])
  }
  
  ## More filters, like PIF? Intensity?
}

prnt('Finished filtering data')

# experiment name manipulation --------------------------------------------

raw_files <- c()

for(f in load_input_files) {
  file <- input_files[[f]]
  
  # for each file, check if it has a raw file column
  if('Raw.file' %in% colnames(data[[file$name]])) {
    
    # make a copy of the raw file column
    data[[file$name]]$Raw.file.orig <- data[[file$name]]$Raw.file
    
    # drop unused levels, if they've been filtered out
    data[[file$name]]$Raw.file <- droplevels(data[[file$name]]$Raw.file)
    
    # get the raw files for this input file
    .raw_files <- levels(data[[file$name]]$Raw.file)
    
    for(raw_file in .raw_files) {
      # if the raw file is not in the list of raw files, then add it
      if(!raw_file %in% raw_files) {
        raw_files <- c(raw_files, raw_file)
      }
    }
    
  }
}

# sort the raw files
raw_files <- sort(raw_files)

  
level_prefixes <- paste0('Exp ', seq(1, 100))
# create the nickname vector
file_levels <- level_prefixes[1:length(raw_files)]
  
named_exps <- config[['exp_names']]
if(!is.null(named_exps) & length(named_exps) > 0) {
  if(length(named_exps) < length(file_levels)) {
    file_levels[1:length(named_exps)] <- named_exps
  } else if(length(named_exps) > length(file_levels)) {
    file_levels <- named_exps[1:length(file_levels)]
  } else {
    # same length
    file_levels <- named_exps
  }
}
  
# ensure there are no duplicate names
# if so, then append a suffix to duplicate names to prevent refactoring errors

# only do this if we have more than one experiment
if(length(raw_files) > 1) {
    
  for(i in 1:(length(file_levels)-1)) {
    duplicate_counter <- 0
    for(j in (i+1):length(file_levels)) {
      if(file_levels[i] == file_levels[j]) {
        # if j is a duplicate, append the corresponding duplicate number and increment
        file_levels[j] <- paste0(file_levels[j], '_', duplicate_counter + 2)
        duplicate_counter <- duplicate_counter + 1
      }
    }
    # if there were any duplicates, change .file_levels[i]
    if(duplicate_counter > 0) {
      file_levels[i] <- paste0(file_levels[i], '_1')
    }
  }
  
}


# re-filter data ----------------------------------------------------------

prnt('Renaming raw files...')

for(f in load_input_files) {
  file <- input_files[[f]]
  
  # for each file, check if it has a raw file column
  if('Raw.file' %in% colnames(data[[file$name]])) {
    
    # rename the levels of this file
    .levels <- levels(data[[file$name]]$Raw.file)
    .labels <- file_levels
    
    # if this file has a subset of raw files
    # then take the same subset of the labels vector
    if(length(.labels) > length(.levels)) {
      .labels <- .labels[1:length(.levels)]
    }
    
    data[[file$name]]$Raw.file <- factor(data[[file$name]]$Raw.file,
                                         levels=.levels, labels=.labels)
  }
}

prnt('Finished renaming raw files')


# generate report ---------------------------------------------------------

prnt('Generating report...')

# first create fake "input" object.
# just copy the config object. customization options are on the top-level anyways
# and the other fields should just be ignored
input <- config

# wrap data in a function, since down the line data is called like a function
# as modules are expecting a reactive object not static data
f_data <- function() { data }

generate_report(input, f_data, raw_files, config[['output']], progress_bar=FALSE)

prnt(paste0('Report written to: ', config[['output']]))

prnt('Done!')
