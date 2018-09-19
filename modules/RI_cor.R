init <- function() {
  
  tab <- 'SCoPE-MS Diagnostics'
  boxTitle <- 'TMT Channel Spearman Correlations'
  help <- 'Calculating the spearman correlation between the peptide quantitation in different
  TMT channels for every experiment.'
  source.file<-"evidence"
  
  .validate <- function(data, input) {
    validate(need(data()[[source.file]], paste0("Upload ", source.file,".txt")))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source.file]]
  
    uniqRaw<-unique(plotdata$Raw.file)
  
    RI<-colnames(plotdata)[ grep("Reporter.intensity.corrected", colnames(plotdata)) ]
    
    medianNA<-function(X){ median(X, na.rm = T) }
    
    medianRI<-sapply(plotdata[,RI], medianNA)
    
    maxRI<-names(medianRI)[medianRI==max(medianRI)]
    
    plotMat<-matrix(data = NA, nrow = length(uniqRaw), ncol = length(RI))
    for(i in 1:length(uniqRaw)){
      
      for(j in 1:length(RI)){
        
        plotMat[i,j]<-cor( plotdata[plotdata$Raw.file==uniqRaw[i], RI[j]] ,  
                           plotdata[plotdata$Raw.file==uniqRaw[i], maxRI] , 
                           use="complete", method = "spearman")
        
      }
      
    }
    
    plotDF<-data.frame(plotMat); names(plotDF)<-RI; plotDF$Exp<-uniqRaw
    plotDF_melt<-melt(plotDF); levels(plotDF_melt$variable)<-1:length(levels(plotDF_melt$variable))
    colnames(plotDF_melt)<-c("Experiment","TMT_Channel","Correlation")
    
    plotdata<-plotDF_melt
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    # validate
    .validate(data, input)
    # get plot data
    plotdata <- .plotdata(data, input)
    
<<<<<<< HEAD
    ggplot(plotdata, aes(x=TMT_Channel, y=Experiment, fill=Correlation), color="white") + geom_tile() + 
      theme_base + theme(axis.title.y=element_blank(), 
                         axis.text.x = element_text(angle=0, hjust = 0.5),
                         axis.ticks.x=element_blank(),
                         axis.ticks.y=element_blank(),
                         legend.position = "right") + scale_fill_gradient2(low="blue", midpoint = 0.5, mid = "white", high="red")
=======
    ggplot(plotdata, aes(x=TMT_Channel, y=Experiment, fill=Correlation)) + 
      geom_tile() + 
      theme_base(input=input) + 
      theme(axis.title.y=element_blank(), 
            axis.text.x = element_text(angle=0, hjust = 0.5),
            axis.ticks.x=element_blank(),
            axis.ticks.y=element_blank(),
            legend.position = "right") + 
      scale_fill_gradient2(low="blue", mid = "white", high="red")
>>>>>>> c4ef5f977a1b1459b8ed69579703b4c55d0da46d
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
