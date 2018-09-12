init <- function() {
  
  tab <- 'Instrument'
  boxTitle <- 'IDs by Retention Time'
  help <- 'help text for module'
  source.file <- 'evidence'
  
  .validate <- function(data) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file, '.txt')))
  }
  
  .plotdata <- function(data) {
    plotdata <- data()[[source.file]][,c("Raw.file","Retention.time","PEP")]
    return(plotdata)
  }
  
  .plot <- function(data) {
    .validate(data)
    plotdata <- .plotdata(data)
    
    maxRT <- max(plotdata$Retention.time)
    
    ggplot(plotdata, aes(Retention.time)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins=100) + 
      coord_flip() + 
      xlim(10, maxRT) +
      theme_base
  }
  
  return(list(
    tab=tab,
    boxTitle=boxTitle,
    help=help,
    source.file=source.file,
    validateFunc=.validate,
    plotdataFunc=.plotdata,
    plotFunc=.plot
  ))
}
