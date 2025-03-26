##################################################################
###                                                            ###
### SERVER                                                     ###
###                                                            ###
##################################################################


source(file.path('server', 'build_modules.R'))
source(file.path('server', 'generate_report.R'))


shinyServer(function(input, output, session) {
  
  
  if(exists('latest_version')) {
    # in addition to printing the version message, show it as a notification here
    if(version == latest_version) {
      showNotification(paste0('You are on the latest version of DO-MS: ', version))
    } else if (version < latest_version) {
      showNotification(paste0('An update to DO-MS has been released: ', latest_version, '. You can download the latest version from our GitHub page: https://github.com/SlavovLab/DO-MS/releases.', '\nYour version: ', version, ' << latest version: ', latest_version, '.\nClick the "x" to dismiss this message'), type='warning', duration=NULL)
    } else {
      # not supposed to happen
      showNotification('Current version ahead of latest release. Ignoring versioning...')
    }
  }
  
  
  
  
  folders <- reactiveVal(data.frame(
    Folder.Name=as.character(c()),
    Has.Files=as.logical(c()),
    Path=as.character(c())
  ))
  
  

  if(file.exists('folder_list.txt')) {
    .folders <- as.data.frame(read_tsv('folder_list.txt', col_types = cols()))
    
    # patch older versions of the folder_list where Has.Files doesn't exist
    if(ncol(.folders) < 3) {
      print('Detected legacy version of folder_list.txt. Patching now...')
      .folders$Has.Files <- TRUE # just set it to true for now
      # reorder columns
      .folders <- .folders[,c('Folder.Name', 'Has.Files', 'Path')]
    }
 
    folders <- reactiveVal(.folders)
  }
  
  add_folder_modal <- function() {
    modalDialog(
      title='Add Folder(s)',
      p('Paths must be formatted according to your operating system. i.e., "C:\\path\\to\\folder" for Windows, and "/path/to/folder" for Mac OS/Linux'),
      p(a(href='https://github.com/SlavovLab/DO-MS/wiki/Adding-Folders', target='_blank', 'Please see this document for help adding folders or getting folder paths')),
      textInput('add_folder_path', 'Folder Path'),
      radioButtons('add_folder_options', 'Options', selected='parent',
                         choices=c('Add Single Folder' = 'parent', 'Add Child Folders' = 'children', 
                                   'Add Recursively' = 'recursive')),
      p('"Add Single Folder" only adds the folder entered'),
      p('"Add Child Folders" adds all child folders that are directly below the path entered'),
      p('"Add Recursively" adds all folders recursively below the path entered. Warning: selecting many folders will take a long time and may bloat the table.'),
      footer = tagList(
        modalButton('Cancel'),
        actionButton('add_folders_confirm', 'Confirm')
      )
    )
  }
  
  # launch add folder modal
  observeEvent(input$show_add_folder_modal, {
    showModal(add_folder_modal())
  })
  
  # listen to add folder modal completion
  observeEvent(input$add_folders_confirm, {
   
    # get a copy of the current list of folders
    .folders <- isolate(folders())
    # list of selected files
    .input_files <- isolate(input$input_files)
    
    directory <- input$add_folder_path
    
    
    # does directory exist?
    finfo <- file.info(directory) # get file information
    
    # if doesn't exist, show error and break out
    if(is.na(finfo$size)) {
      showNotification(paste0('Folder "', directory, '" does not exist.'), type='error')
      return()
    }
    
    # if exists, but is not a folder, show error and break out
    if(!finfo$isdir) {
      showNotification(paste0('Folder "', directory, '" is a file, not a folder.'), type='error')
      return()
    }
    
    # if the directory path ends in '/', then remove it.
    if(substr(directory, nchar(directory), nchar(directory)) == .Platform$file.sep) {
      directory <- substr(directory, 0, nchar(directory)-1)
    }
    
    new_folders <- c()
    # what to do with this folder
    if(input$add_folder_options == 'children' | input$add_folder_options == 'recursive') {
      
      # if add_children is checked, then look for child folders within the one specified
      # and add all of those. again, don't have to check if they contain relevant files, yet
      child_dirs <- list.dirs(path=directory, recursive=(input$add_folder_options == 'recursive'))
      
      # for each child directory, check if it exists already and add if not
      for(child_dir in child_dirs) {
        
        # if folder chosen by user is already in the list, then ignore
        if(child_dir %in% .folders$Path) {
          showNotification(paste0('Folder ', basename(child_dir), ' already in list. Skipping...'), type='warning')
          next
        }
        
        # add folder to list
        new_folders <- c(new_folders, child_dir)
      }
      
    } else {
      # if folder chosen by user is already in the list, then ignore
      if(directory %in% .folders$Path) {
        showNotification(paste0('Folder ', basename(directory), ' already in list. Skipping...'), type='warning')
        return()
      }
      # add folder to list
      new_folders <- c(new_folders, directory)
    }
    
    # transform char vector into data table
    # at the same time, check if MaxQuant output files exist
    for(folder in new_folders) {
      folder_files <- list.files(path=folder)
      # require that it has all files
      has_files <- all(sapply(config[['input_files']], function(i) { i$file }) %in% folder_files)
      
      
      # if the user wants to skip folders without all files present...
      if(!config[['allow_all_folders']] & !has_files) {
        showNotification(paste0('Folder ', folder, ' does not have all input files and user has specified to skip such folders. Skipping...'), type='warning')
        next
      }
      
      # add folder to table
      .folders <- rbind(.folders, data.frame(
        Folder.Name=as.character(basename(folder)),
        Has.Files=as.logical(has_files),
        Path=as.character(folder)
      ))
    }
    
    # set temp variable into reactive value
    folders(.folders)
    
    # remove modal
    removeModal()
  })
  
  # have a debounced version of folders, so we can do more
  # expensive operations when the list changes
  folders_d <- folders %>% debounce(3000) # by 3 seconds
  
  # react when folders_d (debounced version) is updated
  observe({
    # write folder list to file (overwrite previous)
    write_tsv(folders_d(), file='folder_list.txt')
  })
  
  output$data_status <- renderUI({
    if(is.null(selected_folders())) {
      return(HTML('<b>No Data Loaded</b>.<br/>Please select files from <span style="color:#3c8dbc;">Input File Selection</span> and folders from <span style="color:#3c8dbc;">Folder List</span>, and then click \"Load Data\"'))
    }
    if(is.null(selected_files())) {
      return(HTML())
    }
    HTML(paste(
      paste0('Loaded ', length(selected_files()),
             ' files: ', paste(paste0(selected_files(), '.txt'), collapse=', ')),
      paste0('From ', length(selected_folders()), 
             ' folders: ', paste(selected_folders(), collapse=', ')),
    sep='<br/>'))
  })
  
  output$folder_table <- DT::renderDataTable({
    folders()
  }, options=list(
    columnDefs=list(
      list(visible=FALSE, targets=0), # hide the row number
      list(title='Folder', targets=1), # rename folder list columns
      list(title='Has Files', targets=2),
      list(title='Path', targets=3)),
    pageLength=5,
    dom='lftp',
    lengthMenu=c(5, 10, 15, 20, 50)
  ))
  
  output$selected_folders <- renderUI({
    selected <- input$folder_table_rows_selected
    .folders <- folders()
    HTML(paste(
      paste0('<b>', length(selected), '</b> folder(s) selected:'),
      paste(.folders[selected, 'Folder.Name'], collapse=', '),
    sep='<br/>'))
  })
  
  observeEvent(input$clear_folder_selection, {
    DT::dataTableProxy('folder_table') %>% DT::selectRows(NULL)
  })
  observeEvent(input$folder_select_all, {
    .folders <- isolate(folders())
    DT::dataTableProxy('folder_table') %>% DT::selectRows(1:nrow(.folders))
  })
  
  observeEvent(input$delete_folders, {
    selected <- isolate(input$folder_table_rows_selected)
    
    # if no folders are selected, break out
    if(length(selected) == 0 | is.null(selected)) {
      showNotification('No folders selected', type='warning')
      return()
    }
    
    .folders <- folders()
    .folders <- .folders[-selected,]
    folders(.folders)
    showNotification(paste0(length(selected), ' folder(s) deleted'), type='warning')
  })
  
  data <- reactiveVal(NULL)
  selected_folders <- reactiveVal(NULL)
  selected_files <- reactiveVal(NULL)
  
  observeEvent(input$confirm_folders, {
    selected <- input$folder_table_rows_selected
    .folders <- folders()
    .input_files <- input$input_files
    
    # if no folders are selected, break out
    if(length(selected) == 0 | is.null(selected)) {
      showNotification('No folders selected', type='warning')
      return()
    }
    
    # if no MQ files are selected, break out
    if(length(.input_files) == 0 | is.null(.input_files)) {
      showNotification('No input files selected', type='warning')
      return()
    }
    
    # set selected folders, selected files
    selected_folders(.folders$Folder.Name[selected])
    selected_files(.input_files)
    
    showNotification(paste0('Loading files...'), type='message')
    
    # create progress bar
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message='', value=0)
    
    # each progress step will be per folder, per file.
    progress_step <- (1 / (length(selected) * length(.input_files)))
    
    # create the data list
    .data <- list()
    
    # loop thru input files
    for(file in .input_files) {
      # get the input file object as defined in global.R
      file <- config[['input_files']][[file]]
      
      # loop thru selected folders
      for(s in selected) {
        folder <- .folders[s,]
        
        # update progress bar
        progress$inc(progress_step, 
                     detail=paste0('Reading ', file[['file']], ' from ', folder$Folder.Name))
        
        # if file doesn't exist, skip
        if(!file.exists(file.path(folder$Path, file[['file']]))) {
          showNotification(paste0(file.path(folder$Path, file[['file']]), ' does not exist'), type='error')
          next
        }
        
        # read data into temporary data.frame
        # increase the number of guesses from the default,
        # since a lot of MS data is very sparse and only using the first 1000
        # rows to guess may guess a column type wrong
        # Custom behavior for report
        if(file$file == 'report.parquet') {
          .dat <- as.data.frame(read_parquet(file=file.path(folder$Path, file[['file']])))
        }

        else {
          .dat <- as.data.frame(read_tsv(file=file.path(folder$Path, file[['file']]),
                                        guess_max=1e5, col_types = cols()))
        }


        # Custom behavior for ms1_extracted
        if(file$name == 'ms1_extracted') {
          # transform matrix style output to report.tsv style
          .dat <- ms1_extracted_to_report(.dat)
        }
        
        # Custom behavior for report
        if((file$name == 'report') && (! is.null(.dat))) {
          
          # DIA-NN versions > 1.8.1 beta 12 use a different channel identifier 
          # for the modified sequence and precursor Id.
          # This will transform the new sequence format to the old one.
          .dat <- translate_diann_channel_format(.dat)
          
          # Add column for modified precursor without channel
          .dat <- separate_channel_info(.dat)
          
        }
        
        # rename columns (replace whitespace or special characters with '.')
        .dat <- .dat %>% dplyr::rename_all(make.names)
        
        # apply column aliases
        .dat <- apply_aliases(.dat)
        
        
        
        if('Raw.file' %in% colnames(.dat)) {
          # Remove any rows where "Total" is a raw file (e.g., summary.txt)
          .dat <- .dat %>% dplyr::filter(!Raw.file == 'Total')
          
          # coerce raw file names to a factor
          .dat$Raw.file <- factor(.dat$Raw.file)
        }
        
        
        
        # Custom behavior for parameters.txt
        if(file$name == 'parameters') {
          # store folder name/path as a value in parameters.txt
          .dat <- rbind(c('Folder Name', folder$Folder.Name), c('Folder Path', folder$Path), .dat, 
                        stringsAsFactors=FALSE)
          # rename value column to folder name as well
          colnames(.dat)[2] <- folder$Folder.Name
        } else {
          # store folder name and path
          .dat$Folder.Name <- folder$Folder.Name
          .dat$Folder.Path <- folder$Path
        }
        
        # if field is not initialized yet, set field
        if(is.null(.data[[file$name]])) {
          .data[[file$name]] <- .dat
        }
        # if parameters.txt file, then cbind instead of rbind
        else if(file$name == 'parameters') {
          
          # take only the common rows (instead of the common columns)
          rows_prev <- .data[[file$name]]$Parameter
          rows_new <- .dat$Parameter
          common_rows <- intersect(rows_prev, rows_new)
          
          # print warnings about rows being lost
          diff_rows <- setdiff(rows_prev, rows_new)
          if(length(diff_rows) > 0) {
            showNotification(paste0(length(diff_rows), ' parameters in file \"', file$name, '\" are exclusive to some analyses but not others. Eliminating the different parameters'), type='warning')
            print(paste0(length(diff_rows), ' parameters in file ', file$name, ' are exclusive to some analyses but not others. Eliminating the different parameters: ', paste(diff_rows, collapse=', ')))
          }
          
          .data[[file$name]] <- cbind(
            # original
            .data[[file$name]] %>% 
              dplyr::filter(Parameter %in% common_rows), 
            # new
            .dat %>% 
              dplyr::filter(Parameter %in% common_rows) %>%
              dplyr::select(-1) %>% 
              dplyr::pull()
          )
          # rename column to folder name
          colnames(.data[[file$name]])[ncol(.data[[file$name]])] <- folder$Folder.Name
        }
        # otherwise, append to existing data.frame
        else {
          
          # before we append, need to make sure that columns match up
          # if not, then take the intersection of the columns (only common columns)
          cols_prev <- colnames(.data[[file$name]])
          cols_new  <- colnames(.dat)
          common_cols <- intersect(cols_prev, cols_new)
          
          # print warning about columns being lost
          diff_cols <- setdiff(cols_prev, cols_new)
          if(length(diff_cols) > 0) {
            showNotification(paste0(length(diff_cols), ' columns in file \"', file$name, '\" are exclusive to some analyses but not others. Eliminating the different columns.'), type='warning')
            print(paste0(length(diff_cols), ' columns in file ', file$name, ' are exclusive to some analyses but not others. Eliminating the different columns: ', paste(diff_cols, collapse=', ')))
          }
          
          # merge dataframes, with only common columns between the two frames
          .data[[file$name]] <- rbind(.data[[file$name]][,common_cols], .dat[,common_cols], 
                                      stringsAsFactors=FALSE)
        }
      }
    }
    
    # set the data
    data(.data)
    
    
    showNotification(paste0('Loading Complete!'), type='message')
  })
  
  # for each misc. input file, create a form object
  # which will then be displayed on the import tab page
  misc_input_forms <- list()
  for(file in config[['misc_input_files']]) {
    # for now, all files are specified to be csv/tsv files,
    # but a input file type can be added later so that we can support
    # multiple file types
    misc_input_forms[[file$name]] <- fileInput(
      file$name, file$help,
      accept = c(
        "text/csv/tsv",
        "text/comma-separated-values,text/plain",
        ".csv",'.txt', '.tsv',options(shiny.maxRequestSize=1000*1024^2) 
      )
    )
  }

  # render the input forms into an HTML object
  output$misc_input_forms <- renderUI({
    do.call(tagList, misc_input_forms)
  })
  
  # handle misc file input events
  observe({
    # isolate data obj because we dont want changes in that to trigger this
    .data <- isolate(data())
    
    # create a progress bar, only if theres data somewhere
    all_empty <- TRUE
    for(file in config[['misc_input_files']]) {
      if(!is.null(input[[file$name]])) {
        progress <- shiny::Progress$new()
        on.exit(progress$close())
        progress$set(message='', value=0)
        all_empty <- FALSE
        break
      }
    }
    
    # if no files exist yet, then exit now
    if(all_empty) {
      return()
    }
    
    # loop thru all misc input files and add it to the data list
    for(file in config[['misc_input_files']]) {
      # update progress bar
      progress$inc(1 / length(config[['misc_input_files']]), detail=paste0('Reading ', file$name))
      
      # get the fileinput object
      .file <- input[[file$name]]
      
      # don't read if there's no file there
      if(is.null(.file)){ next }
      # also don't read if it's already been read
      if(!is.null(.data[[file$name]])) { next }
      
      # read in as data frame (need to convert from tibble)
      .data[[file$name]] <- as.data.frame(read_tsv(file=.file$datapath, col_types = cols()))
      # rename columns (replace whitespace or special characters with '.')
      colnames(.data[[file$name]]) <- gsub('\\s|\\(|\\)|\\/|\\[|\\]', '.', 
                                           colnames(.data[[file$name]]))
      # coerce raw file names to a factor
      if('Raw.file' %in% colnames(.data[[file$name]])) {
        .data[[file$name]]$Raw.file <- factor(.data[[file$name]]$Raw.file)
      }
    }
    
    # reassign data object
    data(.data)
  })
  
  # count and catalogue raw files across combined input files 
  raw_files <- reactive({
    f_data <- data()
    
    # if no data has been loaded yet, break out
    if(is.null(f_data)) {
      return(NULL)
    }
    
    .raw_files <- c()
    
    for(file in config[['input_files']]) {
      # don't do this with MaxQuant's summary.txt file since it has weird behavior
      if(file$name == 'summary') { next; }
      if(file$name == 'features') { next; }
      
      # for each file, check if it has a raw file column
      if('Raw.file' %in% colnames(f_data[[file$name]])) {
        # get the raw files for this input file
        ..raw_files <- levels(f_data[[file$name]]$Raw.file)
        for(raw_file in ..raw_files) {
          # if the raw file is not in the list of raw files, then add it
          if(!raw_file %in% .raw_files) {
            
            # store the folder it came from as the name of the raw file
            names(raw_file) <- first(unique(
              f_data[[file$name]] %>% 
                dplyr::filter(`Raw.file` == raw_file) %>% 
                dplyr::pull(Folder.Name)
            ))
            
            .raw_files <- c(.raw_files, raw_file)
          }
        }
      }
    }
    
    # sort the raw files
    #.raw_files <- sort(.raw_files)
    
    .raw_files
  })
  
  # custom, user-defined experiment names
  exp_name_table <- reactive({
    .raw_files <- raw_files()
    .file_levels <- file_levels()
    
    # if lengths aren't equal, then we're in the middle of reloading our data
    # return an empty dataframe so we don't crash out
    if(length(.raw_files) != length(.file_levels)) {
      return(data.frame())
    }
    
    # apply re-ordering
    nfile_order <- file_order()
    if(length(nfile_order) > 1) {
      .file_levels <- .file_levels[nfile_order]
      .raw_files <- .raw_files[nfile_order]
    }
    
    data.frame(
      `Raw file`=.raw_files,
      Labels=.file_levels
    )
  })
  
  output$exp_name_table <- DT::renderDataTable({
    validate(need(raw_files(), 'Please import data before proceeding'))
    validate(need(file_levels(), 'Please import data before proceeding'))
    exp_name_table()
  }, selection='none', editable=T, extensions='RowReorder', options=list(
    pageLength=10,
    dom='ltp',
    lengthMenu=c(5, 10, 15, 20, 50),
    rowReorder=T,
    order=list(c(0, 'asc'))
  ), callback=JS(
    "table.on('row-reorder', function(e, details, changes) {
       Shiny.onInputChange('exp_name_table_row_reorder', JSON.stringify(details));
    });"
  ))
  exp_name_table_proxy <- dataTableProxy('exp_name_table')
  
  # observe changes to the experiment name table cell contents
  observeEvent(input$exp_name_table_cell_edit, {
    info = input$exp_name_table_cell_edit
    i = info$row
    j = info$col + 1  # column index offset by 1
    v = info$value
    
    # Replace the data object of a table output and avoid regenerating the full table,
    .exp_name_table <- isolate(exp_name_table())
    # don't need DT::coerceValue like they use in example -- this will always be a string
    .exp_name_table[i, j] <- as.character(v)
    DT::replaceData(exp_name_table_proxy, .exp_name_table, resetPaging = FALSE, rownames = FALSE)
    
    # update the file_levels vector
    .file_levels <- isolate(file_levels())
    .file_levels[i] <- as.character(v)
    file_levels(.file_levels)
  })
  
  # level ordering
  file_order <- reactiveVal()
  
  # initialize file ordering
  # only triggers when raw files or format has changed
  observe({
    .raw_files <- raw_files()
    
    # if raw files (i.e., data) haven't been loaded yet, break
    if(length(.raw_files) == 0 | is.null(.raw_files)) {
      return(c())
    }
    
    # by default, go by the default order (alphabetical, ascending)
    file_order(seq(1, length(.raw_files)))
  })
  
  exp_name_table_proxy2 <- dataTableProxy('exp_name_table')
  # observe row reordering
  observeEvent(input$exp_name_table_row_reorder, {
    info <- input$exp_name_table_row_reorder
    if(is.null(info) | class(info) != 'character') { return() }
    
    info <- read_yaml(text=info)
    if(length(info) == 0) { return() }
    
    .order <- file_order()
    .new_order <- .order
    
    for(i in 1:length(info)) {
      j <- info[[i]]
      .new_order[(j$newPosition+1)] <- .order[(j$oldPosition+1)]
    }
    
    # Replace the data object of a table output and avoid regenerating the full table,
    #.exp_name_table <- isolate(exp_name_table())
    # don't need DT::coerceValue like they use in example -- this will always be a string
    #.exp_name_table <- .exp_name_table[order(.new_order),]
    #DT::replaceData(exp_name_table_proxy2, .exp_name_table, resetPaging = FALSE, rownames = FALSE)
    
    file_order(.new_order)
  })
  
  exp_name_format <- reactiveVal(config[['exp_name_format']])
  # only change the exp_name_pattern when the apply button is pressed
  observeEvent(input$exp_name_format_apply, {
    exp_name_format(input$exp_name_format)
  })
  
  exp_name_pattern <- reactiveVal(config[['exp_name_pattern']])
  # only change the exp_name_pattern when the apply button is pressed
  observeEvent(input$exp_name_pattern_apply, {
    exp_name_pattern(input$exp_name_pattern)
  })
  
  file_levels <- reactiveVal()
  
  # recalculate file levels
  # only triggers when raw files or format has changed
  observe({
    .raw_files <- raw_files()
    
    # if raw files (i.e., data) haven't been loaded yet, break
    if(length(.raw_files) == 0 | is.null(.raw_files)) {
      return(c())
    }
    
    # load naming format
    .format <- exp_name_format()
    .pattern <- exp_name_pattern()
    .file_levels <- rep(.format, length(.raw_files))
    
    # replace flags in the format
    # replacements have to be character vectors with same length as raw file vector
    
    # replace %i with the index
    .file_levels <- str_replace(.file_levels, '\\%i', as.character(seq(1, length(.raw_files))))
    
    # replace %f with the folder name
    # folder name is stored as the names of the raw files vector
    .file_levels <- str_replace(.file_levels, '\\%f', names(.raw_files))
    
    # replace %e with the raw file name
    .file_levels <- str_replace(.file_levels, '\\%e', .raw_files)
    
    print(.pattern)
    # apply custom string extraction expression to file levels
    if(!is.null(.pattern) & length(.pattern) > 0 & nchar(.pattern) > 0) {
      # account for users inputting bad regexes
      .file_levels <- tryCatch({ str_extract(.file_levels, .pattern) },
        error=function(e){
          showNotification(paste0('Invalid regex: ', e), type='error')
          .file_levels
        }
      )
      # if string extraction failed, then will return NA. set NAs to "default"
      .file_levels[is.na(.file_levels)] <- 'default'
    }
    
    file_levels(.file_levels)
  })
  
  # deal with duplicates in file_levels
  observe({
    .raw_files <- isolate(raw_files())
    .file_levels <- file_levels()
    
    # ensure there are no duplicate names
    # if so, then append a suffix to duplicate names to prevent refactoring errors
    
    # only do this if we have more than one experiment
    if(length(.raw_files) > 1) {
      for(i in 1:(length(.file_levels)-1)) {
        duplicate_counter <- 0
        for(j in (i+1):length(.file_levels)) {
          if(.file_levels[i] == .file_levels[j]) {
            showNotification(paste0('Label "', .file_levels[i], '" is a duplicate of label "', .file_levels[j], '". Adjusting file names to prevent collisions.'), type='warning')
            # if j is a duplicate, append the corresponding duplicate number and increment
            .file_levels[j] <- paste0(.file_levels[j], '_', duplicate_counter + 2)
            duplicate_counter <- duplicate_counter + 1
          }
        }
        # if there were any duplicates, change .file_levels[i]
        if(duplicate_counter > 0) {
          .file_levels[i] <- paste0(.file_levels[i], '_1')
        }
      }
    }
    
    file_levels(.file_levels) # update
  })
  
  # listen to the experiment selection checkboxes
  observe({
    if(length(file_levels()) > 0 & length(raw_files() > 0)) {
      # update the selection input
      # for the selection input only, concatenate the nickname and the raw file name

      choices <- file_levels()
      names(choices) <- paste0(file_levels(), ': ', raw_files())
      
      shinyWidgets::updatePickerInput(session, 'Exp_Sets', '',
        selected=file_levels(), choices=choices)
    }
  })
  
  # filtered data
  # debounce (throttle) by 1000ms delay, because this expression is so costly
  filtered_data <- debounce(reactive({
    f_data <- data()

    # skip if no data has been loaded yet
    if(is.null(f_data)) return()
    
    
    
    for(file in config[['input_files']]) {
      
       if('Raw.file' %in% colnames(f_data[[file$name]]))  {
        
        # make a copy of the raw file column
        f_data[[file$name]]$Raw.file.orig <- f_data[[file$name]]$Raw.file
        
        
        olevels <- levels(f_data[[file$name]]$Raw.file)
        nlabels <- file_levels()
        nlevels <- as.vector(unlist(isolate(raw_files()), use.names=FALSE))
        
        
        # if labels are still not loaded or defined yet, then default them to the levels
        if(is.null(nlabels) | length(nlabels) < 1 | length(nlabels) != length(nlevels)) {

          nlabels <- nlevels
        }
        
        # if this file has a subset of raw files
        # then take the same subset of the labels vector
        if(length(nlabels) > length(nlevels)) {
          nlabels <- nlabels[1:length(nlevels)]
        }
        
        # apply re-ordering
        nfile_order <- file_order()
        if(length(nfile_order) > 1) {
          nlevels <- nlevels[nfile_order]
          nlabels <- nlabels[nfile_order]
        }
        

        # recalculate file levels
        f_data[[file$name]]$Raw.file <- factor(f_data[[file$name]]$Raw.file,
                                               levels=nlevels, labels=nlabels)
        
        # Filter for experiments as specified by user
        if(!is.null(input$Exp_Sets)) {
          f_data[[file$name]] <- f_data[[file$name]] %>%
            dplyr::filter(Raw.file %in% input$Exp_Sets)
        }
        
        # drop filtered-out levels
        droplevels(f_data[[file$name]]$Raw.file, reorder=FALSE)
      }
      
      ## Filter observations
      
      if (config[['do_ms_mode']] == 'max_quant'){
        # Filter out decoys and contaminants, if the leading razor protein column exists
        if('Leading.razor.protein' %in% colnames(f_data[[file$name]])) {
          if(!is.null(config[['remove_contam']])) {
            f_data[[file$name]] <- f_data[[file$name]] %>% 
              dplyr::filter(!grepl(config[['remove_contam']], Leading.razor.protein))
          }
          if(!is.null(config[['remove_decoy']])) {
            f_data[[file$name]] <- f_data[[file$name]] %>% 
              dplyr::filter(!grepl(config[['remove_decoy']], Leading.razor.protein))
          }
        }
        
        # Filter by PEP
        if('PEP' %in% colnames(f_data[[file$name]])) {
          f_data[[file$name]] <- f_data[[file$name]] %>%
            dplyr::filter(PEP < input$pep_thresh | is.na(PEP))
        }
        
        # Filter by PIF
        if('PIF' %in% colnames(f_data[[file$name]])) {
        #filter on PIF only if the value is not NA
            f_data[[file$name]] <- f_data[[file$name]] %>%
              dplyr::filter(PIF > input$pif_thresh | is.na(PIF))
        }
        
      }
      else if (config[['do_ms_mode']] == 'dia-nn'){
        # calculate modification columns
        
        # Filter by PEP
        if('PEP' %in% colnames(f_data[[file$name]])) {
          f_data[[file$name]] <- f_data[[file$name]] %>%
            dplyr::filter(PEP < input$pep_thresh | is.na(PEP))
        }
        
        
        # apply modification filter
        if('Precursor.Id' %in% colnames(f_data[[file$name]])) {
          
          modvec <- c()
          # create modification columns
          for(i in 1:length(config[['modifications']])){
            unimod <- config[['modifications']][[i]]$unimod
            modvec <- c(modvec, config[['modifications']][[i]]$unimod)
          
            f_data[[file$name]][unimod] <- sapply(f_data[[file$name]]['Precursor.Id'], str_count, paste0('\\Q',unimod,'\\E'))
          }
          
          # summarize over all modification columns
          f_data[[file$name]]['mod_sum'] <- rowSums(f_data[[file$name]][,modvec])

          # filter for modifications
          modifications <- config[['modification_list']]
        
          if (input$modification == "All"){
            
          } else if (input$modification == "Unmodified") {

            
            f_data[[file$name]] <- f_data[[file$name]][f_data[[file$name]]['mod_sum'] < 1,]
            
          } else {
            
            # Try to resolve unimod key from modifications dataframe
            
            
            modifications_filtered <- modifications[modifications$name == input$modification, ]
            
            if (nrow(modifications_filtered) > 0){
              # contains unimod label for the current modification
              unimod <- modifications_filtered$unimod[[1]]
              
              #filter for all rows, which contain modification
              f_data[[file$name]] <- f_data[[file$name]][f_data[[file$name]][unimod] > 0,]
              
              if (nrow(f_data[[file$name]]) == 0){
                showNotification(paste("No Precursors found with modification:",input$modification), type='warning')
              }
              
            }
          }
        }
        
        # apply MBR filter
        
        #if(!input$mbr){
        #  if (file$name == 'report'){
            
        #    if ('report-first-pass' %in% names(f_data)){
              
        #     f_data[['report']] <- f_data[['report-first-pass']]

        #    } else {
        #      showNotification("Cant show results without MBR, report-first-pass.tsv was not found.", type='warning')
        #    }
        #  }

        #}
        
      }
      
      
      
      
      
      # Filter by PIF
      #if('PIF' %in% colnames(f_data[[file$name]])) {
        # filter on PIF only if the value is not NA
      #  f_data[[file$name]] <- f_data[[file$name]] %>%
      #    dplyr::filter(PIF > input$pif_thresh | is.na(PIF))
      #}
      
      # filter by modification
      
      ## More filters, like Intensity?
    }
    
    ## Filtered data
    f_data
  }), 1000)
  
  output$UserExpList <- renderText({ input$Exp_Names })
  exp_sets <- reactive({ input$Exp_Sets }) %>% debounce(1000)
  
  attach_module_outputs(input, output, filtered_data, exp_sets)
  render_modules(input, output)
  
  # PDF Report Generation
  download_report(input, output, filtered_data, exp_sets)
  
  traceback()
})
