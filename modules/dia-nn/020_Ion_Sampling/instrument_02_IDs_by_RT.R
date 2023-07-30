init <- function() {
  
  type <- 'plot'
  box_title <- 'Precursors Identified across Gradient'
  help_text <- 'Plotting the precursors across the chromatographic gradient.'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Please provide a report.tsv file')))
  }
  
  .plotdata <- function(data, input) {

    

    plotdata <- data()[['report']][,c('Raw.file', 'Retention.time')]

    # Apply retention time filter as specified in settings.yaml
    plotdata <- plotdata %>% 
      filter(Retention.time > config[['RT.Start']]) %>% 
      filter(Retention.time < config[['RT.End']])

    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(x=Retention.time)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      
      stat_bin(aes(y=..count..), size = 0.8, bins=100,position = "identity",geom="step")+
      coord_flip() + 
      labs(x='Retention Time (min)', y='Number of Precursors') +
      scale_color_manual(values=c(custom_colors[[1]], custom_colors[[6]]))+
      theme_diann(input=input, show_legend=T)
    
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
