init <- function() {
  
  tab <- '005 Summary'
  boxTitle <- 'MaxQuant Experiment Summary'
  help <- 'MaxQuant experiment summary statistics'
  type <- 'datatable'
  source.file <- 'summary'
  
  .validate <- function(data, input) {
    validate(need(
      data()[['summary']],
      paste0("Upload summary")
    ))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['summary']] %>%
      arrange(Raw.file) %>%
      # put raw file and original raw file next to each other
      dplyr::select(Raw.file, Raw.file.orig, everything())
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    plotdata
  }
  
  return(list(
    tab=tab,
    type=type,
    boxTitle=boxTitle,
    help=help,
    source.file=source.file,
    validateFunc=.validate,
    plotdataFunc=.plotdata,
    plotFunc=.plot,
    datatable_options=list(
      pageLength=10,
      dom='lfptp',
      lengthMenu=c(5, 10, 15, 20, 50)
    ),
    box_width=12, # in bootstrap column units
    box_height=600 # pixels
  ))
}

