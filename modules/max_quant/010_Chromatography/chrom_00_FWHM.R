init <- function() {
  
  type <- 'plot'
  box_title <- 'Elution profile: FWHM'
  help_text <- 'Plotting the distrution of elution profile widths at half the maximum intensity value for all observed ions. '
  source_file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[['allPeptides']], paste0('Upload allPeptides.txt')))
    validate(need( 
      'Retention.length..FWHM.' %in% colnames(data()[['allPeptides']]),
      'Column "Retention length (FWHM)" not found. Please run search with "Calculate peak properties" enabled (under Global Parameters/Advanced) in order to generate this column in the MaxQuant output.'
    ))
    validate(need( 
      any(data()[['allPeptides']]$Retention.length..FWHM. != 0) & any(!is.na(data()[['allPeptides']]$Retention.length..FWHM.)),
      'Column "Retention length (FWHM)" contains all empty values. Please run search with "Calculate peak properties" enabled (under Global Parameters/Advanced) in order to generate this column in the MaxQuant output.'
    ))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['allPeptides']][,c('Raw.file', 'Retention.length..FWHM.')]
    plotdata$Retention.length..FWHM.[plotdata$Retention.length..FWHM. > 45] <- 49
    
    # Thresholding data at 1 and 99th percentiles
    ceiling <- quantile(plotdata$Retention.length..FWHM., probs=.99, na.rm = TRUE)
    floor <- quantile(plotdata$Retention.length..FWHM., probs=.01, na.rm = TRUE)
    
    plotdata <- dplyr::filter(plotdata, is.finite(Retention.length..FWHM.))
    
    plotdata[plotdata$Retention.length..FWHM. >= ceiling, 2] <- ceiling
    plotdata[plotdata$Retention.length..FWHM. <= floor, 2] <- floor
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    ggplot(plotdata, aes(Retention.length..FWHM.)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_histogram(bins = 49) + 
      coord_flip() +  
      labs(x='Retention Length FWHM (sec)', y='Number of Ions') +
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

