init <- function() {
  
  tab <- 'SCoPE-MS Diagnostics'
  boxTitle <- 'TMT Channel Spearman Correlations vs. Intensity'
  help <- 'Calculating the spearman correlation between the peptide quantitation in different
  TMT channels to the carry channel for every experiment, plotted against the median RI 
  intensity for that channel.'
  source.file<-"evidence"
  
  .validate <- function(data) {
    validate(need(data()[[source.file]], paste0("Upload ", source.file,".txt")))
  }
  
  .plotdata <- function(data) {
    plotdata <- data()[[source.file]]
  
    uniqRaw<-unique(plotdata$Raw.file)
    
    RI<-colnames(plotdata)[ grep("Reporter.intensity.corrected", colnames(plotdata)) ]
    
    
    medianNA<-function(X){ median(X, na.rm = T) }
    
    medianRI<-sapply(plotdata[,RI], medianNA)
    
    maxRI<-names(medianRI)[medianRI==max(medianRI)]
    
    rawName<-c()
    cor2carry<-c()
    medianRIs<-c()
    RInames<-c()
    for(X in uniqRaw){
      
      cor.temp<-c()
      for(Y in RI){
        
        cor.t<-cor( plotdata[plotdata$Raw.file==X, Y], plotdata[plotdata$Raw.file==X, maxRI], use="complete", method = "spearman" )
        
        cor.temp<-c(cor.temp, cor.t)
        
      }
      medianRI<-sapply(plotdata[,RI], medianNA)
      
      cor2carry<-c(cor2carry, cor.temp)
      RInames<-c(RInames, names(medianRI))
      medianRIs<-c(medianRIs, medianRI)
      rawName<-c(rawName, rep(X, length(medianRI)) )
      
    }
    
    df<-data.frame(rawName, RInames, medianRIs, cor2carry)
    df$medianRIs<-log10(df$medianRIs)
    colnames(df)<-c("Experiment", "RI", "MedianRI", "Correlation")
    
    plotdata<-df
    return(plotdata)
  }
  
  .plot <- function(data) {
    # validate
    .validate(data)
    # get plot data
    plotdata <- .plotdata(data)
    
    ggplot(plotdata, aes(x = Correlation, y = MedianRI, color = Experiment)) +
      geom_point(size = 1.5, alpha = 0.5) +
      theme_base + theme(axis.text.x = element_text(angle=0, hjust = 0.5),
                         axis.ticks.x=element_blank(),
                         axis.ticks.y=element_blank(),
                         legend.position = "right",
                         legend.key = element_rect(fill = "white"),
                         panel.background = element_rect(fill = "white",colour = "white")) + 
      ylab("Median Reporter Ion Intensity (log10)")
      
    
    
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
