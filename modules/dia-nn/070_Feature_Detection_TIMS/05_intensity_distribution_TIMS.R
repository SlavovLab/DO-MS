init <- function() {
  
  type <- 'plot'
  box_title <- 'Feature Intensity Distribution'
  help_text <- 'The distribution of intensities is shown for identified features. '
  source_file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[['allPeptides']], paste0('Upload allPeptides.txt file')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['allPeptides']][,c('Raw.file', 'Intensity')]
    plotdata$Intensity <- log10(plotdata$Intensity)
    
    # Thresholding data at 1 and 99th percentiles
    ceiling <- quantile(plotdata$Intensity, probs=.99, na.rm = TRUE)
    floor <- quantile(plotdata$Intensity, probs=.01, na.rm = TRUE)
    
    plotdata <- dplyr::filter(plotdata, is.finite(Intensity))
    if(nrow(plotdata) > 0){
      plotdata[plotdata$Intensity >= ceiling, 2] <- ceiling
      plotdata[plotdata$Intensity <= floor, 2] <- floor
    }
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata, aes(x=Intensity )) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_histogram(bins=50, fill=custom_colors[[6]]) + 
      coord_flip() + 
      labs(x=expression(bold('Log'[10]*'Feature Intensity')), y='Number of Features') +
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
