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

# set CRAN mirror

r = getOption("repos")

if(is.null(r['CRAN'])) {
  r['CRAN'] = "http://cran.us.r-project.org"
  options(repos = r)
}

# load packages, modules, tabs, helper functions --------------------------

source('global.R')
source(file.path('server', 'generate_report.R'))

# command-line specific packages
p_load(argparse)

# helper functions
prnt <- function(message) {
  if(verbose) print(message)
}


# build command-line arguments --------------------------------------------

# allow users to source this R script instead of forcing to run from command-line
# so that they can integrate this into their own R workflows directly
if(!exists('.config')) {
  parser <- ArgumentParser(description='Generate DO-MS report')
  
  parser$add_argument('config_file', type='character',
                      help='Path to config file (YAML format). Required')
  
  parser$add_argument('-v', '--verbose', action='store_true', default=T, 
                      help='Print detailed output (default: true)')
  parser$add_argument('-i', '--input-folders', type='character', nargs='+',
                      help='One or more folder paths to generate report from')
  parser$add_argument('-o', '--output', type='character',
                      help='Path to report file output. e.g., "/path/to/report.html"')
  parser$add_argument('-f', '--load-input-files', type='character', nargs='+',
                      help='Names of MaxQuant text files to process. e.g., "summary evidence allPeptides"')
  
  parser$add_argument('--include-files', type='character',
                      help='Include raw files matching this regular expression. e.g., "SQC98[ABC]"')
  parser$add_argument('--exclude-files', type='character',
                      help='Exclude raw files matching this regular expression. e.g., "SQC98[ABC]"')
  parser$add_argument('--exp_names', type='character', nargs='+',
                      help='Rename raw files with short names. e.g., "Control 2X 4X 10X"')
  parser$add_argument('--exp_order', type='integer', nargs='+',
                      help='Reorder raw files in plots. Files are by default ordered alphabetically, so indices refer to the original order. For example, to get A B C D --> D A C B, put "4 1 3 2"')
  parser$add_argument('--pep_thresh', type='double',
                      help='PEP threshold for identified peptides, remove all below this threshold. e.g., "0.01"')
  
  # parser$print_help()
  args <- parser$parse_args()
  
  # merge args with config YAML file
  config <- merge_list(config, read_yaml(args$config_file))
  
  # remove entries from args that are null
  args <- args[sapply(args, function(i) { !is.null(i) })]
  # override with command-line args
  config <- merge_list(config, args)
  
} else {
  # fake command-line arguments with an empty list
  args <- list()
  config <- merge_list(config, .config)
}


# validate config file ----------------------------------------------------

verbose <- args$verbose
if(is.null(verbose)) verbose <- F # if not specified, set to false

input_folders <- config[['input_folders']]
if(is.null(input_folders)) stop('"input_folders" missing. Please provide list of folders to import and analyze')
if(length(input_folders) == 0) stop('No input folders specified in the "input_folders" list. Please provide list of folders to import and analyze')
if(class(input_folders) != 'character') stop('Folder paths in "input_folders" list must be strings')

prnt(paste0('Loading input folders: ', paste(input_folders, collapse=', ')))

# make sure all folders exist
for(folder in input_folders) {
  if(!dir.exists(folder)) {
    stop(paste0('Folder \"', folder, '\" does not exist. Please fix the folder path or remove it from the list of input folders.'))
  }
}

load_input_files <- config[['load_input_files']]
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
for(f in config[['load_input_files']]) {
  # get the input file object as defined in global.R
  file <- config[['input_files']][[f]]
  
  # if it isn't defined, break out
  if(is.null(file)) {
    stop(paste0('File "', f, '" is not defined in the input_files list in global.R. Please check spelling in the config file or add this file type to the input_files list.'))
  }
  
  prnt(paste0('Loading file: ', file[['file']]))
  
  # loop thru folders
  for(folder in config[['input_folders']]) {
  
    prnt(paste0('Loading file: ', file[['file']], ' from: ', folder))
    
    # if file doesn't exist, skip
    if(!file.exists(file.path(folder, file[['file']]))) {
      prnt(paste0(file.path(folder, file[['file']]), ' does not exist'))
      next
    }
    
    # read data into temporary data.frame
    .dat <- suppressWarnings(
      as.data.frame(read_tsv(file=file.path(folder, file[['file']]), progress=FALSE, col_types = cols(), guess_max=1e5))
    )
    
    # rename columns (replace whitespace or special characters with '.')
    .dat <- .dat %>% dplyr::rename_all(make.names)
    
    # apply column aliases
    .dat <- apply_aliases(.dat)
    
    if('Raw.file' %in% colnames(.dat)) {
      # Remove any rows where "Total" is a raw file (e.g., summary.txt)
      .dat <- .dat %>% filter(!Raw.file == 'Total')
      
      # coerce raw file names to a factor
      .dat$Raw.file <- factor(.dat$Raw.file)
    }
    
    # Custom behavior for parameters.txt
    if(file$name == 'parameters') {
      # store folder name/path as a value in parameters.txt
      .dat <- rbind(c('Folder Name', basename(folder)), c('Folder Path', folder), .dat, stringsAsFactors=FALSE)
      # rename value column to folder name as well
      colnames(.dat)[2] <- basename(folder)
    } else {
      # store folder name and path
      .dat$Folder.Name <- basename(folder)
      .dat$Folder.Path <- folder
    }
    
    # if field is not initialized yet or is empty, set field
    if(is.null(data[[file$name]])) {
      data[[file$name]] <- .dat
    }
    # if parameters.txt file, then cbind instead of rbind
    else if(file$name == 'parameters') {
      data[[file$name]] <- cbind(data[[file$name]], .dat[,-1])
      # rename column to folder name
      colnames(data[[file$name]])[ncol(data[[file$name]])] <- basename(folder)
    }
    # otherwise, append to existing data.frame
    else {
      
      # before we append, need to make sure that columns match up
      # if not, then take the intersection of the columns (only common columns)
      cols_prev <- colnames(data[[file$name]])
      cols_new  <- colnames(.dat)
      common_cols <- intersect(cols_prev, cols_new)
      
      # print warning about columns being lost
      diff_cols <- setdiff(cols_prev, cols_new)
      if(length(diff_cols) > 0) {
        prnt(paste0(length(diff_cols), ' columns in file ', file$name, ' are exclusive to some analyses but not others. Eliminating the different columns: ', paste(diff_cols, collapse=', ')))
      }
      
      # merge dataframes, with only common columns between the two frames
      data[[file$name]] <- rbind(data[[file$name]][,common_cols], .dat[,common_cols])
    }
  }
}

prnt('Finished loading folders')

# sometimes all folders might exist, but none of the specified files are in them
# if all entries of the data list are empty, then let's crash out here
if(all(
  sapply(names(data), function(x) { is.null(data[[x]]) }) 
)) {
  stop('None of the folders in the input list have the specified output files. Please make sure that all folders provided have search engine output files.')
}


# load misc files ---------------------------------------------------------

# loop thru all misc input files and add it to the data list
if(length(config[['load_misc_input_files']]) > 0) {
for(i in 1:length(config[['load_misc_input_files']])) {
  
  name <- names(config[['load_misc_input_files']])[i]
  path <- config[['load_misc_input_files']][[i]]
  
  file <- config[['misc_input_files']][[name]]
  
  # if it isn't defined, break out
  if(is.null(file)) {
    stop(paste0('File "', f, '" is not defined in the misc_input_files list in global.R. Please check spelling in the config file or add this file type to the misc_input_files list.'))
  }
  
  prnt(paste0('Loading misc file: ', name))
  
  # read in as data frame (need to convert from tibble)
  data[[name]] <- as.data.frame(read_tsv(file=path, col_types = cols()))
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

for(f in config[['load_input_files']]) {
  file <- config[['input_files']][[f]]
  
  prnt(paste0('Filtering data for ', file$name))
  
  # for each file, check if it has a raw file column
  if('Raw.file' %in% colnames(data[[file$name]])) {
    
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
  
  # Filter by PIF
  if('PIF' %in% colnames(data[[file$name]])) {
    prnt(paste0('Filtering by PIF, with threshold ', config[['pif_thresh']]))
    data[[file$name]] <- data[[file$name]] %>%
      filter(PIF > config[['pif_thresh']])
  }
  
  ## More filters, like PIF? Intensity?
}

prnt('Finished filtering data')

# experiment name manipulation --------------------------------------------

raw_files <- c()

for(f in config[['load_input_files']]) {
  file <- config[['input_files']][[f]]
  
  # don't do this with MaxQuant's summary.txt file since it has weird behavior
  if(file$name == 'summary') { next; }
  
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
        
        # store the folder it came from as the name of the raw file
        names(raw_file) <- first(unique(
          data[[file$name]] %>% filter(`Raw.file` == raw_file) %>% pull(Folder.Name)
        ))
        
        raw_files <- c(raw_files, raw_file)
      }
    }
    
  }
}

# sort the raw files
raw_files <- sort(raw_files)



  
# load naming format
file_levels <- rep(config[['exp_name_format']], length(raw_files))

# replace flags in the format
# replacements have to be character vectors with same length as raw file vector

# replace %i with the index
file_levels <- str_replace(file_levels, '\\%i', as.character(seq(1, length(raw_files))))

# replace %f with the folder name
# folder name is stored as the names of the raw files vector
file_levels <- str_replace(file_levels, '\\%f', names(raw_files))


# replace %e with the raw file name
file_levels <- str_replace(file_levels, '\\%e', raw_files)
print(file_levels)

print(config[['exp_name_pattern']])

# apply custom string extraction expression to file levels
if(!is.null(config[['exp_name_pattern']])) {
  file_levels <- str_extract(file_levels, config[['exp_name_pattern']])
  # if string extraction failed, then will return NA. set NAs to "default"
  file_levels[is.na(file_levels)] <- 'default'
}

print(file_levels)

# apply custom names, as defined in the "exp_names" config field
if(!is.null(config[['exp_names']]) & length(config[['exp_names']]) > 0) {
  file_levels[1:length(config[['exp_names']])] <- config[['exp_names']]
}
print(file_levels)
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
    # if there were any duplicates, change file_levels[i]
    if(duplicate_counter > 0) {
      file_levels[i] <- paste0(file_levels[i], '_1')
    }
  }
}

prnt('File labels: ')
prnt(paste(file_levels, collapse=', '))

# re-filter data ----------------------------------------------------------

prnt('Renaming raw files...')

for(f in config[['load_input_files']]) {
  file <- config[['input_files']][[f]]
  
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
    
    # apply re-ordering
    .file_order <- config[['exp_order']]
    if(is.null(.file_order)) {
      .file_order <- c()
    }
    
    if(length(unique(.file_order)) == length(.levels) & min(.file_order) == 1 & max(.file_order) == length(.levels)) {
      .levels <- .levels[.file_order]
      .labels <- .labels[.file_order]
    }
    
    # recalculate file levels
    data[[file$name]]$Raw.file <- factor(data[[file$name]]$Raw.file,
                                         levels=.levels, labels=.labels)
    
    # drop filtered-out or unused levels
    droplevels(data[[file$name]]$Raw.file, reorder=FALSE)
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

# prnt(paste0('Report written to: ', config[['output']]))

prnt('Done!')
