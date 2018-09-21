init <- function() {
  
  tab <- 'Chromatography'
  boxTitle <- 'Identification frequency across gradient'
  help <- 'Plotting the frequency of peptide identification across thechromatographic gradient.'
  source.file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file,".txt")))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source.file]][,c("Raw.file","Retention.time","PEP")]
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    maxRT <- max(plotdata$Retention.time)
    ggplot(plotdata, aes(Retention.time)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins=100) + 
      coord_flip() + 
      xlim(10, maxRT) +
      theme_base(input=input)
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
