init <- function() {
  
  type <- 'plot'
  box_title <- 'Elution profile: FWHM'
  help_text <- 'Plotting the distrution of elution profile widths at half the maximum intensity value for each peak.'
  source_file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[[source_file]], paste0('Upload ', source_file, '.txt')))
    validate(need( 
      'Retention.length..FWHM.' %in% colnames(data()[[source_file]]),
      'Column "Retention length (FWHM)" not found. Please run search with "Calculate peak properties" enabled (under Global Parameters/Advanced) in order to generate this column in the MaxQuant output.'
    ))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source_file]][,c('Raw.file', 'Retention.length..FWHM.')]
    plotdata$Retention.length..FWHM.[plotdata$Retention.length..FWHM. > 45] <- 49
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata, aes(Retention.length..FWHM.)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins = 49) + 
      coord_flip() +  
      labs(x='Retention Length FWHM (sec)', y='Count') +
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
    dynamic_width=150
  ))
}

