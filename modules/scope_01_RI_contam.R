init <- function() {
  
  tab <- '05 SCoPE-MS Diagnostics'
  boxTitle <- 'Reporter Ion Intensities vs. Carrier Intensities'
  help <- 'Comparing the reporter ion intensities for all TMT channels
  to the carrier channel, chosen automatically as the most intense 
  channel (median intensity).'
  source.file<-"msms"
  
  .validate <- function(data, input) {
    validate(need(data()[[source.file]], paste0("Upload ", source.file,".txt")))
    plotdata <- data()[[source.file]]
    validate(need((length(unique(plotdata[,"Raw.file"])) == 1),"Please select a single experiment"))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source.file]]
  
    uniqRaw<-unique(plotdata$Raw.file)
    
    RI<-colnames(plotdata)[ grep("Reporter.intensity.corrected", colnames(plotdata)) ]
    
    medianNA<-function(X){ median(X, na.rm = T) }
    
    medianRI<-sapply(plotdata[,RI], medianNA)
    
    maxRI<-names(medianRI)[medianRI==max(medianRI)]
    
    plotdata_melt<-melt(plotdata[,RI[RI!=maxRI] ])
    plotdata_melt$maxRI<-rep(plotdata[,maxRI], length(RI)-1)
    
    plotdata_melt[,c("value","maxRI")]<-log10(plotdata_melt[,c("value","maxRI")])
    colnames(plotdata_melt)<-c("TMT_RI","Other_Channels","Highest_Channel")
    plotdata_melt$Raw.file<-uniqRaw
    
    plotdata<-plotdata_melt
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    # validate
    .validate(data, input)
    # get plot data
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata, aes(x=Highest_Channel, y=Other_Channels)) + 
      xlab("Highest TMT Channel (log10)") +
      ylab("All Other TMT Channels (log10)") + 
      ggtitle(unique(plotdata$Raw.file)) + 
      geom_point(size = 0.1, alpha = 0.1) + 
      theme_base(input=input) + 
      theme(axis.text.x = element_text(angle=0, hjust = 0.5)) +
      geom_abline(intercept = 0, slope = 1, color = "red", size = 1)
    
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
