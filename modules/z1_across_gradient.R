init <- function() {
  
  tab <- 'Contamination'
  boxTitle <- 'Intensity of z=1 across gradient'
  help <- 'Plotting the intensity of z=1 ions observed. This will give an
  if you are seeing mostly peptides or non-peptide species and where they occur
  in the gradient'
  source.file <- 'allPeptides'
  
  .validate <- function(data) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file,".txt")))
  }
  
  .plotdata <- function(data) {
    plotdata <- data()[[source.file]][,c("Raw.file","Charge","Intensity","Retention.time")]
    
    plotdata <- plotdata[plotdata$Charge == 1,]
    plotdata$Retention.time <- floor(plotdata$Retention.time)
    
    return(plotdata)
  }
  
  .plot <- function(data) {
    .validate(data)
    plotdata <- .plotdata(data)
    
    ggplot(plotdata, aes(x = Retention.time, y = Intensity)) + 
      geom_bar(stat = 'identity', width= 1) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      coord_flip() + 
      xlab("Retention Time (min)") + 
      ylab(expression(bold("Precursor Intensity"))) +
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
