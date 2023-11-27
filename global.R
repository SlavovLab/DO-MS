version <- '2.0.8'

# check R version. required R >= 3.5.0 & R <= 4.0.2
if(as.numeric(R.Version()$major) < 4) {
  stop('R Version >= 4.0.0  and <= 4.0.2 required. Download R 4.0.2 from the CRAN page: https://cran.r-project.org/')
}

# check R version. required R <= 4.0.2
#if(as.numeric(R.Version()$minor) > 0.2) {
#  stop('R Version <= 4.0.2 required. Download R 4.0.2 from the CRAN page: https://cran.r-project.org/')
#}

# first, get pacman
if(!'pacman' %in% installed.packages()[,'Package']) {
  install.packages('pacman')
}
library(pacman)

# install/load dependencies
p_load(shiny, shinyWidgets, shinydashboard, dplyr, tidyr, ggplot2, lattice, knitr, tibble,
      reshape2, readr, rmarkdown, stats, DT, stringr, yaml, viridisLite, ggpubr, MASS, viridis)

# look for pandoc - moved from start_server.R to gloabl to make sure pandoc is always available
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
os <- get_os()

pandoc_osx <- "/Applications/RStudio.app/Contents/MacOS/quarto/bin/tools"
pandoc_windows <- "C:\\Program Files\\RStudio\\bin\\pandoc"
pandoc_linux <- "/usr/lib/rstudio/bin/pandoc"

# try and predict pandoc directories
if(os == 'mac' & file.exists(pandoc_osx)) {
  Sys.setenv(RSTUDIO_PANDOC=pandoc_osx)
} else if (os == 'win' & file.exists(pandoc_windows)) {
  Sys.setenv(RSTUDIO_PANDOC=pandoc_windows)
} else if (os == 'unix' & file.exists(pandoc_linux)) {
  Sys.setenv(RSTUDIO_PANDOC=pandoc_linux)
} else {
  print('pandoc could not be found in default directories. If it is not available on the system PATH then PDF report generation will fail.')
}

print('Checking online for latest version of DO-MS...')
# check application version
# grab release tags from github and compare them to the local version
tryCatch({
  # read tags from the GitHub API
  tags_conn <- url('https://api.github.com/repos/SlavovLab/DO-MS/tags', open='r')
  release_tags <- suppressWarnings(read_yaml(tags_conn))
  close(tags_conn) 
  
  # loop thru release tags and find highest version
  # also remove 'v' from tag version names
  tag_versions <- sapply(release_tags, function(tag) { substring(tag$name, 2) })
  
  # get the latest version from the one that would be sorted last
  #latest_version <- rev(sort(tag_versions))[1]
  latest_version <- (tag_versions)[1]
  
  # do string order comparison to determine where the current version falls
  if(version == latest_version) {
    print(paste0('You are on the latest version of DO-MS: ', version))
  } else if (version < latest_version) {
    print(paste0('An update to DO-MS has been released: ', latest_version, '. You can download the latest version from our GitHub page: https://github.com/SlavovLab/DO-MS/releases.'))
    print(paste0('Your version: ', version, ' << latest version: ', latest_version))
  } else {
    # not supposed to happen
    print('Current version ahead of latest release. Ignoring versioning...')
  }
  
}, error=function(e) {
  print('Error fetching versions from GitHub. This will fail if you are not connected to the internet. Ignoring versioning...')
}, finally={
  
})

# load application settings
config <- read_yaml('settings.yaml')

do_ms_mode <- config[['do_ms_mode']]

# check if settings.yaml contains config for do_ms_mode
if (do_ms_mode %in% names(config)){
  print(paste('DO-MS mode:',do_ms_mode, 'found in settings.yaml'))
  
} else {
  
  stop(paste('No config section for DO-MS mode',do_ms_mode, 'found in settings.yaml'))
}

# Add all config attributes found in the do_ms_mode specific section to the base config level.
for (i in 1:length(names(config[[do_ms_mode]]))){
  current_name <- names(config[[do_ms_mode]])[i]
  
  config[[current_name]] <- config[[do_ms_mode]][[current_name]]
}

#DO-MS mode specific module path
module_path <- file.path('modules', do_ms_mode)

# load tabs first
tabs <- list.dirs(module_path, recursive=F, full.names=F)
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
# loop thru tabs and populate modulesapply_aliases
for(i in 1:length(tabs)) {
  tab_path <- tab_paths[i]
  
  # put modules for this tab in its own list
  modules[[i]] <- list()
  
  module_files <- list.files(file.path(module_path, tab_path))
  for(j in 1:length(module_files)) {
    module_file <- module_files[j]
    
    # skip module if it begins with '__'
    if(substr(module_file, 1, 2) == '__') { next }
    
    # source module to load the init named list
    source(file.path(module_path, tab_path, module_file))
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

# load modifications
if ("modifications" %in% names(config)){
  
  if (length(config[['modifications']]) > 0){
    
    real_mod_vec <- c(F, F)
    name_vec <- c("All", "Unmodified")
    unimod_vec <- c("all", "unmodified")

    for(i in 1:length(config[['modifications']])){
      name_vec <- c(name_vec, config[['modifications']][[i]]$name)
      unimod_vec <- c(unimod_vec, config[['modifications']][[i]]$unimod)
      real_mod_vec <- c(real_mod_vec, T)
    }
    
  } else {
    name_vec <- c("All")
    unimod_vec <- c("all")
    real_mod_vec <- c(F)
  }

} else {
  name_vec <- c("All")
  unimod_vec <- c("all")
  real_mod_vec <- c(F)
}

config[['modification_list']] <- data.frame(name = name_vec,
                                            unimod = unimod_vec,
                                            real_mod = real_mod_vec,
                                            stringsAsFactors = FALSE)


# load app.css into string
app_css <- paste(readLines(file.path('resources', 'app.css')), collapse='')
# load app.js into string
app_js <- paste(readLines(file.path('resources', 'app.js')), collapse='\n')

substrRight <- function(x){
  substr(x, 1, nchar(x)-1)
}

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

theme_diann <- function(input=list(), show_legend=F) {
  
  # default values
  axis_font_size <- ifelse(is.null(input[['figure_axis_font_size']]), 
                           10, input[['figure_axis_font_size']])
  title_font_size <- ifelse(is.null(input[['figure_title_font_size']]),
                            12, input[['figure_title_font_size']])
  facet_font_size <- ifelse(is.null(input[['figure_facet_font_size']]),
                            10, input[['figure_facet_font_size']])
  
  show_grid <- ifelse(is.null(input[['figure_show_grid']]),
                      TRUE, input[['figure_show_grid']])
  
  .theme <- theme(text = element_text(face="bold", size=12, colour = "grey40"),
    panel.grid.major = element_line(colour = "grey80", size = 0.4),
    axis.ticks = element_line(colour = "grey80", size = 0.4),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor = element_blank(),
    #panel.background = element_rect(fill = NA),
    axis.text = element_text(colour = "grey40", face = "bold", size = axis_font_size),
    axis.text.x = element_text(angle=45, hjust=1, margin=margin(r=45)),
    axis.line = element_blank(),
    axis.title=element_text(size=title_font_size, colour = "grey20"),
    strip.background = element_rect(colour = NA, fill = "grey90"),
    strip.text = element_text(colour = "grey20", face = "bold", size = facet_font_size),
    legend.text = element_text(colour = "grey40", face = "bold", size = 12),
    legend.title = element_text(colour = "grey40", face = "bold", size = 12),
    panel.background = element_rect(fill="white", colour = "white")
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
  
  .theme <- .theme + theme(text = element_text(face="bold", size=12, colour = "grey40"),
                          panel.grid.major = element_line(colour = "grey80", size = 0.4),
                          axis.ticks = element_line(colour = "grey80", size = 0.4),
                          panel.grid.minor.x = element_blank(),
                          panel.grid.minor = element_blank(),
                          #panel.background = element_rect(fill = NA),
                          axis.text = element_text(colour = "grey40", face = "bold", size = axis_font_size),
                          axis.line = element_blank(),
                          axis.title=element_text(size=title_font_size, colour = "grey20"),
                          strip.background = element_rect(colour = NA, fill = "grey90"),
                          strip.text.x = element_text(colour = "grey20", face = "bold", size = facet_font_size),
                          legend.text = element_text(colour = "grey40", face = "bold", size = 12),
                          legend.title = element_text(colour = "grey40", face = "bold", size = 12))
  
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

# load column aliases
col_aliases <- config[['aliases']]

apply_aliases <- function(dataframe) {
  
  for(colname in names(col_aliases)) {
    # if the column exists in the dataframe, no extra work needed
    if(colname %in% colnames(dataframe)) next
    
    # get list of aliases for this column from the col_aliases file
    aliases <- col_aliases[[colname]]
    
    # if no aliases found from the col_alises file, fail loudly
    if(is.null(aliases)) {
      stop('Attempted to fetch aliases for column \"', colname, '\" but no aliases for this column name are defined in col_aliases.yaml. Please check your spelling or confirm that the col_aliases.yaml file does specify aliases for \"', colname, '\"')
    }
    
    # find aliases in the dataframe columns. if found, rename the column
    for(.alias in aliases) {
      if(.alias %in% colnames(dataframe)) {
        dataframe <- dataframe %>% dplyr::rename_at(.alias, funs(paste0(colname)))
      }
    }
    
    # if we reach this point, none of the aliases matched
    # TODO: something? here?? print a warning?
  }
  
  # return the modified dataframe
  return(dataframe)
  
}


# sanitize text for display
# very important for outputs like LaTeX
sanitize_text_output <- function(text) {
  
  # if its a factor, then turn it into a string
  if(class(text) == 'factor') {
    text <- as.character(text)
  }
  
  # only operate on strings
  if(class(text) != 'character') {
    return(text)
  }
  
  # replace "\\" with "/" - for LaTeX
  text <- gsub('\\\\', '/', text)
  
  # no tildas allowed
  text <- gsub('\\~', '', text)
  
  # return
  text
}

print("global.R")

# create a new column with the chemical label
map_label <- function(sequence, labelsdata){
  
  label = ''
  
  for (i in 1:length(labelsdata)){
    current_label <- labelsdata[[i]]
    
    if (grepl( current_label, sequence, fixed = TRUE)){
      label <- current_label
    }
    
  }
  return(label)
}

count_pattern <- function(string, pattern){
  occurence <- str_count(string, pattern = pattern)
  if (occurence > 0){
    return(pattern)
  } else {
    return("Unmodified")
  }
}

#returns the seperator for a path
get_seperator <- function(instring){
  forward_count <- str_count(instring, "/")
  backward_count <- str_count(instring, "\\\\")
  
  seperator <-  if (forward_count > backward_count) "/" else "\\\\"
  return(seperator)
}
  
# accepts an MS1.extracted style matrix dataframe and returns an report.tsv style dataframe
# conversion of the matrix based format to a row based format allows to use the same satatistics as with the report.tsv
ms1_extracted_to_report <- function(.input_df){
  
  # for debugging
  #.input_df <- as.data.frame(read_tsv(file='G:/.shortcut-targets-by-id/1uQ4exoKlaZAGnOG1iCJPzYN3ooYYZB7g/MS/Users/GW/test_data/diann_v_16_d/Report.pr_matrix_channels_ms1_extracted.tsv',guess_max=1e5))
  
  #.input_df <- as.data.frame(read_tsv(file='/Volumes/GoogleDrive/.shortcut-targets-by-id/1uQ4exoKlaZAGnOG1iCJPzYN3ooYYZB7g/MS/Users/GW/test_data/diann_v_16_raw/report.pr_matrix_channels_ms1_extracted.tsv.txt',guess_max=1e5))
  
  # get slash direction. Last element is always path
  seperator <- get_seperator(tail(colnames(.input_df), n=1))

  # get a vector of all column names which do not contain a slash
  slash_occurences <- str_count(colnames(.input_df), seperator)
  last_non_path_index <- max(which(slash_occurences == 0))
  dont_pivot <- colnames(.input_df)[0:last_non_path_index]
  
  print(dont_pivot)
  .input_df <- .input_df %>% pivot_longer(cols = !all_of(dont_pivot), names_to='File.Name.Conv', values_to = "val")
  print("done")
  basename_filename <- matrix(unlist(strsplit(.input_df$File.Name.Conv, paste0(seperator,"\\s*(?=[^",seperator,"]+$)"), perl=TRUE)), ncol=2,byrow=TRUE)
  
  .input_df <- .input_df %>% dplyr::mutate(MS1.Name = basename_filename[,2])
  
  
  
  # Old DIA-NN versions contain a Q.Value column in the MS1 extracted.
  # New versions have a .Quality column
  # checking the occurrences of both strings is used to determine the verson.
  qval_count <- length(grep(".QValue", .input_df$MS1.Name, fixed=TRUE))
  quality_count <- length(grep(".Quality", .input_df$MS1.Name, fixed=TRUE))
  
  if (qval_count > quality_count){
    ms1_extracted_mode = '.QValue'
  } else {
    ms1_extracted_mode = '.Quality'
  }
  print(paste('Ms1_extracted mode:', ms1_extracted_mode))
  
  # Match all rows which contain .QValue at the end of the file name
  .input_df <- .input_df %>% dplyr::mutate(Q = grepl(ms1_extracted_mode, MS1.Name, fixed=TRUE))
  
  
  identifier_comp <- matrix(unlist(strsplit(.input_df$MS1.Name, "-\\s*(?=[^-]+$)", perl=TRUE)), ncol=2,byrow=TRUE)
  
  # File.Name eLK002.raw
  .input_df$File.Name <- identifier_comp[,1]
  
  # Raw.file eLK002.raw
  .input_df$Raw.File <- matrix(unlist(strsplit(.input_df$File.Name, "\\.\\s*(?=[^\\.]+$)", perl=TRUE)), ncol=2,byrow=TRUE)[,1]
  
  .input_df$Channel <- strtoi(str_extract(identifier_comp[,2], '[0-9]+'))
  
  # create unique identifier for merging Q values to intensities
  .input_df <- .input_df %>% 
    dplyr::mutate(Identifier = paste(Raw.File, Channel, Precursor.Id, sep='_'))
  
  # create seperate dataframes for Q-values and intensities
  .input_df.val <- .input_df %>% 
    dplyr::filter(!Q) %>% 
    dplyr::mutate(val = replace_na(val, 0)) %>% 
    dplyr::rename(Ms1.Area = val)
  
  q_default <- if (ms1_extracted_mode == '.Qvalue') 1 else 0
  
  .input_df.Q <- .input_df %>% 
    dplyr::filter(Q) %>%
    dplyr::select(Identifier, val) %>%
    dplyr::mutate(val = replace_na(val, q_default)) %>% 
    dplyr::rename(Quality = val)
  
  # Append q-value by joining the datasets
  .input_df <- .input_df.val %>% 
    inner_join(.input_df.Q, by='Identifier')
  
  # create Precursor.Id with channel information
  # create Modified.Sequence with channel information
  # remove temporary columns
  .input_df <- .input_df %>% 
    dplyr::mutate(Precursor.Id = str_replace_all(Precursor.Id, "(?<=\\()mTRAQ(?=\\))", paste0('mTRAQ',Channel))) %>% 
    dplyr::mutate(Modified.Sequence= str_replace_all(Modified.Sequence, "(?<=\\()mTRAQ(?=\\))", paste0('mTRAQ',Channel))) %>% 
    dplyr::select(-c('Q','File.Name.Conv','MS1.Name','Channel'))
  
  return(.input_df)
}

# Translates new (post 1.8.1 b12) channels to the old format
# Old Channels were denoted like (mTRAQ0) new ones are denoted like (mTRAQ-K-0)
translate_diann_channel_format <- function(.input_df, columns = c("Precursor.Id","Modified.Sequence")){
  if (length(columns) < 1){
    print('translate_diann_channel_format, no columns specified')
    return(.input_df)
  }
  
  if (nrow(.input_df) < 1){
    print('translate_diann_channel_format, dataframe is empty')
    return(.input_df)
  }
  
  # check if channel is in old format
  test_precursor <- .input_df[[columns[1]]][[1]]
  label_occurences <- str_count(test_precursor, 'mTRAQ-[a-zA-Z]-')
  if(label_occurences == 0){
    return(.input_df)
  }

  
  for (column in columns) {
    .input_df[[column]] = sapply(.input_df[[column]], .update_channel)
  }
  

  return(.input_df)

}

.update_channel <- function(sequence){
  groups <- str_match_all(sequence, "mTRAQ-([a-zA-Z])-([0-9]+)")
  
  if (length(groups) > 0 ){
    groups <- groups[[1]]
    
    for(i in 1:nrow(groups)){
      sequence <- str_replace_all(sequence, groups[i,1], paste0('mTRAQ',groups[i,3]))
    }
  }
  
  return(sequence)
}

custom_colors = c("#e8411c", "#f7c12a", "#329ebf",'#51c473','#c355d4','#6e6e6e',"#e8411c", "#f7c12a", "#329ebf",'#51c473','#c355d4','#6e6e6e')
custom_theme = 

separate_channel_info <- function(df){
  channels <- config[['channels']]

  df$Label <- sapply(df$Precursor.Id, .get_channel, channels )

  for (channel in channels) {
    mod <- channel[['modification']]
    df$Precursor.Id <- gsub(paste0('\\Q',mod,'\\E'),'',df$Precursor.Id)
  }

  return(df)
}

.get_channel <- function(sequence, channeldata){
  
  label = ''
  
  for (channel in channeldata) {
    current_label = channel[['name']]
    mod = channel[['modification']]
    if (grepl( mod, sequence, fixed = TRUE)){
      label <- current_label
    }
  }
  
  return(label)
  
}
