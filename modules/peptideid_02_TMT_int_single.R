init <- function() {
  
  tab <- '030 Peptide Identifications'
  boxTitle <- 'Reporter ion intensity'
  help <- 'Plotting the TMT reporter intensities for a single run.'
  source.file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file,".txt")))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- dplyr::select(data()[[source.file]],starts_with("Reporter.intensity.corrected"))
    plotdata <- melt(plotdata)
    plotdata$log10tran <- log10(plotdata$value)
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    uniqueLabelsSize <- length(unique(plotdata$variable))
    TMTlabels <- c("C1","C2","C3","C4","C5","C6","C7","C8","C9","C10","C11")
    plot2Labels <- TMTlabels[1:uniqueLabelsSize]
    
    ggplot(plotdata,aes(x=variable,y=log10tran))+ 
      geom_violin(aes(group=variable,colour=variable,fill=variable), alpha=0.5, 
                  kernel="rectangular")+    # passes to stat_density, makes violin rectangular 
      xlab("TMT Channel")+             
      ylab(expression(bold("Log"[10]*" RI Intensity")))+ 
      theme_bw() +                     # make white background on plot
      theme_base(input=input) +
      scale_x_discrete(name ="TMT Channel", labels=plot2Labels) 
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
