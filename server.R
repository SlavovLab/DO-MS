##################################################################
###                                                            ###
### SERVER                                                     ###
###                                                            ###
##################################################################

source('global.R')
source(file.path('server', 'build_modules.R'))
source(file.path('server', 'generate_report.R'))

shinyServer(function(input, output, session) {
  
  folders <- reactiveVal(data.frame(
    Folder.Name=as.character(c()),
    Path=as.character(c())
  ))
  
  if(file.exists('folder_list.txt')) {
    folders <- reactiveVal(as.data.frame(read_tsv('folder_list.txt')))
  }
  
  add_folder_modal <- function() {
    modalDialog(
      title='Add Folder(s)',
      textInput('add_folder_path', 'Folder Path'),
      radioButtons('add_folder_options', 'Options', selected=character(0),
                         choices=c('Add Child Folders' = 'children', 
                                   'Add Recursively' = 'recursive')),
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
    
    # what to do with this folder
    if(input$add_folder_options == 'children' | input$add_folder_options == 'recursive') {
      
      # if add_children is checked, then look for child folders within the one specified
      # and add all of those. again, don't have to check if they contain relevant files, yet
      child_dirs <- list.dirs(path=directory, recursive=input$add_folder_options == 'recursive')
      
      # for each child directory, check if it exists already and add if not
      for(child_dir in child_dirs) {
        
        # if folder chosen by user is already in the list, then ignore
        if(child_dir %in% .folders$Path) {
          showNotification(paste0('Folder ', basename(directory), ' already in list. Skipping...'), type='warning')
          next
        }
        
        # add folder to list
        .folders <- rbind(.folders, data.frame(
          Folder.Name=basename(child_dir),
          Path=child_dir
        ))
      }
      
    } else {
      
      # if we're not looking for child folders, then allow this addition
      # we could check for membership of certain files (evidence.txt, etc) later,
      # but now just let the user add whatever they want
      
      # if folder chosen by user is already in the list, then ignore
      if(directory %in% .folders$Path) {
        showNotification(paste0('Folder ', basename(directory), ' already in list. Skipping...'), type='warning')
        return()
      }
      
      # add folder to list
      .folders <- rbind(.folders, data.frame(
        Folder.Name=basename(directory),
        Path=directory
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
    showNotification('Writing folder list to file...', type='message')
    # write folder list to file (overwrite previous)
    write_tsv(folders_d(), path='folder_list.txt')
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
      list(title='Path', targets=2)),
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
    selected <- isolate(input$folder_table_rows_selected)
    .folders <- isolate(folders())
    .input_files <- isolate(input$input_files)
    
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
      file <- input_files[[file]]
      
      # loop thru selected folders
      for(s in selected) {
        folder <- .folders[s,]
        
        # update progress bar
        progress$inc(progress_step, detail=paste0('Reading ', file[['file']], 
                                                  ' from ', folder$Folder.Name))
        
        # if file doesn't exist, skip
        if(!file.exists(file.path(folder$Path, file[['file']]))) {
          showNotification(paste0(file.path(folder$Path, file[['file']]), ' does not exist'),
                           type='error')
          next
        }
        
        # read data into temporary data.frame
        .dat <- as.data.frame(read_tsv(file=file.path(folder$Path, file[['file']])))
        
        # rename columns (replace whitespace or special characters with '.')
        colnames(.dat) <- gsub('\\s|\\(|\\)|\\/|\\[|\\]', '.', colnames(.dat))
        # coerce raw file names to a factor
        if('Raw.file' %in% colnames(.dat)) {
          .dat$Raw.file <- factor(.dat$Raw.file)
        }
        
        # if field is not initialized yet, set field
        if(is.null(.data[[file$name]])) {
          .data[[file$name]] <- .dat
        }
        # otherwise, append to existing data.frame
        else {
          
          # before we append, need to make sure that columns match up
          # if not, then take the intersection of the columns (only common columns)
          cols_prev <- colnames(.data[[file$name]])
          cols_new  <- colnames(.dat)
          common_cols <- intersect(cols_prev, cols_new)
          
          if(length(common_cols) < length(cols_prev)) {
            # take only common cols, if there is a difference
            .data[[file$name]] <- .data[[file$name]][,common_cols]
            .dat              <- .dat[,common_cols]
          }
          
          .data[[file$name]] <- rbind(.data[[file$name]], .dat)
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
  for(file in misc_input_files) {
    # for now, all files are specified to be csv/tsv files,
    # but a input file type can be added later so that we can support
    # multiple file types
    misc_input_forms[[file$name]] <- fileInput(
      file$name, file$help,
      accept = c(
        "text/csv",
        "text/comma-separated-values,text/plain",
        ".csv",'.txt', options(shiny.maxRequestSize=1000*1024^2) 
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
    for(file in misc_input_files) {
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
    for(file in misc_input_files) {
      # update progress bar
      progress$inc(1/length(misc_input_files), detail=paste0('Reading ', file$name))
      
      # get the fileinput object
      .file <- input[[file$name]]
      
      # don't read if there's no file there
      if(is.null(.file)){ next }
      # also don't read if it's already been read
      if(!is.null(.data[[file$name]])) { next }
      
      # read in as data frame (need to convert from tibble)
      .data[[file$name]] <- as.data.frame(read_tsv(file=.file$datapath))
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
   
  raw_files <- reactive({
    f_data <- data()
    
    # if no data has been loaded yet, break out
    if(is.null(f_data)) {
      return(NULL)
    }
    
    .raw_files <- c()
    
    for(file in input_files) {
      # for each file, check if it has a raw file column
      if('Raw.file' %in% colnames(f_data[[file$name]])) {
        # get the raw files for this input file
        ..raw_files <- levels(f_data[[file$name]]$Raw.file)
        for(raw_file in ..raw_files) {
          # if the raw file is not in the list of raw files, then add it
          if(!raw_file %in% .raw_files) {
            .raw_files <- c(.raw_files, raw_file)
          }
        }
      }
    }
    
    # sort the raw files
    .raw_files <- sort(.raw_files)
    
    .raw_files
  })
  
  # keep track of user-defined experiment names
  # first debounce the Exp_Names input to prevent errors
  exp_names <- debounce(reactive({ input$Exp_Names }), 1000)
  file_levels <- reactive({
    .raw_files <- raw_files()
    
    # if raw files (i.e., data) haven't been loaded yet, break
    if(length(.raw_files) == 0 | is.null(.raw_files)) {
      return(c())
    }
    
    level_prefixes <- paste0('Exp ', seq(1, 100))
    # create the nickname vector
    .file_levels <- level_prefixes[1:length(.raw_files)]
    
    named_exps <- trimws(unlist(strsplit(paste(exp_names()), ",")))
    if(length(named_exps) > 0) {
      if(length(named_exps) < length(.file_levels)) {
        .file_levels[1:length(named_exps)] <- named_exps
      } else if(length(named_exps) > length(.file_levels)) {
        .file_levels = named_exps[1:length(.file_levels)]
      } else {
        # same length
        .file_levels = named_exps
      }
    }
    
    # ensure there are no duplicate names
    # if so, then append a suffix to duplicate names to prevent refactoring errors
    
    # only do this if we have more than one experiment
    if(length(.raw_files) > 1) {
      
      for(i in 1:(length(.file_levels)-1)) {
        duplicate_counter <- 0
        for(j in (i+1):length(.file_levels)) {
          if(.file_levels[i] == .file_levels[j]) {
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
    
    .file_levels
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
    
    for(file in input_files) {
      
      # for each file, check if it has a raw file column
      if('Raw.file' %in% colnames(f_data[[file$name]])) {
        
        # rename the levels of this file
        f_data[[file$name]]$Raw.file <- factor(f_data[[file$name]]$Raw.file,
          levels=levels(f_data[[file$name]]$Raw.file),
          labels=file_levels())
        
        if(!is.null(input$Exp_Sets)) {
          # Filter for experiments as specified by user
          f_data[[file$name]] <- f_data[[file$name]] %>%
            filter(Raw.file %in% input$Exp_Sets)
        }
      }
      
      ## Filter observations
      
      # Filter out decoys and contaminants, if the leading razor protein column exists
      if('Leading.razor.protein' %in% colnames(f_data[[file$name]])) {
        f_data[[file$name]] <- f_data[[file$name]] %>% 
          filter(!grepl("CON", Leading.razor.protein)) %>%
          filter(!grepl("REV", Leading.razor.protein))
      }
      
      # Filter by PEP
      if('PEP' %in% colnames(f_data[[file$name]])) {
        f_data[[file$name]] <- f_data[[file$name]] %>%
          filter(PEP < input$slider)
      }
      
      ## More filters, like PIF? Intensity?
    }
    
    ## Filtered data
    f_data
  }), 1000)
  
  output$UserExpList <- renderText({ input$Exp_Names })
  exp_sets <- reactive({ input$Exp_Sets }) %>% debounce(1000)
  
  attach_module_outputs(input, output, filtered_data, exp_sets)
  render_modules(input, output)
  
  ######################################################################################
  ######################################################################################
  # PDF Report Generation Area 
  # [structure/code pulled from an official Shiny tutorial]
  ######################################################################################
  ######################################################################################
  
  download_report(input, output, filtered_data, exp_sets)
})