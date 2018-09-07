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
  
  # modularize this?? list of reactives()
  
  data <- list()
  input_forms <- list()
  for(file in input_files) {
    input_forms[[file$name]] <- fileInput(
      file$name, file$help,
      accept = c(
        "text/csv",
        "text/comma-separated-values,text/plain",
        ".csv",'.txt', options(shiny.maxRequestSize=300*1024^2) 
      )
    )
  }
  data <- reactive({
    .data <- list()
    for(file in input_files) {
      .file <- input[[file$name]]
      if(is.null(.file)){ break }
      .data[[file$name]] <- read.delim(file=.file$datapath, header=TRUE)
    }
    .data
  })
  
  output$input_forms <- renderUI({
    do.call(tagList, input_forms)
  })

  ## Apply filters (PEP, experiment subsets, ....)
  
  ## Rename raw files?
  
  ## Filtered data
  
  # evidence_f
  # allPeptides_f ...
  
  # for(module in module_names) {
  #   a <- callModule(eval(parse(text=paste0(module, 'Module'))), module, 
  #                   data=data)
  # }
  for(module in modules) {
    callModule(module$moduleFunc, module$id, data=data)
  }
  
  # need local({}) to isolate each instance of the for loop - or else the output
  # of each iteration will default to to the last one.
  # see: https://gist.github.com/wch/5436415/
  for(tab in tabs) { local({
    modules_in_tab <- modules[sapply(modules, function(m) { m$tab == tab })]
    
    plots <- lapply(modules_in_tab, function(m) {
      ns <- NS(m$id)
      return(panel(
        h1(m$id),
        plotOutput(ns('plot'), height=280, width=250)
        # column(4, panel(
        #   fixedRow(
        #     downloadButtonFixed(ns('downloadPDF'), label='Download PDF')
        #   ),
        #   fixedRow(
        #     downloadButtonFixed(ns('downloadPNG'), label='Download PNG')
        #   ),
        #   fixedRow(
        #     downloadButtonFixed(ns('downloadData'), label='Download Data')
        #   )
        # ))
      ))
    })
    
    output[[tab]] <- renderUI(plots)
  }) }
  
  
  # output$tabs <- renderUI({
  #   
  #   
  #   tab_plots <- list()
  #   for(tab in tabs) {
  #     modules_in_tab <- modules[sapply(modules, function(m) { m$tab == tab })]
  #     tab_plots[[tab]] <- lapply(modules_in_tab, function(m) {
  #       ns <- NS(m$id)
  #       return(panel(
  #         plotOutput(ns('plot'), height=280, width=250)
  #         # column(4, panel(
  #         #   fixedRow(
  #         #     downloadButtonFixed(ns('downloadPDF'), label='Download PDF')
  #         #   ),
  #         #   fixedRow(
  #         #     downloadButtonFixed(ns('downloadPNG'), label='Download PNG')
  #         #   ),
  #         #   fixedRow(
  #         #     downloadButtonFixed(ns('downloadData'), label='Download Data')
  #         #   )
  #         # ))
  #       ))
  #     })
  #   }
  #   
  #   do.call(tabItems, lapply(tabs, function(tab) {
  #     tabItem(tab, tab_plots[[tab]])
  #   }))
  # })
  
})

