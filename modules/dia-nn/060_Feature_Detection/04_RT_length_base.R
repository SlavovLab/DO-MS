init <- function() {
  
  type <- 'plot'
  box_title <- 'Retention Length of Features at Base'
  help_text <- 'Plotting the retention length of identified features at the base.'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['features']], paste0('Please provide a features.tsv file')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['features']][,c('Raw.file', 'mz', 'rtStart','charge','rtApex','rtEnd')]

    # Apply retention time filter as specified in settings.yaml
    plotdata <- plotdata %>% 
      filter(rtStart > config[['RT.Start']]) %>% 
      filter(rtStart < config[['RT.End']])

    plotdata <- dplyr::mutate(plotdata, RT.Length = (rtEnd-rtStart)*60)
    
    
    # Thresholding data at 1 and 99th percentiles
    ceiling <- quantile(plotdata$RT.Length, probs=.99, na.rm = TRUE)
    floor <- quantile(plotdata$RT.Length, probs=.01, na.rm = TRUE)
    
    plotdata <- dplyr::filter(plotdata, is.finite(RT.Length))
    
    plotdata[plotdata$RT.Length >= ceiling, "RT.Length"] <- ceiling
    plotdata[plotdata$RT.Length <= floor, "RT.Length"] <- floor
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(RT.Length)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_histogram(bins=50, fill=custom_colors[[6]]) + 
      coord_flip() + 
      labs(x='Retention Lengths at base (sec)', y='Features identified') +
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
