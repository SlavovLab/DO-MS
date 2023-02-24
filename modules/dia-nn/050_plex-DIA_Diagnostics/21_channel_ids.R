init <- function() {
  
  type <- 'plot'
  box_title <- 'Identified Precursors per Channel, Channel Q-Value'
  help_text <- 'The number of precursors identified is shown for every channel together with the number of total and intersected precursors. The number of precursors is based on all precursors with a Channel.Q.Value <= 0.01.'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload report.txt')))
    validate(need(data()[['report']][['Channel.Q.Value']], paste0('Channel.Q.Value column was not found. Your DIA-NN version does not yet support this feature.')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
  }
  
  
  .plotdata <- function(data, input) {
    
    plotdata <- data()[['report']][,c('Raw.file', 'Ms1.Area', 'Precursor.Id', 'Channel.Q.Value', 'Label')]
    
    
    plotdata <- plotdata[plotdata$Ms1.Area>0,]
    
    plotdata <- plotdata %>%
      dplyr::filter(Channel.Q.Value < 0.01)
    
    
    # calculate channel wise IDs
    plotdata_n <- plotdata %>%
      dplyr::group_by(Raw.file, Label) %>%
      dplyr::summarise(Identifications=n(), 
                       .groups = "drop")

    # calculate IDs across channels
    plotdata_k <- plotdata %>%
      dplyr::group_by(Raw.file, Precursor.Id) %>%
      dplyr::summarise(Identifications=n(), 
                       .groups = "drop")
    
    # calculate union of all IDs
    plotdata_union <- plotdata_k %>%
      dplyr::group_by(Raw.file) %>%
      dplyr::summarise(Identifications=n(), 
                       .groups = "drop")
    
    # calculate intersection of all IDs
    plotdata_k = plotdata_k[plotdata_k$Identifications==3,]
    plotdata_intersected <- plotdata_k %>%
      dplyr::group_by(Raw.file) %>%
      dplyr::summarise(Identifications=n(), 
                       .groups = "drop")
    
    # Set labels dor newly create dataframe
    plotdata_intersected$Label = "Intersected"
    plotdata_union$Label = "Union"
    
    
    plotdata = rbind(plotdata_n, plotdata_intersected)
    plotdata = rbind(plotdata, plotdata_union)
    
    channels = c()
    for (channel in config[['channels']]) {
      channels <- c(channels, channel[['name']])
    }
    
    # create custom factor levels to influence the order of labels
    levels_plot = c('Intersected',channels,'Union')
    plotdata <- within(plotdata, 
                       Label <- factor(Label, levels=levels_plot))
    
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)

    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(x=Label, y=Identifications, fill=Label, colour=Label)) +
      geom_bar(stat="identity", alpha=0.7) +
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x")+
      labs(x='', y='Number of Precursors') +
      theme_diann(input=input, show_legend=F) +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
      scale_fill_manual(values = c(custom_colors[[6]],custom_colors[[1]],custom_colors[[2]],custom_colors[[3]],custom_colors[[6]]))+
      scale_color_manual(values = c(custom_colors[[6]],custom_colors[[1]],custom_colors[[2]],custom_colors[[3]],custom_colors[[6]]))
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

