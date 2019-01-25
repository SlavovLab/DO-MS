init <- function() {
  
  boxTitle <- 'Miscleavage rate'
  help <- 'Plotting frequency of peptide miscleavages.'
  type <- 'plot'
  source.file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file,".txt")))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source.file]][,c("Raw.file","Missed.cleavages","PEP")]
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata, aes(Missed.cleavages)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins=10) + 
      coord_flip() + 
      labs(x="Missed Cleavages", y='Count') +
      theme_base(input=input)
  }
  
  return(list(
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
