init <- function() {
  
  boxTitle <- 'MaxQuant Parameters'
  help <- 'MaxQuant Search Parameters'
  type <- 'datatable'
  source.file <- 'parameters'
  
  .validate <- function(data, input) {
    validate(need(
      data()[['parameters']],
      paste0("Upload parameters.txt")
    ))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['parameters']]
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    plotdata
  }
  
  return(list(
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

