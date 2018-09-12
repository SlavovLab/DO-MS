init <- function() {
  
  tab <- 'Instrument Performance'
  boxTitle <- 'Apex Offset'
  help <- 'Plotting the distance from the peak of the elution profile the MS2
    events were executed.'
  source.file<-"msmsScans"
  
  .validate <- function(data) {
    validate(need(data()[[source.file]], paste0("Upload ", source.file,".txt")))
  }
  
  .plotdata <- function(data) {
    plotdata <- data()[[source.file]][,c("Raw.file","Precursor.apex.offset.time")]
    
    plotdata$Precursor.apex.offset.time <- plotdata$Precursor.apex.offset.time * 60
    plotdata$Precursor.apex.offset.time[plotdata$Precursor.apex.offset.time > 8] <- 9
    plotdata$Precursor.apex.offset.time[plotdata$Precursor.apex.offset.time < -8] <- -9
    
    return(plotdata)
  }
  
  .plot <- function(data) {
    # validate
    .validate(data)
    # get plot data
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
