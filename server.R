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

  observe({
    print(data()[['evidence']])
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
  
  # collect all tab names
  tabs <- c()
  for(module in modules) {
    tabs <- c(tabs, module$tab)
  }
  tabs <- unique(tabs)
  
  sapply(modules, function(m) {
    m$tab == 'tab_2'
  })
  
  tab_plots <- list()
  for(tab in tabs) {
    modules_in_tab <- modules[sapply(modules, function(m) { m$tab == tab })]
    tab_plots[[tab]] <- lapply(modules_in_tab, function(m) {
       ns <- NS(m$id)
       return(panel(
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
  }
  
  output$tabs <- renderUI({
    data()
    do.call(tagList, lapply(tabs, function(tab) {
      tabItem(tab, tab_plots[[tab]])
    }))
  })
  
})

