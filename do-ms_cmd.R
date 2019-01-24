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

prnt <- function(message) {
  if(verbose) print(message)
}

# load config file --------------------------------------------------------

args <- commandArgs(trailingOnly=T)
# args <- 'config.yaml'

# validate command line args. only accept single YAML file
print(args)
if(class(args) == 'character' & length(args) == 1 & 
   file.exists(args) & substr(args, nchar(args)-4, nchar(args)) == '.yaml') {
  print('Valid config file')
} else {
  stop('Invalid command-line usage. Please input the path to one config file (YAML format, ending in .yaml)')
}

config <- read_yaml(args)

# validate config file ----------------------------------------------------

verbose <- config[['verbose']]
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
    
    prnt(.raw_files)
    
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
    data[[file$name]]$Raw.file <- factor(data[[file$name]]$Raw.file,
      levels=levels(data[[file$name]]$Raw.file), labels=file_levels)
  }
}

prnt('Finished renaming raw files')


# generate report ---------------------------------------------------------

prnt('Generating report...')

# first create fake "input" object.
# just copy the config object. customization options are on the top-level anyways
# and the other fields should just be ignored
input <- config


report <- paste(
  '---',
  'title: DO-MS Report',
  'date: "`r format(Sys.time(), \'Generated: %Y-%m-%d    %H:%M:%S\')`"',
  'output:',
  sep='\n')

if(config[['format']] == 'pdf') {
  
  report <- paste(report,
                  '  pdf_document:',
                  #'    header-includes:',
                  #'      - \\usepackage{xcolor}',
                  #'      - \\usepackage{framed}',
                  #'      - \\usepackage{color}',
                  '    fig_caption: false',
                  sep='\n')
  
} else if (config[['format']] == 'html') {
  
  report <- paste(report,
                  '  html_document:',
                  paste0('    theme: ', config[['theme']]),
                  #'    highlight: tango',
                  '    fig_caption: false',
                  '    df_print: paged',            
                  sep='\n')
}
  
# add figure options
report <- paste(report,
                paste0('    fig_width: ', config[['figure_width']]),
                paste0('    fig_height: ', config[['figure_height']]),
                paste0('    dev: ', config[['figure_format']]),
                sep='\n')
  
# add params
report <- paste(report,
                'params:',
                '  plots: NA',
                '---',
                '# {.tabset}',
                sep='\n')

prnt('Adding modules to report')

params <- list()
params[['plots']] <- list()
  
for(t in 1:length(tabs)) { local({
  .t <- t
  tab <- tabs[.t]
  
  report <<- paste(report,
                   paste0('## ', tab),
                   sep='\n')
  
  modules_in_tab <- modules[sapply(modules, function(m) { 
    gsub('([0-9])+(\\s|_)', '', m$tab) == tab 
  })]
  
  plots <- list()
  
  for(m in 1:length(modules_in_tab)) { local({
    .m <- m
    module <- modules_in_tab[[.m]]
    
    prnt(paste0('Adding module ', .m, ' (', module$id, ') from tab ', .t, ' (', tab, ')'))
    
    # create chunk name from module box title
    chunk_name <- module$id
    chunk_name <- gsub('\\s', '_', chunk_name)
    chunk_name <- gsub('[=-\\.]', '_', chunk_name)
    
    # if dynamic plot width is defined, then inject that into this
    # R-markdown chunk instead
    # because dynamic width is defined in pixels -- need to convert to inches
    
    # I know this is variable between screens and whatever, 
    # but set this as the default for now
    ppi <- 75
    
    dynamic_plot_width = ''
    if(!is.null(module$dynamic_width)) {
      num_files <- length(raw_files)
      dynamic_plot_width <- paste0(', fig.width=', ceiling(num_files * module$dynamic_width / ppi) + 1)
    }
    
    report <<- paste(report,
                     paste0('### ', module$boxTitle, ' {.plot-title}'),
                     '',
                     module$help,
                     '',
                     paste0('```{r ', chunk_name, ', echo=FALSE, warning = FALSE, message = FALSE', 
                            # put custom width definition. if it doesn't exist, this variable will be empty
                            dynamic_plot_width,
                            '}'),
                     'options( warn = -1 )',
                     paste0('params[["plots"]][[', .t, ']][[', .m, ']]'),
                     sep='\n')
    
    # because in shiny data is a reactive variable (that is called like a function)
    # and here data is just a static table, create a dummy function that just returns the data
    # that way we don't have to change any module code.
    plots[[.m]] <<- tryCatch(module$plotFunc(function() { data }, input),
                             error = function(e) {
                               # dummy plot
                               #qplot(0, 0)
                               paste0('Plot failed to render. Reason: ', e)
                             },
                             finally={}
    )
    
    report <<- paste(report, '```', '', sep='\n')
  }) } # end module loop
  
  params[['plots']][[.t]] <<- plots
  
  report <<- paste(report,
                   '',
                   sep='\n')
  
}) } # end tab loop
  

prnt('Writing temporary files')

tempReport <- file.path(tempdir(), "tempReport.Rmd")
write_file(x=report, path=tempReport, append=FALSE)

prnt('Rendering report (this may take a while)')

rmarkdown::render(tempReport, output_file = config[['output']],
                  params = params,
                  envir = new.env(parent = globalenv())
)

prnt(paste0('Report written to: ', config[['output']]))

prnt('Done!')
