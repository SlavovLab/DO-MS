init <- function() {
  
  type <- 'text'
  box_title <- 'MaxQuant Search Summary'
  help_text <- 'MaxQuant Search Summary'
  source_file <- 'parameters'
  
  .validate <- function(data, input) {
    validate(need(
      data()[[source_file]],
      paste0('Upload ', source_file, '.txt')
    ))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source_file]]
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
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot
  ))
}

