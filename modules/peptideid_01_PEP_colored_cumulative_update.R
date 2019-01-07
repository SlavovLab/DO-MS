init <- function() {
  
  tab <- '030 Peptide Identifications'
  boxTitle <- 'Number of Confident Identifications'
  help <- 'Plotting the number of peptides identified at each given confidence
    level.'
  source.file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file, ".txt")))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source.file]][,c("Raw.file","PEP")]
    data.loaded<-plotdata
    # histdata <- data.loaded[,c("Raw.file","PEP")]
    # histdata_PEP <- count(histdata,c('Raw.file','PEP'))
    # DF.t <- ddply(histdata_PEP, .(Raw.file), transform, cy = cumsum(freq))

    options(scipen =200)
    
    histdata <- data.loaded[,c("Raw.file","PEP")]
    #histdata_PEP <- count(histdata,c('Raw.file','PEP'))
    histdata_PEP <- as.data.frame(table(histdata[,c('Raw.file','PEP')]))
    histdata_PEP<-histdata_PEP[histdata_PEP$Freq!=0,]
    histdata_PEP<-data.frame(histdata_PEP$Raw.file, as.numeric(as.character(histdata_PEP$PEP)), as.numeric(histdata_PEP$Freq))
    colnames(histdata_PEP)<-c("Raw.file","PEP","Freq")
    #DF.t <- ddply(histdata_PEP, .(Raw.file), transform, cy = cumsum(freq))
    DF.t <- ddply(histdata_PEP, .(Raw.file), transform, cy = cumsum(Freq))
    
    # Cut off for display
    #DF.t<-DF.t[DF.t$PEP<0.1,]
    
    plotdata<-DF.t
    return(plotdata)
    
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    DF.t<-plotdata
    
    # Rank the Experiments by most number of peptides observed
    maxnum<-c()
    rawnames<-c()
    for(X in unique(DF.t$Raw.file)){
      maxnum<-c(maxnum, max(DF.t$cy[DF.t$Raw.file%in%X]) )
      rawnames<-c(rawnames,X)
    }
    names(maxnum)<-rawnames
    rankExp<-maxnum[order(maxnum, decreasing = T)]
    rankExp_ord<-seq(1,length(rankExp),1); names(rankExp_ord)<-names(rankExp)
    DF.t$rank_ord<-NA
    for(X in levels(DF.t$Raw.file)){
      
      DF.t$rank_ord[DF.t$Raw.file%in%X] <- rankExp_ord[X]
      
    }
    
    cc <- scales::seq_gradient_pal("red", "blue", "Lab")(seq(0,1,length.out=length(rankExp_ord)))
    
    #ggplot(DF.t, aes(x=PEP, y=cy,group=Raw.file)) + geom_line(size = 1.2) + coord_flip() + scale_x_log10(limits = c(.00009,.1), breaks = c(.0001,.001,.01,.1), labels = scales::trans_format("log10", scales::math_format(10^.x))) + theme( panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"), axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=textVar)) + ylab("Number of IDs") 
    ggplot(DF.t, aes(x=PEP, color = factor(rank_ord), y=cy,group=Raw.file)) + 
      geom_line(size = input$figure_line_width) +
      scale_colour_manual(name = "Experiment", values=cc, labels = names(rankExp_ord)) +
      coord_flip() + 
      scale_x_log10(limits = c(.00009,.1), breaks = c(.0001,.001,.01,.1), 
                    labels = scales::trans_format("log10", scales::math_format(10^.x))) + 
      theme_base(input=input) +
      theme(legend.position = "right") + 
      theme(legend.key = element_rect(fill = "white")) +
      ylab("Number of IDs") 
    
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
