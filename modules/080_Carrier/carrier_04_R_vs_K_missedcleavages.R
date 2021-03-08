init <- function() {
  
  type <- 'plot'
  box_title <- 'Miscleavage rate, R and K, PEP < 0.01'
  help_text <- 'Miscleavage rate at arginine and lysine for peptides filtered to PEP < 0.01'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
  }
  
  .plotdata <- function(data, input) {
    
    plotdata <- data()[['evidence']]
    plotdata <- plotdata[plotdata$PEP<0.01, ]
    
    plotdata$seq2<-substrRight(plotdata$Sequence)
    
    plotdata$R<-as.numeric(grepl("R", plotdata$seq2))
    plotdata$K<-as.numeric(grepl("K", plotdata$seq2))
    
    
    plotdata<-plotdata[,c("Raw.file","R","K")]
    
    plotdata<-melt(plotdata)
    
    plotdata<-plotdata %>% 
      dplyr::group_by(Raw.file,variable) %>%
      dplyr::summarise(pct = mean(value, na.rm=T))
        
    return(plotdata)
    
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 0), paste0('No Rows selected')))
    
    plotdata$pct<-plotdata$pct*100
    
    ggplot(plotdata, aes(Raw.file, pct, fill=variable)) +
      geom_bar(stat='identity', width = 0.8, position = position_dodge(width = 0.9)) +
      labs(x='Experiment', y='% misscleavage', fill='AA') +
      theme_bw() +
      #scale_y_continuous(labels = comma) +
      #scale_x_discrete(breaks=1:6,labels=c("100 ms","200 ms","300 ms","","", "600 ms")) +
      #scale_x_continuous(limits=c(0, 700), breaks=c(0,100,200,300,400,500, 600,700), labels= c("","100 ms","200 ms","300 ms","","", "600 ms","")) +
      #ylab("scRI") +
      #rremove("legend") +
      #xlab("\n Experiment") +
      ggtitle("")+
      #rremove("legend") +
      # theme(legend.position="right") +
      # theme(legend.title = element_blank()) +
      #scale_color_discrete(name = "Samples", labels = c("1 HEK-293", "1 U-937", "1 HEK-293", "1 U-937","1 HEK-293", "1 U-937")) +
      theme(axis.text.x = element_text(color = "grey20", size = 14, angle = 90, hjust = 0, vjust = 0, face = "plain"),
            axis.text.y = element_text(color = "grey20", size = 18, angle = 0, hjust = 1, vjust = 0, face = "plain"),
            axis.title.x = element_text(color = "grey20", size = 18, angle = 00, hjust = .5, vjust = 0, face = "plain"),
            axis.title.y = element_text(color = "grey20", size = 18, angle = 90, hjust = .5, vjust = .5, face = "plain"),
            axis.ticks.x = element_blank(),
            legend.text = element_text(size = 18),
            legend.title = element_text(size = 18)) + 
  # keep the legend
      theme(legend.position='right',legend.key=element_rect(fill='white'))
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot
  ))
}

