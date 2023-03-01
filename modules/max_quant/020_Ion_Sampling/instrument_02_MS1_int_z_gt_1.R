init <- function() {
  
  type <- 'plot'
  box_title <- 'MS1 Intensity for z>1 ions'
  help_text <- 'Plotting the MS1 intensity for all peptide-like ions observed (not necessarily sent to MS2) across runs.'
  source_file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[['allPeptides']], paste0('Upload allPeptides.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['allPeptides']][,c('Raw.file', 'Charge', 'Intensity')]
    plotdata$Intensity <- log10(plotdata$Intensity)
    plotdata <- plotdata[plotdata$Charge > 1,]
    
    # Thresholding data at 1 and 99th percentiles
    ceiling <- quantile(plotdata$Intensity, probs=.99, na.rm = TRUE)
    floor <- quantile(plotdata$Intensity, probs=.01, na.rm = TRUE)
    
    plotdata <- dplyr::filter(plotdata, is.finite(Intensity))
    
    plotdata[plotdata$Intensity >= ceiling, 3] <- ceiling
    plotdata[plotdata$Intensity <= floor, 3] <- floor
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(Intensity)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_histogram(bins=30) + 
      coord_flip() + 
      labs(x=expression(bold('Log'[10]*' Precursor Intensity')), y='Number of Ions') +
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
