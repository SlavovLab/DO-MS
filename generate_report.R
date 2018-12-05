#############################################
###                                       ### 
### GENERATE R-MARKDOWN, HTML/PDF REPORT  ###
###                                       ###
#############################################


source('global.R')

download_report <- function(input, output, filtered_data, exp_sets) {
  output$download_report <- downloadHandler(
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
          progress$inc(0.45/length(modules), detail=paste0('Adding module ', .m, ' from tab ', .t))
          
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
            num_files <- length(exp_sets())
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
}