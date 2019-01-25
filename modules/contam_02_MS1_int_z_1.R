init <- function() {
  
  tab <- '040 Contamination'
  boxTitle <- 'MS1 Intensity, +1 ions'
  help <- 'Plotting the intensity distribution of +1 ions, a diagnostic of non-peptide contaminants'
  type <- 'plot'
  source.file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file,".txt")))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source.file]][,c('Raw.file', 'Charge', 'Intensity')]
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    plotdata$logInt <- log10(plotdata$Intensity)
    ggplot(plotdata[plotdata$Charge == 1, ], aes(logInt)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins=100) + 
      coord_flip() + 
      #scale_x_log10() +
      labs(y='Count', x=expression(bold("Log"[10]*" Intensity"))) +
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


