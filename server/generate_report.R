#############################################
###                                       ### 
### GENERATE R-MARKDOWN, HTML/PDF REPORT  ###
###                                       ###
#############################################

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
  
  # check if pandoc exists
  rmarkdown::pandoc_available(error=T)
  
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
  
  pep_max<-signif(max(filtered_data()[['evidence']][,"PEP"]),2)  
  
  report <- paste(
    '---',
    paste0('title: DO-MS Report'
    ),
    paste0('date: "`r paste0(\'Version: ', version, " | PEP < ",pep_max, ' | \',  format(Sys.time(), \'Generated: %Y-%m-%d    %H:%M:%S\'))`"'),
    'output:',
#    paste0('data filtered to PEP < ',
#           pep_max),
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
  
  # get number of total modules, so we can update the progress bar accordingly
  num_modules <- 0
  for(t in 1:length(tabs)) { for(m in 1:length(modules[[t]])) {
    num_modules <- num_modules + 1
  }}
  
  for(t in 1:length(tabs)) { local({
    
    # need to create copies of these indices in the local environment
    # otherwise, the indices will be frozen for each iteration, only generating the last one
    .t <- t
    tab <- tabs[.t]
    
    report <<- paste(report,
                     paste0('## ', tab),
                     sep='\n')
    
    modules_in_tab <- modules[[.t]]
    
    plots <- list()
    meta <- list() # module metadata
    
    for(m in 1:length(modules_in_tab)) { local({
      .m <- m
      module <- modules_in_tab[[.m]]
      
      # debugging:
      # print(paste0('tab ', .t))
      # print(paste0('module ', .m))
      
      if(progress_bar) {
        progress$inc(0.45/num_modules, detail=paste0('Adding module ', .m, ' from tab ', .t))
      }
      
      # create chunk name from module box title
      chunk_name <- module$id
      chunk_name <- gsub('\\s', '_', chunk_name)
      chunk_name <- gsub('[=-\\.]', '_', chunk_name)
      
      # if dynamic plot width is defined, then inject that into this
      # R-markdown chunk instead
      # because dynamic width is defined in pixels -- need to convert to inches
      
      plot_width = NA
      if(!is.null(module$dynamic_width)) {
        num_files <- length(exp_sets)
        plot_width <- num_files * module$dynamic_width / input$ppi
        
        # allow for a base width. useful for plots where a legend can
        # take up a fixed amount of horizontal space
        if(!is.null(module$dynamic_width_base)) {
          # units are in pixels, so convert to inches using ppi
          plot_width <- plot_width + (module$dynamic_width_base / input$ppi)
        } else {
          # by default, add an inch of padding
          plot_width <- plot_width + 1
        }
        
        # round up to an integer
        plot_width <- ceiling(plot_width)
      }
      
      # override existing/default plot width if it is explicitly defined
      if(!is.null(module$report_plot_width)) {
        plot_width <- module$report_plot_width
      }
      
      # if plot width was defined, then insert it into the block def
      if(!is.na(plot_width)) { plot_width <- paste0(', fig.width=', plot_width) }
      else { plot_width <- '' }
      
      plot_height <- ''
      # override existing/default plot height if it is explicitly defined
      if(!is.null(module$report_plot_height)) {
        plot_height <- paste0(', fig.height=', module$report_plot_height)
      }
      
      # prevent further processing with 'results=asis' flag?
      results_flag <- ''
      if(module$type == 'text') {
        results_flag <- ", results='asis'"
      }
      
      report <<- paste(report,
                       paste0('### ', module$box_title, ' {.plot-title}'), '',
                       module$help, '',
                       paste0('```{r ', chunk_name, ', echo=FALSE, warning = FALSE, message = FALSE', 
                              # custom width/height definition
                              plot_width, plot_height, 
                              # results flag
                              results_flag,
                              '}'),
                       'options( warn = -1 )',
                       sep='\n')
      
      # call helper function to decide what to do with this module + report format
      report <<- paste(report, render_module(.t, .m, module$type, input$report_format), sep='\n')
      
      
      # store the output from the module plot function
      plots[[.m]] <<- tryCatch(module$plot_func(filtered_data, input),
        error = function(e) { paste0('Plot failed to render. Reason: ', e) },
        finally={}
      )
      
      # if this plot is a text, sanitize the text
      if(module$type == 'text') {
        plots[[.m]] <<- sanitize_text_output(plots[[.m]])
      }
      # if this plot is a table, sanitize the text in every cell in the table
      # note: sanitize_text_output ignores non-character values so don't worry about
      #       inadvertently typecasting doubles or logicals to characters
      if(module$type %in% c('table', 'datatable') & class(plots[[.m]]) != 'character') {
        plots[[.m]] <<- plots[[.m]] %>%
          dplyr::mutate_all(sanitize_text_output) %>%
          dplyr::rename_all(sanitize_text_output)
      }
      
      # grab module metadata, but exclude function definitions to save space
      meta[[.m]] <<- module[!grepl('Func', names(module))]
      
      # end chunk
      report <<- paste(report, '```', '', sep='\n')
      
    }) } # end module loop
    
    # deposit plot and meta structures into the tab entry in parameters
    params[['plots']][[.t]] <<- plots
    params[['meta']][[.t]] <<- meta
    
    # extra newline at end
    report <<- paste(report, '', sep='\n')
    
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
                    params = params, envir = new.env(parent = globalenv())
  )
  
  if(progress_bar) {
    progress$inc(40/100, detail='Finishing')
  }
}

# helper function for deciding how to render each module
render_module <- function(tab_index, module_index, type, format) {

  render_code <- ''
  
  if(format == 'pdf') {
    
    if(type == 'plot') {
      render_code <- paste0('params[["plots"]][[', tab_index, ']][[', module_index, ']]')
    }
    else if(type == 'table') {
      # for PDF, need to render the table with the kable function
      render_code <- paste0('kable(params[["plots"]][[', tab_index, ']][[', module_index, ']])')
    }
    else if(type == 'datatable') {
      render_code <- paste0('kable(params[["plots"]][[', tab_index, ']][[', module_index, ']])')
    }
    else if(type == 'text') {
      render_code <- paste0('cat(params[["plots"]][[', tab_index, ']][[', module_index, ']])')
    }
    
  } 
  else if(format == 'html') {
    
    if(type == 'plot') {
      render_code <- paste0('params[["plots"]][[', tab_index, ']][[', module_index, ']]')
    }
    else if(type == 'table') {
      # for HTML report, this is transformed neatly into the DOM automatically, no need to transform the output
      render_code <- paste0('params[["plots"]][[', tab_index, ']][[', module_index, ']]')
    }
    # render an htmlwidget object which then becomes interactive in the HTML report
    else if(type == 'datatable') {
      # pull in datatable options from the meta object for this module
      render_code <- paste0('if("data.frame" %in% class(params[["plots"]][[', tab_index, ']][[', module_index, ']])) {')
      render_code <- paste0(render_code, 'datatable(params[["plots"]][[', tab_index, ']][[', module_index, ']], ',
        'options=ifelse(is.null(params[["meta"]][[', tab_index, ']][[', module_index, ']][["datatable_options"]]), ',
        'list(), params[["meta"]][[', tab_index, ']][[', module_index, ']][["datatable_options"]])', ')')
      # if not found, render as a table so that the validation error message shows
      render_code <- paste0(render_code, '} else {')
      render_code <- paste0(render_code, 'params[["plots"]][[', tab_index, ']][[', module_index, ']]')
      render_code <- paste0(render_code, '}')
    }
    else if(type == 'text') {
      render_code <- paste0('cat(params[["plots"]][[', tab_index, ']][[', module_index, ']])')
    }
  }
  
  return(render_code)
}


