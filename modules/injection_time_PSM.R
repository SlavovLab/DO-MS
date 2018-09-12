init <- function() {
  
  tab <- 'Sample Quality'
  boxTitle <- 'Injection times, PSM resulting'
  help <- 'Plotting distribution of injection times for MS2 events that did result in a PSM.'
  source.file <- 'msmsScans'
  
  .validate <- function(data) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file,".txt")))
  }
  
  .plotdata <- function(data) {
    plotdata <- data()[[source.file]][,c("Raw.file","Ion.injection.time", "Sequence")]
    plotdata <- plotdata[!is.na(plotdata$Sequence),]
    return(plotdata)
  }
  
  .plot <- function(data) {
    .validate(data)
    plotdata <- .plotdata(data)
    
    ggplot(plotdata, aes(Ion.injection.time)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram() + 
      coord_flip() + 
      xlab("Ion Injection Time (ms)") +
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
