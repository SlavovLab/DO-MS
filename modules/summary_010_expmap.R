init <- function() {
  
  tab <- '005 Summary'
  boxTitle <- 'Experiment Map'
  help <- 'Map of raw file names to short names'
  type <- 'table'
  source.file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(
      data()[[source.file]],
      paste0('Upload ', source.file, '.txt')
    ))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source.file]] %>%
      dplyr::select(c('Raw.file','Raw.file.orig')) %>%
      distinct(Raw.file, .keep_all=T) %>%
      arrange(Raw.file) %>%
      rename(`Short name`=Raw.file,
             `Raw file`=Raw.file.orig)
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    # return the data
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
    plotFunc=.plot
  ))
}

