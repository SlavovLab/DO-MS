init <- function() {
  
  type <- 'plot'
  box_title <- 'TMT Labeling Efficiency, PEP < 0.01'
  help_text <- 'Comparing relative rates of IDs for peptides with, or without the TMT tag. Only compatible with searches performed with TMT as a variable mod (n-terminus and on lysine)'
  source_file <- 'evidence'
  repDiv <- ''
  
  .validate <- function(data, input) {
    validate(need(data()[['Labeling_Efficiency']], paste0('Upload evidence.txt in labeling efficiency input')))
    
    # require TMT as a variable mod
    #validate(need(any(grepl('TMT', data()[['Labeling_Efficiency']]$Modifications)), 
                  #paste0('Loaded data was not searched with TMT as a variable modification')))
    #validate(need(any(grepl('TMTPro_K_LE', colnames(data()[['Labeling_Efficiency']]))), 
                #  paste0('Loaded data was not searched with TMT as a variable modification')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['Labeling_Efficiency']]
    
      plotdata <- plotdata %>%
      # filter at 0.01 PEP
      dplyr::filter(PEP < 0.01)

      plotdata$K_count <- stringr::str_count(plotdata$Sequence, "K")
      plotdata$Acetyl_count = stringr::str_count(plotdata$Modifications, "Acetyl (Protein N-term)")

      n_nam<-c("TMT11plex_N_LE", "TMTPro_Nter_LE")
      k_nam<-c("TMT11plex_K_LE", "TMTPro_K_LE")
      
      n_ind<-which(colnames(plotdata)%in%n_nam)
      k_ind<-which(colnames(plotdata)%in%k_nam)
      
      plotdata$n_le<-plotdata[,n_ind] / (1 - plotdata$Acetyl_count)
      plotdata$k_le<-plotdata[,k_ind] / (plotdata$K_count)

      plotdata<-plotdata[,c("Raw.file","n_le","k_le")]
      plotdata <- plotdata %>% 
        dplyr::group_by(Raw.file) %>% 
        dplyr::summarise(mean(n_le, na.rm=T), mean(k_le, na.rm=T))

      
      colnames(plotdata)<-c("Raw.file","N-term","K")
      plotdata<-melt(plotdata)
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata, aes(Raw.file, value, fill=variable)) +
      geom_bar(stat='identity', width = 0.8, position = position_dodge(width = 0.9)) +
      labs(x='Experiment', y='Labeling efficiency\n', fill='Position') +
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
    repDiv=repDiv,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot
  ))
}
