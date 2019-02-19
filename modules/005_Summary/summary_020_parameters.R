init <- function() {
  
  type <- 'datatable'
  box_title <- 'MaxQuant Parameters'
  help_text <- 'MaxQuant Search Parameters'
  source_file <- 'parameters'
  
  .validate <- function(data, input) {
    validate(need(data()[['parameters']], paste0('Upload parameters.txt')))
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
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    datatable_options=list(
      pageLength=10,
      dom='lfptp',
      lengthMenu=c(5, 10, 15, 20, 50)
    ),
    box_width=12, # in bootstrap column units
    box_height=600 # pixels
  ))
}

