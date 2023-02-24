init <- function() {
  
  type <- 'plot'
  box_title <- 'Total MS1 Precursors'
  help_text <- 'Total number of precursors identified based on different confidence metrics.'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['ms1_extracted']], paste0('Upload ms1_extracted.tsv')))
    validate(need((nrow(data()[['ms1_extracted']]) > 1), paste0('No Rows selected')))
    validate(need(config[['ChemicalLabels']], paste0('Please provide a list of labels under the key: ChemicalLabels in the settings.yaml file')))
  }

  
  .plotdata <- function(data, input) {
    
    ms1_extracted <- data()[['ms1_extracted']][,c('Raw.file', 'Ms1.Area', 'Precursor.Id')]
    
    
    report <- data()[['report']][,c('Raw.file', 'Ms1.Area', 'Precursor.Id')]
    
    
    ms1_extracted <- ms1_extracted[ms1_extracted$Ms1.Area>0,]
    report <- report[report$Ms1.Area>0,]
    
    
    # calculate channel wise IDs
    ms1_extracted_s <- ms1_extracted %>%
      dplyr::group_by(Raw.file) %>%
      dplyr::summarise(Identifications=n(), 
                       .groups = "drop")
    
    # calculate channel wise IDs
    report_s <- report %>%
      dplyr::group_by(Raw.file) %>%
      dplyr::summarise(Identifications=n(), 
                       .groups = "drop")
    
    # Set labels dor newly create dataframe
    ms1_extracted_s$Label <- "Ms1_extracted.tsv"
    report_s$Label <- "run q-value"
    
    plotdata = rbind(ms1_extracted_s, report_s)
    
    # create custom factor levels to influence the order of labels
    levels_plot = c("run q-value","Ms1_extracted.tsv")
    plotdata <- within(plotdata, 
                       Label <- factor(Label, levels=levels_plot))
    
    
    if ("Channel.Q.Value" %in% names(report)){
      report_channel_q<- report %>%
        dplyr::filter(Ms1.Area > 0) %>%
        dplyr::filter(Channel.Q.Value < 0.01) %>%
        dplyr::group_by(Raw.file) %>%
        dplyr::summarise(Identifications=n(), 
                       .groups = "drop")
        
      report_channel_q$Label <- "channel q-value"
      
      plotdata = rbind(ms1_extracted_s, report_s, report_channel_q)
      
      # create custom factor levels to influence the order of labels
      levels_plot = c("run q-value","Ms1_extracted.tsv","channel q-value")
      plotdata <- within(plotdata, 
                         Label <- factor(Label, levels=levels_plot))
    }
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)

    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(x=Label, y=Identifications, fill=Label, colour=Label)) +
      geom_bar(stat="identity", alpha=0.7) +
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x")+
      labs(y='Number of Precursors',x='' ) +
      theme_diann(input=input, show_legend=T) +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
      scale_fill_manual(values=c("#DC267F","#FFB000","#648FFF")) +
      scale_fill_manual(values = c(custom_colors[[4]],custom_colors[[5]],custom_colors[[6]]))+
      scale_color_manual(values = c(custom_colors[[4]],custom_colors[[5]],custom_colors[[6]]))
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    dynamic_width=200,
    dynamic_width_base=50
  ))
}

