#############################################
###                                       ### 
### GENERATE R-MARKDOWN, HTML/PDF REPORT  ###
###                                       ###
#############################################


source('global.R')

download_report <- function(input, output, filtered_data, exp_sets) {
  output$download_report <- downloadHandler(
    filename = function() {
      name <- 'DO-MS_Report'
      switch(input$report_format,
             html=paste0(name, '.html'),
             pdf=paste0(name, '.pdf'))
    },
    content = function(file) { generate_report(input, filtered_data, exp_sets(), file, progress_bar=TRUE)  }
  )
}

# helper function, also used by do-ms_cmd.R
generate_report <- function(input, filtered_data, exp_sets, file, progress_bar=FALSE) {
  
  # init progress bar
  if(progress_bar) {
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message='', value=0)
  
    # first 5% is init
    # next 45% will be gathering materials
    # leave last 50% for rmarkdown rendering
    progress$inc(5/100, detail='Initializing')
  }
    
  report <- paste(
    '---',
    'title: DO-MS Report',
    'date: "`r format(Sys.time(), \'Generated: %Y-%m-%d    %H:%M:%S\')`"',
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
                  '  meta: NA',
                  '---',
                  '# {.tabset}',
                  sep='\n')
  
  params <- list()
  params[['plots']] <- list()
  params[['meta']] <- list()
  
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
    meta <- list() # module metadata
    
    for(m in 1:length(modules_in_tab)) { local({
      .m <- m
      module <- modules_in_tab[[.m]]
      
      if(progress_bar) {
        progress$inc(0.45/length(modules), detail=paste0('Adding module ', .m, ' from tab ', .t))
      }
      
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
        num_files <- length(exp_sets)
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
                       sep='\n')
      
      # render plot for the module. varies based on module plot type
      render_obj <- ''
      
      # for plots, can just dump the object and Rmarkdown will take care of the rest.
      if(module$type == 'plot') {
        report <<- paste(report, paste0('params[["plots"]][[', .t, ']][[', .m, ']]'), sep='\n')
      } 
      
      # for datatable widget
      else if (module$type == 'datatable') {
        # render an htmlwidget object which then becomes interactive in the HTML report
        if(input$report_format == 'html') {
        # pull in datatable options from the meta object for this module
        report <<- paste(report, 
                         paste0('datatable(params[["plots"]][[', .t, ']][[', .m, ']], ',
                                'options=ifelse(is.null(params[["meta"]][[',.t,']][[',.m,']][["datatable_options"]]), list(), params[["meta"]][[',.t,']][[',.m,']][["datatable_options"]])', ')'), 
                         sep='\n')
        } 
        # for PDF, render the table with kable
        else if (input$report_format == 'pdf') {
          report <<- paste(report, paste0('kable(params[["plots"]][[', .t, ']][[', .m, ']])'), sep='\n')
        }
      } 
      
      # for tables:
      else if (module$type == 'table') {
        # for HTML report, this is transformed neatly into the DOM automatically, no need to transform the output
        if(input$report_format == 'html') {
          report <<- paste(report, paste0('params[["plots"]][[', .t, ']][[', .m, ']]'), sep='\n')
        }
        # for PDF, need to render the table with the kable function
        else if(input$report_format == 'pdf') {
          report <<- paste(report, paste0('kable(params[["plots"]][[', .t, ']][[', .m, ']])'), sep='\n')
        }
      }
      
      # for text output, just render normally
      else if (module$type == 'text') {
        report <<- paste(report, paste0('params[["plots"]][[', .t, ']][[', .m, ']]'), sep='\n')
      }
      
      
      plots[[.m]] <<- tryCatch(module$plotFunc(filtered_data, input),
                               error = function(e) {
                                 # dummy plot
                                 #qplot(0, 0)
                                 paste0('Plot failed to render. Reason: ', e)
                               },
                               finally={}
      )
      # grab module metadata, but exclude function definitions to save space
      meta[[.m]] <<- module[!grepl('Func', names(module))]
      
      report <<- paste(report, '```', '', sep='\n')
      
      
    }) } # end module loop
    
    params[['plots']][[.t]] <<- plots
    params[['meta']][[.t]] <<- meta
    
    report <<- paste(report,
                     '',
                     sep='\n')
    
  }) } # end tab loop
  
  if(progress_bar) {
    # last 50% of progress
    progress$inc(5/100, detail='Writing temporary files')
  }
  
  tempReport <- file.path(tempdir(), "tempReport.Rmd")
  write_file(x=report, path=tempReport, append=FALSE)
  
  if(progress_bar) {
    progress$inc(5/100, detail='Rendering report (this may take a while)')
  }
  
  rmarkdown::render(tempReport, output_file = file,
                    params = params,
                    envir = new.env(parent = globalenv())
  )
  
  if(progress_bar) {
    progress$inc(40/100, detail='Finishing')
  }
}
