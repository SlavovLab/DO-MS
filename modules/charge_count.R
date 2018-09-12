init <- function() {

  tab <- 'Contamination'
  boxTitle <- 'Number of ions by charge state'
  help <- 'Plotting the frequency of charge states observed. This will give an
  if you are seeing mostly peptides or non-peptide species'
  source.file <- 'allPeptides'

  
  .validate <- function(data) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file,".txt")))
  }
  
  .plotdata <- function(data) {
    plotdata <- data()[[source.file]][,c("Raw.file","Charge")]
    
    plotdata$Charge[plotdata$Charge > 3] <- 4
    plotdata_charge <- count(plotdata, c("Raw.file","Charge"))
    
    hc <- aggregate(plotdata_charge$freq, 
                    by=list(Category=plotdata_charge$Raw.file,
                            plotdata_charge$Charge), 
                    FUN=sum)
    colnames(hc) <- c("Raw.file","Charge","Frequency")
    
    return(hc)
  }
  
  .plot <- function(data) {
    # validate
    .validate(data)
    # get plot data
    plotdata <- .plotdata(data)
    
    # Plot:
    ggplot(plotdata, aes(x=Raw.file, y=Frequency,colour=factor(Charge), group=Raw.file)) + 
      geom_point(size = 2) + 
      #ylab("Number") + 
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
