init <- function() { 
  
  type <- 'plot'
  box_title <- 'MS1 Intensity for all ions'
  help_text <- 'Plotting the MS1 intensity for all ions observed (not necessarily sent to MS2).'
  source_file <- 'allPeptides'
  
  # validate if the correct file is being uploaded
  .validate <- function(data, input) {
    validate(need(data()[['allPeptides']], paste0('Upload allPeptides.txt')))
  }
  
  # Plot data preparation function with an indicator message
  .plotdata <- function(data, input) {
    # Basic columns needed for plotting
    plotdata <- data()[['allPeptides']][, c('Raw.file', 'Charge', 'Intensity')]
    
    # Check if MS.MS.Count or Number.of.pasef.MS.MS columns are present
    msms_count_present <- "MS.MS.count" %in% colnames(data()[['allPeptides']])
    pasef_msms_present <- "Number.of.pasef.MS.MS" %in% colnames(data()[['allPeptides']])
    
    if (msms_count_present) {
      plotdata <- data()[['allPeptides']][, c('Raw.file', 'Charge', 'Intensity', 'MS.MS.count')]
      plot_type_message <- "Plot generated using MS.MS.count data."
    } else if (pasef_msms_present) {
      plotdata <- data()[['allPeptides']][, c('Raw.file', 'Charge', 'Intensity', 'Number.of.pasef.MS.MS')]
      plot_type_message <- "Plot generated using Number.of.pasef.MS.MS data."
    } else {
      # if neither column is present, show validation message and stop
      validate(need(FALSE, "Neither MS.MS.count nor Number.of.pasef.MS.MS is available. Cannot generate plot."))
    }
    
    # Log-transform Intensity column for better scaling
    plotdata$Intensity <- log10(plotdata$Intensity)
    
    # Thresholding data at the 1st and 99th percentiles
    ceiling <- quantile(plotdata$Intensity, probs = .99, na.rm = TRUE)
    floor <- quantile(plotdata$Intensity, probs = .01, na.rm = TRUE)
    
    plotdata <- dplyr::filter(plotdata, is.finite(Intensity)) # Checks whether the Intensity values are finite (i.e., not Inf, -Inf, or NA).
    # the colnames: Raw.file, Charge, Intensity, Number.of.pasef.MS.MS. the 3rd column is 'intensity'
    # Any Intensity value greater than or equal to the ceiling/floor is replaced with the ceiling/floor value. This caps the upper/lower outliers.
    plotdata[plotdata$Intensity >= ceiling, 3] <- ceiling 
    plotdata[plotdata$Intensity <= floor, 3] <- floor
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)  # Check if required file is uploaded
    plotdata <- .plotdata(data, input)  # Prepare the data for plotting
    
    # is there data to plot?
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    # generate the plot
    ggplot(plotdata, aes(Intensity)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_histogram(bins = 30) + 
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
