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
        ".csv",'.txt', options(shiny.maxRequestSize=1000*1024^2) 
        #".csv",'.txt', options(shiny.maxRequestSize=300*1024^2) # Changed 20180924 due to Toni break
        
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
    # create a progress bar, only if theres data somewhere
    all_empty <- TRUE
    for(file in input_files) {
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
      return(list())
    }
    
    # create the data list
    .data <- list()
    # loop thru all input files and add it to the data list
    for(file in input_files) {
      # update progress bar
      progress$inc(1/length(input_files), detail=paste0('Reading ', file))
      
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
      updateCheckboxGroupInput(session, 'Exp_Sets', '',
                               choiceNames=paste0(file_levels(), ': ', raw_files()), 
                               choiceValues=file_levels(), selected=file_levels())
    } else {
    }
  })
  
  # filtered data
  # debounce (throttle) by 1000ms delay, because this expression
  # is so computationally costly
  filtered_data <- debounce(reactive({
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
  }), 1000)
  
  output$UserExpList <- renderText({ input$Exp_Names })
  
  # load each module from the module list via. callModule
  # each module is loaded by passing the moduleFunc field of the module
  # data is only in one reactive named list -- passing in filtered_data
  for(module in modules) { local({
    m <- module
    ns <- NS(m$id)
    
    output[[ns('plot')]] <- renderPlot({ 
      m$plotFunc(filtered_data, input)
    })
    
    output[[ns('downloadPDF')]] <- downloadHandler(
      filename=function() { paste0(gsub('\\s', '_', m$boxTitle), '.pdf') },
      content=function(file) {
        ggsave(filename=file, plot=m$plotFunc(filtered_data, input), 
               device=pdf, 
               units=input$download_figure_units,
               width=input$download_figure_width, 
               height=input$download_figure_height)
      }
    )
    
    output[[ns('downloadPNG')]] <- downloadHandler(
      filename=function() { paste0(gsub('\\s', '_', m$boxTitle), '.png') },
      content=function(file) {
        ggsave(filename=file, plot=m$plotFunc(filtered_data, input), 
               # for some reason, specify the png device with a string instead of the
               # straight device, and it doesn't print a handful of pixels
               device='png', 
               units=input$download_figure_units,
               width=input$download_figure_width, 
               height=input$download_figure_height)
      }
    )
    
    output[[ns('downloadData')]] <- downloadHandler(
      filename=function() { paste0(gsub('\\s', '_', m$boxTitle), '.txt') },
      content=function(file) {
        m$validateFunc(filtered_data, input)
        plotdata <- m$plotdataFunc(filtered_data, input)
        write_tsv(plotdata, path=file)
      }
    )
    
  }) }
  
  # need local({}) to isolate each instance of the for loop - or else the output
  # of each iteration will default to to the last one.
  # see: https://gist.github.com/wch/5436415/
  for(tab in tabs) { local({
    modules_in_tab <- modules[sapply(modules, function(m) { 
      gsub('([0-9])+(\\s|_)', '', m$tab) == tab 
    })]
    
    plots <- lapply(modules_in_tab, function(m) {
      ns <- NS(m$id)
      # instead of using box() as provided by shinydashboard,
      # we're going to hack in a similar div since we have to shove in additional elements
      # taken from: https://github.com/rstudio/shinydashboard/blob/master/R/boxes.R
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
          plotOutput(ns('plot'), height=370)  
        ),
        # TODO: conditionalPanel which only displays the buttons when the relevant data is loaded
        div(class='box-footer', 
          conditionalPanel(
            condition=paste0('output[\"', ns('plot'),'\"] != undefined'),
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
  
  output$download_report <- downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = function() {
      name <- 'SCoPE_QC_Report'
      switch(input$report_format,
             html=paste0(name, '.html'),
             pdf=paste0(name, '.pdf'))
    },
    content = function(file) {
      
      # init progress bar
      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(message='', value=0)
      
      # first 5% is init
      # next 45% will be gathering materials
      # leave last 50% for rmarkdown rendering
      progress$inc(5/100, detail='Initializing')
      
      report <- paste(
        '---',
        'title: SCoPE QC Report',
        'output:',
      sep='\n')
      
      if(input$report_format == 'pdf') {
        report <- paste(report,
          '  pdf_document:',
          #'    header-includes:',
          #'      - \\usepackage{xcolor}',
          #'      - \\usepackage{framed}',
          #'      - \\usepackage{color}',
          '    fig_caption: false',
        sep='\n')
      } else {
        # default: HTML
        .theme <- input$report_theme
        report <- paste(report,
          '  html_document:',
          paste0('    theme: ', .theme),
          #'    highlight: tango',
          '    fig_caption: false',
          '    df_print: paged',            
        sep='\n')
      }
      
      # add figure options
      report <- paste(report,
        paste0('    fig_width: ', input$report_figure_width),
        paste0('    fig_height: ', input$report_figure_height),
        paste0('    dev: ', input$report_figure_format),
      sep='\n')
      
      # add params
      report <- paste(report,
        'params:',
        '  plots: NA',
        '---',
        '# {.tabset}',
      sep='\n')
      
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
          
          # increment progress bar
          progress$inc(0.45/length(modules), detail=paste0('Adding module ', .m, 'from tab ', .t))
          
          report <<- paste(report,
            paste0('### ', module$boxTitle, ' {.plot-title}'),
            '',
            module$help,
            '',
            '```{r, echo=FALSE, warning = FALSE, message = FALSE}',
            'options( warn = -1 )',
            paste0('params[["plots"]][[', .t, ']][[', .m, ']]'),
            sep='\n')

          plots[[.m]] <<- tryCatch(module$plotFunc(filtered_data, input),
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
      
      # last 50% of progress
      progress$inc(5/100, detail='Writing temporary files')
      
      tempReport <- file.path(tempdir(), "tempReport.Rmd")
      write_file(x=report, path=tempReport, append=FALSE)
      
      progress$inc(5/100, detail='Rendering report (this may take a while)')
      
      rmarkdown::render(tempReport, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
      
      progress$inc(40/100, detail='Finishing')

    }
  )
})

