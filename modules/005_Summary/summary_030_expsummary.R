init <- function() {
  
  type <- 'datatable'
  box_title <- 'MaxQuant Experiment Summary'
  help_text <- 'MaxQuant experiment summary statistics'
  source_file <- 'summary'
  
  .validate <- function(data, input) {
    validate(need(data()[['summary']], paste0('Upload summary.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['summary']] %>%
      dplyr::arrange(Raw.file) %>%
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

