init <- function() {
  
  tab <- 'Contamination'
  boxTitle <- 'TIC of ions by charge state'
  help <- 'Plotting the TIC of charge states observed. This will give an idea if you are seeing mostly peptides or non-peptide species'
  source.file <- 'allPeptides'
  
  .validate <- function(data) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file,".txt")))
  }
  
  .plotdata <- function(data) {
    plotdata <- data()[[source.file]][,c("Raw.file","Charge","Intensity")]
    
    plotdata$Charge[plotdata$Charge > 3] <- 4
    hc <- aggregate(plotdata$Intensity, 
                    by=list(Category=plotdata$Raw.file, plotdata$Charge), 
                    FUN=sum)
    colnames(hc) <- c("Raw.file","Charge","Intensity")
    
    return(hc)
  }
  
  .plot <- function(data) {
    .validate(data)
    plotdata <- .plotdata(data)
    
    ggplot(plotdata, aes(x=Raw.file, y=Intensity,colour=factor(Charge), group=Raw.file)) + 
      geom_point(size = 2) + 
      ylab("Number") + 
      labs(x = "Experiment", y = "Total Ion Current", col = "Charge State") + 
      scale_y_log10() + 
      scale_color_hue(labels = c("1","2","3",">3")) + 
      labs(x = "Experiment", y = "Count", col = "Charge State") +
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
