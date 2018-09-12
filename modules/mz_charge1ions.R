init <- function() {
  
  tab <- 'Contamination'
  boxTitle <- 'm/z Distribution for +1 ions'
  help <- 'Plotting the m/z distribution of +1 ions, a diagnostic of non-peptide contaminants'
  source.file <- 'allPeptides'
  
  .validate <- function(data) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file, ".txt")))
  }
  
  .plotdata <- function(data) {
    plotdata <- data()[[source.file]][,c('Raw.file', 'Charge', 'm.z')]
    return(plotdata)
  }
  
  .plot <- function(data) {
    .validate(data)
    plotdata <- .plotdata(data)
    
    facetHist(plotdata[plotdata$Charge == 1, ], "m.z")
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
