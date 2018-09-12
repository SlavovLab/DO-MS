init <- function() {
  
  tab <- 'Abundance'
  boxTitle <- 'MS1 Intensity for z>1 ions'
  help <- 'Plotting the MS1 intensity for all peptide-like ions observed (not necessarily sent to MS2) across runs.'
  source.file <- 'allPeptides'
  
  .validate <- function(data) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file,".txt")))
  }
  
  .plotdata <- function(data) {
    plotdata <- data()[[source.file]][,c("Raw.file","Charge", "Intensity")]
    plotdata$Intensity <- log10(plotdata$Intensity)
    plotdata <- plotdata[plotdata$Charge > 1,]
    return(plotdata)
  }
  
  .plot <- function(data) {
    .validate(data)
    plotdata <- .plotdata(data)
    
    ggplot(plotdata, aes(Intensity)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram() + 
      coord_flip() + 
      xlab(expression(bold("Log"[10]*" Precursor Intensity"))) +
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
