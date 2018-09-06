#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


source('global.R')

shinyServer(function(input, output, session) {
  
  #Reactive element for importing evidence.txt file
  ## RAW FILES
  
  evidence <- reactive({
    file1 <- input$file
    if(is.null(file1)){return()}
    read.delim(file=file1$datapath, header=TRUE)
    #evi <- data()
    #evLevels <- levels(evi$Raw.file)
    #updateSelectizeInput(session, 'Exp_Sets', choices = eviLevels, server = TRUE)
  })
  
  ## Apply filters
  
  ## Filtered data
  
  
  
  # all_data <- reactive({
  #   list(evidence, msms, ....)
  # })
  
  # observe({
  #   evi <- data()
  #   
  #   print(evi)
  # })
  
  #a <- callModule(linkedScatter, "scatters", df = data )
  for(module in module_names) {
    a <- callModule(eval(parse(text=paste0(module, 'Module'))), module, 
                    evidence=evidence)
  }
  
  # for tab in tabs {
  #   modules_in_tab <- get_modules_belonging_to_this_tab()
  #   plot_list[tab] <- lapply(modules_in_tab, {
  #      plotname
  #      ns <- NS(plotname)
  #   })
  #   
  # }
  # for tab in tabs {
  #   output[[tab]] <- renderUI({
  #     do.call(tagList, plot_list[tab])
  #   })
  # }
  
  eval(parse(text=paste0('test', 'Tab')))
  
  output$plots <- renderUI({
    plot_output_list <- lapply(1:length(module_names), function(i) {
      #plotname <- paste("plot", i, sep="")
      plotname <- module_names[i]
      ns <- NS(plotname)
      fluidRow(
        # boxTitle, help
        column(8, plotOutput(ns('plot'), height = 280, width = 250)),
        column(4, panel(
          fixedRow(
            downloadButtonFixed(ns('downloadPDF'), label='Download PDF')
          ),
          fixedRow(
            downloadButtonFixed(ns('downloadPNG'), label='Download PNG')
          ),
          fixedRow(
            downloadButtonFixed(ns('downloadData'), label='Download Data')
          )
        ))
      )
    })
    
    # Convert the list to a tagList - this is necessary for the list of items
    # to display properly.
    do.call(tagList, plot_output_list)
  })
  
})

