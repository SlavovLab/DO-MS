init <- function() {
  
  type <- 'text'
  box_title <- 'DIA-NN Experiments'
  help_text <- 'DIA-NN Experiments'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload parameters.txt')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['report']]
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    plotdata <- plotdata %>%
      dplyr::group_by(Raw.file, File.Name) %>%
      dplyr::summarise(n=n())
    
    outstr <- ''
    for (i in 1:length(plotdata$Raw.file)){
      str <- paste(plotdata$Raw.file[[i]], plotdata$File.Name[[i]])
      outstr <- paste0(outstr, str, sep='\n \n')
  
    }

    outstr
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

