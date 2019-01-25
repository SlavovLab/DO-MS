init <- function() {
  
  tab <- '010 Chromatography'
  boxTitle <- 'Retention length of peptides at base'
  help <- 'Plotting the retention length of identified peptide peaks at the base.'
  type <- 'plot'
  source.file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(
      data()[[source.file]],
      paste0("Upload ", source.file,".txt")
    ))
    validate(need( 
      'Retention.length' %in% colnames(data()[[source.file]]),
      'Column "Retention length" not found. Please run search with "Calculate peak properties" enabled (under Global Parameters/Advanced) in order to generate this column in the MaxQuant output.'
    ))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source.file]][,c("Raw.file","Retention.length","PEP")]
    plotdata$Retention.length <- plotdata$Retention.length*60
    plotdata$Retention.length[plotdata$Retention.length > 120] <- 120
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata, aes(Retention.length)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins=120) + 
      coord_flip() + 
      labs(x='Retention Lengths at base (sec)', y='Count') +
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
