init <- function() {
  
  .validate <- function(data) {
    validate(need(data()[['evidence']],paste0("Upload ", 'evidence',".txt")))
  }
  
  .plotdata <- function(data) {
    plotdata <- data()[['evidence']][,c("Raw.file","Retention.length","PEP")]
    plotdata$Retention.length <- plotdata$Retention.length*60
    plotdata$Retention.length[plotdata$Retention.length > 120] <- 120
    return(plotdata)
  }
  
  .plot <- function(data) {
    .validate(data)
    plotdata <- .plotdata(data)
    
    ggplot(plotdata, aes(Retention.length)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins=120) + 
      coord_flip() + 
      xlab('Retention Lengths at base (sec)') +
      theme_base
  }
  
  return(list(
    tab='Instrument Performance',
    boxTitle='Retention length of peptides at base',
    help='Plotting the retention length of identified peptide peaks at the base.',
    validateFunc=.validate,
    plotdataFunc=.plotdata,
    plotFunc=.plot
  ))
}
