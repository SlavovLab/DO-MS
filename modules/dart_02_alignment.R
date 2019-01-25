init <- function() {
  
  tab <- '070 DART-ID'
  boxTitle <- 'RT Alignment Error'
  help <- 'Alignment Error (Predicted RT - Observed RT) for the RT Alignment in DART-ID'
  type <- 'plot'
  source.file <- 'evidence'
  
  .validate <- function(data, input) {
    
    validate(need(
      data()[['evidence']],
      paste0("Upload ", source.file, ".txt")
    ))
    
    # ensure that table has the DART-ID residual RT
    validate(need(
      'residual' %in% colnames(data()[['evidence']]), 
      paste0('Provide evidence.txt from DART-ID output, with residual RT column [residual]')
    ))
  }
  
  .plotdata <- function(data, input) {
    ev <- data()[['evidence']]
    ev <- ev %>%
      dplyr::select(c('Raw.file', 'Modified.sequence', 'residual'))
    return(ev)
  }
  
  .plot <- function(data, input) {
    
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    p <- ggplot(plotdata) +
      geom_boxplot(aes(Raw.file, residual), outlier.shape=NA) +
      scale_y_continuous(limits=c(-5, 5)) + 
      scale_x_discrete() +
      labs(x='Raw file', y='Residual RT (min)') +
      theme_base(input=input) +
      theme(
        axis.text.x=element_text(angle=45, vjust=1, hjust=1)
      )
    return(p)
  }
  
  # package all these variables and functions into a named list
  # that our application can build its UI from
  return(list(
    tab=tab,
    type=type,
    boxTitle=boxTitle,
    help=help,
    source.file=source.file,
    validateFunc=.validate,
    plotdataFunc=.plotdata,
    plotFunc=.plot,
    dynamic_width=50
  ))
}
