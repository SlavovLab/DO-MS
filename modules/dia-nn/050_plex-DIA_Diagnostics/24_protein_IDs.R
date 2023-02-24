init <- function() {
  
  type <- 'plot'
  box_title <- 'Identified Proteins per Channel'
  help_text <- 'The number of Proteins identified is shown for every channel together with the number of total and intersected proteins. The number of proteins is based on all proteotypic precursors independent of the Protein.Q.Value.'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload report.txt')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
  }
  
  .plotdata <- function(data, input) {
    
    plotdata <- data()[['report']][,c('Raw.file', 'Ms1.Area', 'Precursor.Id','Proteotypic', 'Label', 'Protein.Ids','Protein.Group','Protein.Q.Value','PG.Q.Value', 'Translated.Q.Value')]
    
    plotdata <- plotdata[plotdata$Ms1.Area>0,]
    
    plotdata_union <- plotdata %>%
      dplyr::filter(Proteotypic == 1) %>%
      dplyr::group_by(Raw.file) %>%
      dplyr::summarise(Identifications = n_distinct(Protein.Ids), 
                       Identifications.O = n_distinct(Protein.Ids[Translated.Q.Value <= 0.01]), 
                       .groups = "drop")
    
    plotdata_channel <- plotdata %>%
      dplyr::filter(Proteotypic == 1) %>%
      dplyr::group_by(Raw.file,Label) %>%
      dplyr::summarise(Identifications = n_distinct(Protein.Ids), 
                       Identifications.O = n_distinct(Protein.Ids[Translated.Q.Value <= 0.01]), 
                       .groups = "drop")
    
    plotdata_I <- plotdata %>%
      dplyr::filter(Proteotypic == 1) %>%
      dplyr::group_by(Raw.file,Protein.Ids) %>%
      dplyr::summarise(Channels = n_distinct(Label),
                       Channels.O = n_distinct(Label[Translated.Q.Value <= 0.01]), 
                       .groups = "drop") 
    
    plotdata_intersected <- plotdata_I %>%
      dplyr::group_by(Raw.file) %>%
      dplyr::summarise(Identifications = n_distinct(Protein.Ids[Channels == 3]),
                       Identifications.O = n_distinct(Protein.Ids[Channels.O == 3]), 
                       .groups = "drop")
    
    # Set labels dor newly create dataframe
    plotdata_intersected$Label = "Intersected"
    plotdata_union$Label = "Union"
    
    
    plotdata = rbind(plotdata_channel, plotdata_intersected, plotdata_union)
    
    channels = c()
    for (channel in config[['channels']]) {
      channels <- c(channels, channel[['name']])
    }
    
    # create custom factor levels to influence the order of labels
    levels_plot = c('Intersected',channels,'Union')
    plotdata <- within(plotdata, 
                       Label <- factor(Label, levels=levels_plot))
    
    plotdata <- plotdata %>% 
      mutate(Identifications.T = Identifications - Identifications.O) %>%
      gather("Type", "Identifications", c('Identifications.T','Identifications.O'))
    
    levels_plot = c('Intersected',channels,'Union')
    plotdata <- within(plotdata, 
                       Label <- factor(Label, levels=levels_plot))
    
    plotdata <- plotdata %>% 
      mutate(Type=recode(Type, 
                         Identifications.T = "Translated", 
                         Identifications.O = "Main search"))
    
    levels_plot = c("Main search", "Translated")
    plotdata <- within(plotdata, 
                       Type <- factor(Type, levels=levels_plot))
    
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)

    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(x=Label, y=Identifications, fill=Label, colour=Label,  alpha=Type)) +
      geom_bar(stat="identity") +
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x")+
      labs(x='', y='Number of Proteins') +
      theme_diann(input=input, show_legend=T) +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
      theme(legend.position = "bottom")+
      scale_alpha_manual(name="",values=c(0.4,0.8)) +
      scale_fill_manual(values = c(custom_colors[[6]],custom_colors[[1]],custom_colors[[2]],custom_colors[[3]],custom_colors[[6]]), guide = "none")+
      scale_color_manual(values = c(custom_colors[[6]],custom_colors[[1]],custom_colors[[2]],custom_colors[[3]],custom_colors[[6]]), guide = "none")
      
    
   
    
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

