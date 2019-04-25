init <- function() {
  
  type <- 'plot'
  box_title <- 'Peptide Identification Increase by Experiment'
  help_text <- 'Increased number of peptide IDs per experiment, relative to existing IDs before DART-ID'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
    
    # ensure that table has the DART-ID residual RT
    validate(need(
      'pep_updated' %in% colnames(data()[['evidence']]), 
      paste0('Provide evidence.txt from DART-ID output, with residual RT column \"residual\"')
    ))
    
  }
  
  .plotdata <- function(data, input) {
    ev <- data()[['evidence']]
    
    plotdata <- ev %>%
      dplyr::select(c('Raw.file', 'Modified.sequence', 'PEP', 'pep_updated')) %>%
      dplyr::group_by(Raw.file) %>%
      dplyr::summarise(
        file=unique(Raw.file),
        ids=sum(PEP < 0.01),
        new_ids=sum(pep_updated < 0.01))
    
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
