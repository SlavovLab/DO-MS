init <- function() {
  
  tab <- 'Instrument'
  boxTitle <- 'Precursor Apex Offset'
  help <- 'help text for module'
  source.file <- 'msmsScans'
  
  .validate <- function(data) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file, '.txt')))
  }
  
  .plotdata <- function(data) {
    plotdata <- data()[[source.file]][,c("Raw.file","Precursor.apex.offset.time")]
    plotdata$Precursor.apex.offset.time <- plotdata$Precursor.apex.offset.time*60
    plotdata$Precursor.apex.offset.time[plotdata$Precursor.apex.offset.time > 8] <- 9
    plotdata$Precursor.apex.offset.time[plotdata$Precursor.apex.offset.time < -8] <- -9
    return(plotdata)
  }
  
  .plot <- function(data) {
    .validate(data)
    plotdata <- .plotdata(data)
    
    ggplot(plotdata, aes(Precursor.apex.offset.time)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram() + 
      coord_flip() + 
      xlab("Apex Offset (sec)") +
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
