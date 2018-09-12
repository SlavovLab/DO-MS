init <- function() {

  tab <- 'Instrument'
  boxTitle <- 'Retention Lengths (FWHM)'
  help <- 'help text for module'
  source.file <- 'allPeptides'
  
  .validate <- function(data) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file, '.txt')))
  }
  
  .plotdata <- function(data) {
    plotdata <- data()[[source.file]][,c("Raw.file","Retention.length..FWHM.")]
    
    plotdata$Retention.length..FWHM.[plotdata$Retention.length..FWHM. > 45] <- 49
    return(plotdata)
  }
  
  .plot <- function(data) {
    .validate(data)
    plotdata <- .plotdata(data)
    
    ggplot(plotdata, aes(Retention.length..FWHM.)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins = 49) + 
      coord_flip() + 
      xlab("Retention Length FWHM (sec)") +
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
