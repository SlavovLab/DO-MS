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
        ".csv",'.txt', options(shiny.maxRequestSize=300*1024^2) 
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
    # create the data list
    .data <- list()
    # loop thru all input files and add it to the data list
    for(file in input_files) {
      .file <- input[[file$name]]
      if(is.null(.file)){ break }
      # TODO: replace with readr read_tsv? or read_csv
      .data[[file$name]] <- read.delim(file=.file$datapath, header=TRUE)
    }
    
    ## TODO: Apply filters (PEP, experiment subsets, ....)
    
    ## Rename raw files?
    
    ## Filtered data
    
    # evidence_f
    # allPeptides_f ...
    
    # return the data list
    .data
  })
  
  # load each module from the module list via. callModule
  # each module is loaded by passing the moduleFunc field of the module
  # data is only in one reactive named list
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
      return(box(
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
})

