init <- function() {
  
  type <- 'plot'
  box_title <- 'MS1 Intensity summed over all Channels.'
  help_text <- 'Plotting the MS1 intensity for all precursors summed over all channels.'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload report.txt')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
    
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['report']][,c('Raw.file', 'Ms1.Area', 'Precursor.Id','Label' )]

    

    
    plotdata %>% 
      group_by(Raw.file, Precursor.Id) %>% 
        summarise(Ms1.Area = sum(Ms1.Area), .groups = "drop")
    
    plotdata <- dplyr::filter(plotdata, Ms1.Area>0)
    plotdata$Intensity <- log10(plotdata$Ms1.Area)
    
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
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    
    medianData = plotdata %>% group_by(Raw.file) %>%
      summarise(median = median(Intensity), .groups = "drop")

    
    ggplot(plotdata, aes(Intensity)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_histogram(bins=50, fill=custom_colors[[6]]) + 
      coord_flip() + 
      labs(x=expression(bold('Log'[10]*' Precursor Intensity')), y='Number of Precursors') +
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
