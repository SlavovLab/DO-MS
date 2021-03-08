init <- function() {
  
  type <- 'plot'
  box_title <- 'Peptide Identification Increase by Experiment'
  help_text <- 'Increased number of peptide IDs per experiment, relative to existing IDs before DART-ID'
  source_file <- 'DART-ID'
  
  .validate <- function(data, input) {
    
    validate(need(data()[['DART-ID']], paste0('Upload evidence_updated.txt')))
    
    # ensure that table has the DART-ID residual RT
    validate(need(
      'dart_PEP' %in% colnames(data()[['DART-ID']]), 
      paste0('Provide evidence.txt from DART-ID output, with updated dart_PEP column. Visit https://dart-id.slavovlab.net/ for more information about DART-ID')
    ))
    
  }
  
  .plotdata <- function(data, input) {
    ev <- data()[['DART-ID']]
    
    plotdata <- ev %>%
      dplyr::select(c('Raw.file', 'Modified.sequence', 'PEP', 'dart_PEP')) %>%
      dplyr::group_by(Raw.file) %>%
      dplyr::summarise(
        file=unique(Raw.file),
        ids=sum(PEP < 0.01, na.rm=T),
        new_ids=sum(dart_PEP < 0.01, na.rm=T))
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata) +
      geom_point(aes(x=ids, y=new_ids), size=3, color=rgb(0,0,1,0.7)) +
      geom_abline(intercept=0, slope=1, color=rgb(0,0,0,0.5), size=2) +
      labs(x='Peptide IDs from Spectra', y='Peptide IDs after DART-ID',
           title='Increase in Peptide IDs at PEP < 0.01') +
      theme_base(input=input) +
      theme(aspect.ratio=1)
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot
  ))
}
