init <- function() {
  
  type <- 'plot'
  box_title <- 'MS1 Intensity, +1 ions'
  help_text <- 'Plotting the intensity distribution of +1 ions.'
  source_file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[['allPeptides']], paste0('Upload allPeptides.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['allPeptides']][,c('Raw.file', 'Charge', 'Intensity')]
    
    plotdata <- plotdata %>% 
      filter(Charge == 1) %>%
      mutate(log_int=log10(Intensity))
    
    # Thresholding data at 1 and 99th percentiles
    ceiling <- quantile(plotdata$Intensity, probs=.99, na.rm = TRUE)
    floor <- quantile(plotdata$Intensity, probs=.01, na.rm = TRUE)
    
    plotdata <- dplyr::filter(plotdata, is.finite(Intensity))
    
    plotdata[plotdata$Retention.length..FWHM. >= ceiling, 3] <- ceiling
    plotdata[plotdata$Retention.length..FWHM. <= floor, 3] <- floor
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(log_int)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_histogram(bins=100) + 
      coord_flip() + 
      labs(y='Number of Ions', x=expression(bold('Log'[10]*' Intensity'))) +
      theme_base(input=input) 
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    dynamic_width=150,
    dynamic_width_base=150
  ))
}


