init <- function() {
  
  type <- 'plot'
  box_title <- 'RT Alignment Error'
  help_text <- 'Alignment Error (Predicted RT - Observed RT) for the RT Alignment in DART-ID'
  source_file <- 'DART-ID'
  
  .validate <- function(data, input) {
    
    validate(need(data()[['DART-ID']], paste0('Upload evidence_updated.txt')))
    
    # ensure that table has the DART-ID residual RT
    validate(need(
      'residual' %in% colnames(data()[['DART-ID']]), 
      paste0('Provide evidence.txt from DART-ID output, with residual RT column [residual]. Visit https://dart-id.slavovlab.net/ for more information about DART-ID')
    ))
  }
  
  .plotdata <- function(data, input) {
    ev <- data()[['DART-ID']]
    ev <- ev %>%
      dplyr::select(c('Raw.file', 'Modified.sequence', 'residual'))
    return(ev)
  }
  
  .plot <- function(data, input) {
    
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata) +
      geom_boxplot(aes(Raw.file, residual), outlier.shape=NA) +
      scale_y_continuous(limits=c(-5, 5)) + 
      scale_x_discrete() +
      labs(x='Raw file', y='Residual RT (min)') +
      theme_base(input=input) +
      theme(axis.text.x=element_text(angle=45, vjust=1, hjust=1))
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    dynamic_width=50
  ))
}
