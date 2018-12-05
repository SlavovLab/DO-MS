init <- function() {
  
  tab <- '040 Contamination'
  boxTitle <- 'm/z Distribution for +1 ions'
  help <- 'Plotting the m/z distribution of +1 ions, a diagnostic of non-peptide contaminants'
  source.file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file, ".txt")))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source.file]][,c('Raw.file', 'Charge', 'm.z')]
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata[plotdata$Charge == 1, ], 'm.z') + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins=100) + 
      coord_flip() + 
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
