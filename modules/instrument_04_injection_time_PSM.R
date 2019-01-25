init <- function() {
  
  tab <- '020 Instrument Performance'
  boxTitle <- 'Injection times, PSM resulting'
  help <- 'Plotting distribution of injection times for MS2 events that did result in a PSM.'
  type <- 'plot'
  source.file <- 'msmsScans'
  
  .validate <- function(data, input) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file,".txt")))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source.file]][,c("Raw.file","Ion.injection.time", "Sequence")]
    plotdata <- plotdata[!is.na(plotdata$Sequence),]
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata, aes(Ion.injection.time)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram() + 
      coord_flip() + 
      labs(x="Ion Injection Time (ms)", y='Count') +
      theme_base(input=input)
  }
  
  return(list(
    tab=tab,
    type=type,
    boxTitle=boxTitle,
    help=help,
    source.file=source.file,
    validateFunc=.validate,
    plotdataFunc=.plotdata,
    plotFunc=.plot,
    dynamic_width=150
  ))
}
