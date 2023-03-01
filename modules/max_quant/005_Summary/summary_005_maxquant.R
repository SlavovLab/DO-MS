init <- function() {
  
  type <- 'text'
  box_title <- 'MaxQuant Search Summary'
  help_text <- 'MaxQuant Search Summary'
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
    
    # return a string
    paste(
      paste0('MaxQuant Version: ', 
             paste(unique(as.character(plotdata[plotdata$Parameter == 'Version',-1])), collapse=', ') ),
      paste0('Search Date: ', 
             paste(unique(as.character(plotdata[plotdata$Parameter == 'Date of writing',-1])), collapse=', ') ),
      paste0('FASTA File: ', 
             paste(unique(as.character(plotdata[plotdata$Parameter == 'Fasta file',-1])), collapse=', ') ),
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

