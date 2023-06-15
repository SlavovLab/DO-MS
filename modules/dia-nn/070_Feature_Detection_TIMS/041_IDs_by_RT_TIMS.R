init <- function() {
  
  type <- 'plot'
  box_title <- 'Features Identified across Gradient'
  help_text <- 'The frequency of feature identifications based on the MaxQuant search is plotted across the chromatographic gradient.'
  source_file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[['allPeptides']], paste0('Upload allPeptides.txt file')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['allPeptides']][,c('Raw.file', 'Charge', 'Retention.time', 'Retention.length')]
    plotdata$Retention.length <- as.numeric(plotdata$Retention.length)
    plotdata$Retention.time <- as.numeric(plotdata$Retention.time)
    
    plotdata <- dplyr::mutate(plotdata, RT.Start = Retention.time)
    plotdata <- dplyr::mutate(plotdata, RT.End = RT.Start + Retention.length)
    
    # Apply retention time filter as specified in settings.yaml
    plotdata <- plotdata %>% 
      filter(RT.Start > config[['RT.Start']]) %>% 
      filter(RT.End < config[['RT.End']])

    plotdata$Category = 'z = 1'
    plotdata$Category[plotdata$Charge > 1] <- 'z > 1'

    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    maxRT <- max(plotdata$Retention.time)
    
    ggplot(plotdata, aes(x=Retention.time, color = Category)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      stat_bin(aes(y=..count..), size = 0.8, bins=100,position = "identity",geom="step")+
      coord_flip() + 
      labs(x='Retention Time (min)', y='Number of Features') +
      scale_color_manual(name='Charge:', values=c(custom_colors[[1]], custom_colors[[6]]))+
      theme_diann(input=input, show_legend=T)+
      theme(legend.position = "bottom")
    
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
