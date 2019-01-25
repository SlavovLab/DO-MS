init <- function() {
  
  boxTitle <- 'MaxQuant Search Summary'
  help <- 'MaxQuant Search Summary'
  type <- 'text'
  source.file <- 'parameters'
  
  .validate <- function(data, input) {
    validate(need(
      data()[[source.file]],
      paste0('Upload ', source.file, '.txt')
    ))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source.file]]
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    # return a string
    paste(
      paste0('MaxQuant Version: ', 
             paste(unique(plotdata$Value[plotdata$Parameter == 'Version']), collapse=', ') ),
      paste0('Search Date: ', 
             paste(unique(plotdata$Value[plotdata$Parameter == 'Date of writing']), collapse=', ') ),
      paste0('FASTA File: ', 
             paste(unique(plotdata$Value[plotdata$Parameter == 'Fasta file']), collapse=', ') ),
    sep='\n\n')
  }
  
  return(list(
    type=type,
    boxTitle=boxTitle,
    help=help,
    source.file=source.file,
    validateFunc=.validate,
    plotdataFunc=.plotdata,
    plotFunc=.plot
  ))
}

