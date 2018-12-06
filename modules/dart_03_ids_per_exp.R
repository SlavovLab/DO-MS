init <- function() {
  
  tab <- '070 DART-ID'
  boxTitle <- 'Peptide Identification Increase by Experiment'
  help <- 'Increased number of peptide IDs per experiment, relative to existing IDs before DART-ID'
  source.file <- 'evidence'
  
  .validate <- function(data, input) {
    # require the user upload the specified source file
    validate(need(data()[['evidence']],paste0("Upload ", source.file, ".txt")))
    # or, you can hard-code the source file
    validate(need(data()[['evidence']],paste0("Upload evidence.txt")))
    
    # ensure that table has the DART-ID residual RT
    validate(need('pep_updated' %in% colnames(data()[['evidence']]), 
                  paste0('Provide evidence.txt from DART-ID output, with residual RT column \"residual\"')))
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
    
    p <- ggplot(plotdata) +
      geom_point(aes(x=ids, y=new_ids), size=3, color=rgb(0,0,1,0.7)) +
      geom_abline(intercept=0, slope=1, color=rgb(0,0,0,0.5), size=2) +
      labs(x='Peptide IDs from Spectra', y='Peptide IDs after DART-ID',
           title='Increase in Peptide IDs at PEP < 0.01') +
      theme_base(input=input) +
      theme(aspect.ratio=1)
    
    return(p)
  }
  
  # package all these variables and functions into a named list
  # that our application can build its UI from
  return(list(
    tab=tab,
    boxTitle=boxTitle,
    help=help,
    source.file=source.file,
    validateFunc=.validate,
    plotdataFunc=.plotdata,
    plotFunc=.plot
  ))
}
