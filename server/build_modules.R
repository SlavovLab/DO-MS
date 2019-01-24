#########################################################
###                                                   ###
### BUILD MODULES                                     ###
### Load modules and tabs. Attach functionality and   ###
### define the UI layout                              ###
###                                                   ###
#########################################################

source('global.R')

# attach module outputs/buttons to functions
attach_module_outputs <- function(input, output, filtered_data, exp_sets) {

  # helper function to generate figure widths for figures with dynamic widths 
  dynamic_fig_width <- function(num_exps, width_per_exp) {
    # convert initial dynamic width (in pixels) to inches using PPI
    width_per_exp <- width_per_exp / input$ppi
    
    return(ceiling((width_per_exp * num_exps) + 1))
  }
  
  # helper function to download figure
  download_figure <- function(module, format) { function(file) {
    
    # create progress bar
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message='Generating Figure...', value=0)
    
    # use dynamic width, based on number of experiments
    fig_width <- input$download_figure_width
    if(!is.null(module$dynamic_width)) {
      fig_width <- dynamic_fig_width(isolate(length(exp_sets())), module$dynamic_width)
    }
    
    ggsave(filename=file, plot=module$plotFunc(filtered_data, input), 
           device=format, 
           units=input$download_figure_units,
           width=fig_width, 
           height=input$download_figure_height)
    
    # finish progress bar
    progress$inc(1, detail='')
  }}
  
  # helper function to download data
  download_data <- function(module) { function(file) {
    # create progress bar
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message='Gathering Data...', value=0)
    
    module$validateFunc(filtered_data, input)
    plotdata <- module$plotdataFunc(filtered_data, input)
    # TODO: options to configure output format (CSV, delimeters, quotes, etc)
    write_tsv(plotdata, path=file)
    
    # finish progress bar
    progress$inc(1, detail='')
  }}
  
  # load each module from the module list via. callModule
  # each module is loaded by passing the moduleFunc field of the module
  # data is only in one reactive named list -- passing in filtered_data
  #
  # need local({}) to isolate each instance of the for loop - or else the output
  # of each iteration will default to to the last one.
  # see: https://gist.github.com/wch/5436415/
  
  for(m in modules) { local({
    module <- m
    ns <- NS(module$id)
    
    # simple table output, no javascript
    if(module$type == 'table') {
      output[[ns('table')]] <- renderTable({
        module$plotFunc(filtered_data, input)
      })
      output[[ns('plot.ui')]] <- renderUI({
        tableOutput(ns('table'))
      })
    }
    
    # datatable (from DT package)
    else if (module$type == 'datatable') {
      # pull datatable options (customization) from module def
      datatable_options <- module$datatable_options
      if(is.null(datatable_options)) datatable_options <- list() # set to empty if not defined
      
      output[[ns('table')]] <- renderDataTable({  
        module$plotFunc(filtered_data, input) }, options=datatable_options)
      output[[ns('plot.ui')]] <- renderUI({
        dataTableOutput(ns('table'), width='100%', height='auto')
      })
    }
    
    # plain, unformatted text output
    else if (module$type == 'text') {
      output[[ns('text')]] <- renderText({ module$plotFunc(filtered_data, input) })
      output[[ns('plot.ui')]] <- renderUI({
        verbatimTextOutput(ns('text'))
      })
    }
    
    # plot output (image/plot object/ggplot object)
    else if (module$type == 'plot') {
      output[[ns('plot')]] <- renderPlot({
        module$plotFunc(filtered_data, input)
      })
      output[[ns('plot.ui')]] <- renderUI({
        
        # use dynamic width, based on number of experiments
        plot_width <- '100%'
        if(!is.null(module$dynamic_width)) {
          if(!is.null(exp_sets())) {
            num_files <- length(exp_sets())
            plot_width <- paste0((num_files * module$dynamic_width) + 50, 'px')
          } else plot_width='400px' # default width when no data is loaded - to preserve DOM layout
        }
        
        # pull plot height from module def. if null, default to 370px
        plot_height <- module$plot_height
        if(is.null(plot_height)) plot_height <- 370
        
        plotOutput(ns('plot'), width=plot_width, height=paste0(plot_height, 'px'))
      })
      
    }
    
    output[[ns('downloadPDF')]] <- downloadHandler(
      filename=function() { paste0(gsub('\\s', '_', module$boxTitle), '.pdf') },
      content=download_figure(module, 'pdf')
    )
    
    output[[ns('downloadPNG')]] <- downloadHandler(
      filename=function() { paste0(gsub('\\s', '_', module$boxTitle), '.png') },
      content=download_figure(module, 'png')
    )
    
    output[[ns('downloadData')]] <- downloadHandler(
      filename=function() { paste0(gsub('\\s', '_', module$boxTitle), '.txt') },
      content=download_data(module)
    )
  }) }
}


plot_footer <- function(ns) {
  # only display the below buttons when the plot is displayed
  # (i.e. the required data is loaded)
  conditionalPanel(
    condition=paste0('output[\"', ns('plot'),'\"] != undefined'),
    div(class='row', style='height:30px',
        column(width=4, downloadButtonFixed(ns('downloadPDF'), label='PDF')),
        column(width=4, downloadButtonFixed(ns('downloadPNG'), label='PNG')),
        column(width=4, downloadButtonFixed(ns('downloadData'), label='Data'))
    )
  )
}

table_footer <- function(ns) {
  conditionalPanel(
    condition=paste0('output[\"', ns('table'),'\"] != undefined'),
    div(class='row', style='height:30px',
        column(width=12, downloadButtonFixed(ns('downloadData'), label='Data'))
    )
  )
}

no_footer <- function(ns) { div(class='empty-footer') }


render_modules <- function(input, output) {
  # need local({}) to isolate each instance of the for loop - or else the output
  # of each iteration will default to to the last one.
  # see: https://gist.github.com/wch/5436415/
  for(tab in tabs) { local({
    modules_in_tab <- modules[sapply(modules, function(module) { 
      gsub('([0-9])+(\\s|_)', '', module$tab) == tab 
    })]
    
    plots <- lapply(modules_in_tab, function(module) {
      ns <- NS(module$id)
      
      # derive box height from plot height from module def. if null, default to 370px
      plot_height <- module$plot_height
      if(is.null(plot_height)) plot_height <- 370
      box_height <- plot_height + 30 # add footer_height (30px)
      
      # pull box width from module def. if null, default to 6 (50%)
      box_width <- module$box_width
      if(is.null(box_width)) box_width <- 6
      box_width <- round(box_width) # enforce integer
      if(box_width < 1) box_width <- 1; if(box_width > 12) box_width <- 12 # enforce limits (1-12)
      
      # instead of using box() as provided by shinydashboard,
      # we're going to hack in a similar div since we have to shove in additional elements
      # taken from: https://github.com/rstudio/shinydashboard/blob/master/R/boxes.R
      return(div(class=paste0('col-sm-', box_width), div(class='box box-solid', style='',
        # header
        div(class='box-header',
          h3(class='box-title', module$boxTitle),
           
            # tooltip information:
            # https://getbootstrap.com/docs/3.3/javascript/#tooltips
            
            tags$button(class='btn btn-secondary tooltip-btn', 
                       `data-toggle`='tooltip', `data-placement`='right', title=module$help,
                       icon('question-sign', lib='glyphicon')  
            ),
           
            div(class='box-tools pull-right',
                tags$button(class='btn btn-box-tool', `data-widget`='collapse',
                            shiny::icon('minus'))
          )
        ),
        div(class='box-body plot-module-body', style=paste0('height:', box_height, 'px;'),
          uiOutput(ns('plot.ui'))
        ),
        div(class='box-footer', 
          switch(module$type,
                 plot=plot_footer(ns),
                 table=table_footer(ns),
                 datatable=table_footer(ns),
                 text=no_footer(ns))
        )
      )))
    })
    output[[tab]] <- renderUI(plots)
  }) }
}