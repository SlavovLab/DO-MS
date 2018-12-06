init <- function() {
  
  tab <- '040 Contamination'
  boxTitle <- 'TIC of ions by charge state'
  help <- 'Plotting the TIC of charge states observed. This will give an idea if you are seeing mostly peptides or non-peptide species'
  source.file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file,".txt")))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source.file]][,c("Raw.file","Charge","Intensity")]
    
    # aggregate charge states greater than 3
    plotdata$Charge[plotdata$Charge > 3] <- 4
    # make sure that no intensities are 0 -- will trip up the log10 scale
    plotdata$Intensity[plotdata$Intensity == 0] <- NA
    
    hc <- aggregate(plotdata$Intensity, 
                    by=list(Category=plotdata$Raw.file, plotdata$Charge), 
                    FUN=function(x) { sum(as.numeric(x)) })
    colnames(hc) <- c("Raw.file","Charge","Intensity")
    
    return(hc)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata) + 
      #geom_point(aes(x=Raw.file, y=Intensity,colour=factor(Charge), group=Raw.file), size = 2) + 
      geom_bar(aes(x=Raw.file, y=Intensity, fill=factor(Charge), group=Raw.file), 
               stat='identity', position='dodge2') +
      scale_y_log10() + 
      scale_fill_hue(labels = c("1","2","3",">3")) + 
      labs(x = "Experiment", y = "Total Ion Current", fill = "Charge State") +
    theme_base(input=input, show_legend=T)
    
  }
  
  return(list(
    tab=tab,
    boxTitle=boxTitle,
    help=help,
    source.file=source.file,
    validateFunc=.validate,
    plotdataFunc=.plotdata,
    plotFunc=.plot,
    dynamic_width=50
  ))
}
