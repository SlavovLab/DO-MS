title <- 'Number of Confident Identifications'

init <- function() {
  return(list(
    tab='Sample Quality',
    boxTitle=title,
    help='Plotting the number of peptides identified at each given confidence
    level.',
    moduleFunc=.module
  ))
}

.module <- function(input, output, session, data) {
  
  .validate <- function() {
    validate(need(data()[['evidence']],paste0("Upload ", 'evidence',".txt")))
  }
  
  .plotdata <- function() {
    plotdata <- data()[['evidence']][,c("Raw.file","PEP")]
    data.loaded<-plotdata
    histdata <- data.loaded[,c("Raw.file","PEP")]
    histdata_PEP <- count(histdata,c('Raw.file','PEP'))
    DF.t <- ddply(histdata_PEP, .(Raw.file), transform, cy = cumsum(freq))
    
    # Cut off for display
    DF.t<-DF.t[DF.t$PEP<0.1,]
    
    plotdata<-DF.t
    return(plotdata)
    
  }
  
  .plot <- function() {
    .validate()
    plotdata <- .plotdata()
    
    DF.t<-plotdata
    
    # Rank the Experiments by most number of peptides observed
    maxnum<-c()
    rawnames<-c()
    for(X in levels(DF.t$Raw.file)){
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
    ggplot(DF.t, aes(x=PEP, color = factor(rank_ord), y=cy,group=Raw.file)) + geom_line(size = 1.2) +
      scale_colour_manual(name = "Experiment", values=cc, labels = names(rankExp_ord)) +
      coord_flip() + scale_x_log10(limits = c(.00009,.1), breaks = c(.0001,.001,.01,.1), labels = scales::trans_format("log10", scales::math_format(10^.x))) + theme( legend.key = element_rect(fill = "white"),panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"), axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=textVar)) + ylab("Number of IDs") 
    
  }
  
  output$plot <- renderPlot({
    .plot()
  })
  
  output$downloadPDF <- downloadHandler(
    filename=function() { paste0(gsub('\\s', '_', title), '.pdf') },
    content=function(file) {
      ggsave(filename=file, plot=.plot(), 
             device=pdf, width=5, height=5, units='in')
    }
  )
  
  output$downloadPNG <- downloadHandler(
    filename=function() { paste0(gsub('\\s', '_', title), '.png') },
    content=function(file) {
      ggsave(filename=file, plot=.plot(), 
             device=png, width=5, height=5, units='in')
    }
  )
  
  output$downloadData <- downloadHandler(
    filename=function() { paste0(gsub('\\s', '_', title), '.txt') },
    content=function(file) {
      # validate
      .validate()
      # get plot data
      plotdata <- .plotdata()
      write_tsv(plotdata, path=file)
    }
  )
  
}

