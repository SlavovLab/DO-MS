#########################################################
###                                                   ###
### BUILD MODULES                                     ###
### Load modules and tabs. Attach functionality and   ###
### define the UI layout                              ###
###                                                   ###
#########################################################

source('global.R')

# attach module outputs/buttons to functions
attach_module_outputs <- function(input, output, filtered_data) {
  
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
    
    output[[ns('plot')]] <- renderPlot({ 
      m$plotFunc(filtered_data, input)
    })
    
    output[[ns('downloadPDF')]] <- downloadHandler(
      filename=function() { paste0(gsub('\\s', '_', m$boxTitle), '.pdf') },
      content=function(file) {
        ggsave(filename=file, plot=m$plotFunc(filtered_data, input), 
               device='pdf', 
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
        div(class='box-body',
          plotOutput(ns('plot'), height=370)  
        ),
        div(class='box-footer', 
          # only display the below buttons when the plot is displayed
          # (i.e. the required data is loaded)
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
}