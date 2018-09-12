source('global.R')

shinyServer(function(input, output, session) {
  
  # for each input file, create a form object
  # which will then be displayed on the import tab page
  input_forms <- list()
  for(file in input_files) {
    # for now, all files are specified to be csv/tsv files,
    # but a input file type can be added later so that we can support
    # multiple file types
    input_forms[[file$name]] <- fileInput(
      file$name, file$help,
      accept = c(
        "text/csv",
        "text/comma-separated-values,text/plain",
        ".csv",'.txt', options(shiny.maxRequestSize=300*1024^2) 
      )
    )
  }
  # render the input forms into an HTML object
  output$input_forms <- renderUI({
    do.call(tagList, input_forms)
  })
  
  # store all data as a reactive named list
  # this could also be done as a reactiveValues list -- 
  # but haven't gotten that to work yet.
  data <- reactive({
    # create the data list
    .data <- list()
    # loop thru all input files and add it to the data list
    for(file in input_files) {
      .file <- input[[file$name]]
      if(is.null(.file)){ next }
      # TODO: replace with readr read_tsv? or read_csv
      #.data[[file$name]] <- read.delim(file=.file$datapath, header=TRUE)
      .data[[file$name]] <- as.data.frame(read_tsv(file=.file$datapath))
      # rename columns (replace whitespace or special characters with '.')
      colnames(.data[[file$name]]) <- gsub('\\s|\\(|\\)|\\/|\\[|\\]', '.', 
                                           colnames(.data[[file$name]]))
      # coerce raw file names to a factor
      if('Raw.file' %in% colnames(.data[[file$name]])) {
        .data[[file$name]]$Raw.file <- factor(.data[[file$name]]$Raw.file)
      }
    }
    # return the data list
    .data
  })
  
  raw_files <- reactive({
    f_data <- data()
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
  file_levels <- reactive({
    
    .raw_files <- raw_files()
    if(length(.raw_files) == 0) {
      return(c())
    }
    
    level_prefixes <- paste0('Exp ', seq(1, 100))
    # create the nickname vector
    .file_levels <- level_prefixes[1:length(.raw_files)]
    
    named_exps <- unlist(strsplit(paste(input$Exp_Names), ","))
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
    
    .file_levels
  })
  
  observe({
    if(length(file_levels()) > 0 & length(raw_files() > 0)) {
      # update the selection input
      # for the selection input only, concatenate the nickname and the raw file name
      updateCheckboxGroupInput(session, 'Exp_Sets', 'Select Experiments to Display',
                               choiceNames=paste0(file_levels(), ': ', raw_files()), 
                               choiceValues=file_levels(), selected=file_levels())
    }
  })
  
  # filtered data
  filtered_data <- reactive({
    f_data <- data()
    
    ## TODO: Apply filters (PEP, experiment subsets, ....)
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
  })
  
  output$UserExpList <- renderText({ input$Exp_Names })
  
  # load each module from the module list via. callModule
  # each module is loaded by passing the moduleFunc field of the module
  # data is only in one reactive named list -- passing in filtered_data
  for(module in modules) {
    callModule(module$moduleFunc, module$id, data=filtered_data)
  }
  
  # need local({}) to isolate each instance of the for loop - or else the output
  # of each iteration will default to to the last one.
  # see: https://gist.github.com/wch/5436415/
  for(tab in tabs) { local({
    modules_in_tab <- modules[sapply(modules, function(m) { m$tab == tab })]
    
    plots <- lapply(modules_in_tab, function(m) {
      ns <- NS(m$id)
      # instead of using box() as provided by shinydashboard,
      # we're going to hack in a similar div since we have to shove in additional elements
      return(div(class='col-sm-6', div(class='box box-solid', 
        style='',
        # header
        div(class='box-header',
          h3(class='box-title', m$boxTitle),
          tags$button(class='btn btn-secondary tooltip-btn', 
                      `data-toggle`='tooltip', `data-placement`='right', title=m$help,
            icon('question-sign', lib='glyphicon')  
          ),
          
          div(class='box-tools pull-right',
            tags$button(class='btn btn-box-tool', `data-widget`='collapse',
                        shiny::icon('minus'))
          )
        ),
        div(class='box-body',
          fixedRow(
            plotOutput(ns('plot'), height=370)  
          )
        ),
        # TODO: conditionalPanel which only displays the buttons when the relevant data is loaded
        div(class='box-footer',
          div(class='row', style='height:30px',
            column(width=4,
              downloadButtonFixed(ns('downloadPDF'), label='PDF')
            ),
            column(width=4,
              downloadButtonFixed(ns('downloadPNG'), label='PNG')
            ),
            column(width=4,
              downloadButtonFixed(ns('downloadData'), label='Data')
            )
          )
        )
      )))
    })
    output[[tab]] <- renderUI(plots)
  }) }
  
  ######################################################################################
  ######################################################################################
  # PDF Report Generation Area 
  # [structure/code pulled from an official Shiny tutorial]
  ######################################################################################
  ######################################################################################
  
  output$report.pdf <- downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = "SCoPE_QC_Report.pdf",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "SCoPE_QC_Report.Rmd")
      file.copy("SCoPE_QC_Report.Rmd", tempReport, overwrite = TRUE)
      
      # Set up parameters to pass to Rmd document
      params <- list(pep_in = input$slider, 
                     set_in = input$Exp_Sets, 
                     evid = input$file, 
                     msmsSc = input$file2, 
                     aPep = input$file3, 
                     exp_desc = input$Exp_Names)
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(tempReport, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
    }
  )
})

