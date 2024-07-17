init <- function() {
  
  type <- 'plot'
  box_title <- 'FWHM'
  help_text <- 'Estimated FWHM of identified precursors. Serves as an indication of peak shape.'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload report.parquet')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
  }

  
  .plotdata <- function(data, input) {
    
    report <- data()[['report']][,c('Raw.file', 'FWHM', 'Precursor.Id')]
    
    # plotdata <- report[report$FWHM > 0,]
    plotdata <- report

    # Thresholding data at 1 and 99th percentiles
    # ceiling <- quantile(plotdata$FWHM, probs=.95, na.rm = TRUE)
    # floor <- quantile(plotdata$FWHM, probs=.95, na.rm = TRUE)
    
    # plotdata <- dplyr::filter(plotdata, is.finite(FWHM))
    
    # plotdata[plotdata$FWHM >= ceiling, 2] <- ceiling
    # plotdata[plotdata$FWHM <= floor, 2] <- floor
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)

    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(x=FWHM)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      
      stat_bin(aes(y=..count..), size = 0.8, bins=100,position = "identity",geom="step")+
      coord_flip() + 
      xlim(0, max(plotdata$FWHM) * 0.33) +
      labs(x='FWHM (min)', y='Number of Precursors') +
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

