init <- function() {
  
  type <- 'plot'
  box_title <- 'rRI (misscleaved) / rRI (cleaved) in single cells'
  help_text <- 'rRI defined as each channel divided by the carrier channel. Carrier channel defined as channel with max median intensity. Plotting the ratio of the mean relative reporter ion signal for miss-cleaved peptides / the same for well-cleaved peptides '
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['evidence']]
    
    ri<-paste0("Reporter.intensity.",0:16)
    ri.ind<-which(colnames(plotdata)%in%ri)
    raw.ind<-which(colnames(plotdata)%in%"Raw.file")
    miss.ind<-which(colnames(plotdata)%in%"Missed.cleavages")
    ri.max<-which(colnames(plotdata)%in%names(colMeans(plotdata[,ri.ind]))[ colMeans(plotdata[,ri.ind])==max(colMeans(plotdata[,ri.ind])) ] )
    
    plotdata[,ri.ind]<-plotdata[,ri.ind] / plotdata[,ri.max]
    plotdata<-melt(plotdata[,c(raw.ind, miss.ind, ri.ind[ri.ind!=ri.max])], id.vars = c("Raw.file","Missed.cleavages"))
    
    plotdata$value[plotdata$value==Inf]<-NA
    plotdata$Missed.cleavages[plotdata$Missed.cleavages>0]<-1
    
    plotdata<-plotdata %>% 
      dplyr::group_by(Missed.cleavages, Raw.file,variable) %>%
      dplyr::summarise(mean_val = mean(value, na.rm=T)) %>% 
      dplyr::group_by(Raw.file, variable) %>%
      dplyr::summarise(miss_rat = mean_val[Missed.cleavages==1] / mean_val[Missed.cleavages==0] )
    
    plotdata$miss_rat <- log2(plotdata$miss_rat)
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    #validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(x=Raw.file, y=miss_rat, color=variable)) +
      geom_jitter(width=0.2) +
      #geom_dotplot(binaxis = "y", stackdir = "center", dotsize=2, position = position_dodge(width=0.5)) +
      theme_bw() + 
      #scale_y_continuous(labels = comma) + 
      #scale_x_discrete(breaks=1:6,labels=c("100 ms","200 ms","300 ms","","", "600 ms")) +
      #scale_x_continuous(limits=c(0, 700), breaks=c(0,100,200,300,400,500, 600,700), labels= c("","100 ms","200 ms","300 ms","","", "600 ms","")) +
      ylab("rRI (mc>0)\n / rRI (mc=0), log2") + 
      #rremove("legend") +
      xlab("\n Experiment") + 
      ggtitle("")+
      rremove("legend") +
      # theme(legend.position="right") + 
      # theme(legend.title = element_blank()) + 
      #scale_color_discrete(name = "Samples", labels = c("1 HEK-293", "1 U-937", "1 HEK-293", "1 U-937","1 HEK-293", "1 U-937")) + 
      theme(axis.text.x = element_text(color = "grey20", size = 14, angle = 90, hjust = 0, vjust = 0, face = "plain"),
            axis.text.y = element_text(color = "grey20", size = 18, angle = 0, hjust = 1, vjust = 0, face = "plain"), 
            axis.title.x = element_text(color = "grey20", size = 18, angle = 00, hjust = .5, vjust = 0, face = "plain"),
            axis.title.y = element_text(color = "grey20", size = 18, angle = 90, hjust = .5, vjust = .5, face = "plain"),
            axis.ticks.x = element_blank() )
    
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    box_width=20, # bootstrap column units
    plot_height=500, # pixels
    report_plot_width=7, # inches
    report_plot_height=5 # inches
  ))
}
