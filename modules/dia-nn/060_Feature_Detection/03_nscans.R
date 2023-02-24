init <- function() {
  
  type <- 'plot'
  box_title <- 'Number of Scans per feature'
  help_text <- 'The number of MS1 scans is shown for all features identified in the Dinosaur search.'
  source_file <- 'features'
  
  .validate <- function(data, input) {
    validate(need(data()[['features']], paste0('Please provide a features.tsv file')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['features']][,c('Raw.file', 'mz', 'rtStart','charge','rtApex','rtEnd','nScans')]

    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    
    
    # Thresholding data at 1 and 99th percentiles
    ceiling <- quantile(plotdata$nScans, probs=.99, na.rm = TRUE)
    floor <- quantile(plotdata$nScans, probs=.01, na.rm = TRUE)
    
    plotdata <- dplyr::filter(plotdata, is.finite(nScans))
    
    plotdata[plotdata$nScans >= ceiling, 'nScans'] <- ceiling
    plotdata[plotdata$nScans <= floor, 'nScans'] <- floor
    
    maxScans <- max(plotdata$nScans)
    
    ggplot(plotdata, aes(nScans)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_histogram(bins=30, fill=custom_colors[[6]]) + 
      coord_flip() + 
      xlim(0, maxScans) +
      labs(x='Number of Scans', y='Features identified') +
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
