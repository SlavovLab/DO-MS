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
    # PPI is static. maybe in the future make this dynamic based on the system
    # or graphics device
    ppi <- 75
    # convert initial dynamic width (in pixels) to inches using PPI
    width_per_exp <- width_per_exp / ppi
    
    return(ceiling((width_per_exp * num_exps) + 1))
  }
  
  # helper function to download figure
  download_figure <- function(m, format) { function(file) {
    
    # create progress bar
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message='Generating Figure...', value=0)
    
    # use dynamic width, based on number of experiments
    fig_width <- input$download_figure_width
    if(!is.null(m$dynamic_width)) {
      fig_width <- dynamic_fig_width(isolate(length(exp_sets())), m$dynamic_width)
    }
    
    ggsave(filename=file, plot=m$plotFunc(filtered_data, input), 
           device=format, 
           units=input$download_figure_units,
           width=fig_width, 
           height=input$download_figure_height)
    
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
  
  for(module in modules) { local({
    m <- module
    ns <- NS(m$id)
    
    if(m$type == 'table') {
      
      # table type
      output[[ns('table')]] <- renderTable({
        m$plotFunc(filtered_data, input)
      })
      
      output[[ns('plot.ui')]] <- renderUI({
        tableOutput(ns('table'))
      })
      
    } else if (m$type == 'plot') {
      
      # plot type
      output[[ns('plot')]] <- renderPlot({
        m$plotFunc(filtered_data, input)
      })
      
      output[[ns('plot.ui')]] <- renderUI({
        
        # use dynamic width, based on number of experiments
        plot_width <- '100%'
        if(!is.null(m$dynamic_width)) {
          if(!is.null(exp_sets())) {
            num_files <- length(exp_sets())
            plot_width <- paste0((num_files * m$dynamic_width) + 50, 'px')
          } else {
            plot_width='400px'
          }
        }
        
        plotOutput(ns('plot'), width=plot_width, height='370px')
      })
      
    }
    
    output[[ns('downloadPDF')]] <- downloadHandler(
      filename=function() { paste0(gsub('\\s', '_', m$boxTitle), '.pdf') },
      content=download_figure(m, 'pdf')
    )
    
    output[[ns('downloadPNG')]] <- downloadHandler(
      filename=function() { paste0(gsub('\\s', '_', m$boxTitle), '.png') },
      content=download_figure(m, 'png')
    )
    
    output[[ns('downloadData')]] <- downloadHandler(
      filename=function() { paste0(gsub('\\s', '_', m$boxTitle), '.txt') },
      content=function(file) {
        
        # create progress bar
        progress <- shiny::Progress$new()
        on.exit(progress$close())
        progress$set(message='Gathering Data...', value=0)
        
        m$validateFunc(filtered_data, input)
        plotdata <- m$plotdataFunc(filtered_data, input)
        write_tsv(plotdata, path=file)
        
        # finish progress bar
        progress$inc(1, detail='')
      }
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


render_modules <- function(input, output) {
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
      return(div(class='col-sm-6', div(class='box box-solid', style='',
        # header
        div(class='box-header',
          h3(class='box-title', m$boxTitle),
           
            # tooltip information:
            # https://getbootstrap.com/docs/3.3/javascript/#tooltips
            
            tags$button(class='btn btn-secondary tooltip-btn', 
                       `data-toggle`='tooltip', `data-placement`='right', title=m$help,
                       icon('question-sign', lib='glyphicon')  
            ),
           
            div(class='box-tools pull-right',
                tags$button(class='btn btn-box-tool', `data-widget`='collapse',
                            shiny::icon('minus'))
          )
        ),
        div(class='box-body plot-module-body',
          uiOutput(ns('plot.ui'))
        ),
        div(class='box-footer', 
          switch(m$type,
                 plot=plot_footer(ns),
                 table=table_footer(ns))
        )
      )))
    })
    output[[tab]] <- renderUI(plots)
  }) }
}