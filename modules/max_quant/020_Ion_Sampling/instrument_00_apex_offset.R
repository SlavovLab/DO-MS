init <- function() {
  
  type <- 'plot'
  box_title <- 'Apex Offset'
  help_text <- 'Plotting the distance from the peak of the elution profile the MS2 events were executed.'
  source_file <- 'msmsScans'
  
  .validate <- function(data, input) {
    validate(need(data()[['msmsScans']], paste0('Upload msmsScans.txt')))
    validate(need( 
      'Precursor.apex.offset.time' %in% colnames(data()[['msmsScans']]),
      'Column "Precursor.apex.offset.time" not found. Please run search with "Calculate peak properties" enabled (under Global Parameters/Advanced) in order to generate this column in the MaxQuant output.'
    ))
    validate(need( 
      any(data()[['msmsScans']]$Precursor.apex.offset.time != 0) & any(!is.na(data()[['msmsScans']]$Precursor.apex.offset.time)),
      'Column "Precursor.apex.offset.time" contains all empty values. Please run search with "Calculate peak properties" enabled (under Global Parameters/Advanced) in order to generate this column in the MaxQuant output.'
    ))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['msmsScans']][,c('Raw.file', 'Precursor.apex.offset.time')]
    
    plotdata$Precursor.apex.offset.time <- plotdata$Precursor.apex.offset.time * 60
    plotdata$Precursor.apex.offset.time[plotdata$Precursor.apex.offset.time > 8] <- 9
    plotdata$Precursor.apex.offset.time[plotdata$Precursor.apex.offset.time < -8] <- -9
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(Precursor.apex.offset.time)) + 
      facet_wrap(~Raw.file, nrow=1, scales = "free_x") + 
      geom_histogram(bins=30) + 
      geom_vline(xintercept=0, color='red') +
      coord_flip() + 
      annotate(geom='text', label='Early', x=Inf, y=Inf, hjust=1.2, vjust=-0.5, size=5, angle=90) +
      annotate(geom='text', label='Late', x=-Inf, y=Inf, hjust=-0.2, vjust=-0.5, size=5, angle=90) +
      labs(x='Apex Offset (sec)', y='Number of Ions') + 
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
