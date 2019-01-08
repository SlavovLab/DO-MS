init <- function() {

  tab <- '040 Contamination'
  boxTitle <- 'Number of ions by charge state'
  help <- 'Plotting the frequency of charge states observed. This will give an
  if you are seeing mostly peptides or non-peptide species'
  source.file <- 'allPeptides'

  
  .validate <- function(data, input) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file,".txt")))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source.file]][,c("Raw.file","Charge")]
    
    plotdata$Charge[plotdata$Charge > 3] <- 4
    plotdata_charge <- plyr::count(plotdata, c("Raw.file","Charge"))
    
    hc <- aggregate(plotdata_charge$freq, 
                    by=list(Category=plotdata_charge$Raw.file,
                            plotdata_charge$Charge), 
                    FUN=function(x) { sum(as.numeric(x), na.rm=T) })
    colnames(hc) <- c("Raw.file","Charge","Frequency")
    
    return(hc)
  }
  
  .plot <- function(data, input) {
    # validate
    .validate(data, input)
    # get plot data
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata) + 
      #geom_point(aes(x=Raw.file, y=Frequency,colour=factor(Charge), group=Raw.file), size = 2) + 
      geom_bar(aes(x=Raw.file, y=Frequency, fill=factor(Charge), group=Raw.file), 
               stat='identity', position='dodge2') +
      scale_fill_hue(labels = c("1","2","3",">3")) + 
      labs(x = "Experiment", y = "Count", fill = "Charge State") +
      theme_base(input=input, show_legend=T)
  }
  
  return(list(
    tab=tab,
    boxTitle=boxTitle,
    help=help,
    source.file=source.file,
    validateFunc=.validate,
    plotdataFunc=.plotdata,
    plotFunc=.plot
    #dynamic_width=100
    
  ))
}
