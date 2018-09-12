init <- function() {
  
  tab <- 'Instrument'
  boxTitle <- 'Retention Lengths for IDd Ions'
  help <- 'help text for module'
  source.file <- 'evidence'
  
  .validate <- function(data) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file, '.txt')))
  }
  
  .plotdata <- function(data) {
    plotdata <- data()[[source.file]][,c("Raw.file","Retention.length","PEP")]
    plotdata$Retention.length <- plotdata$Retention.length*60
    plotdata$Retention.length[plotdata$Retention.length > 120] <- 120
    return(plotdata)
  }
  
  .plot <- function(data) {
    .validate(data)
    plotdata <- .plotdata(data)
    
    validate(need(nrow(plotdata) > 0, 'No data available after filtering'))
    
    ggplot(plotdata, aes(Retention.length)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins=120) + 
      coord_flip() + 
      xlab('Retention Lengths at base (sec)') +
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
