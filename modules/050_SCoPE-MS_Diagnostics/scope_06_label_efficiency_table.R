init <- function() {
  
  type <- 'table'
  box_title <- 'TMT Labelling Efficiency Table'
  help_text <- 'Comparing relative rates of IDs for peptides with, or without the TMT tag. Only compatible with searches performed with TMT as a variable mod (n-terminus and on lysine)'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
    
    # require TMT as a variable mod
    validate(need(any(grepl('TMT', data()[['evidence']]$Modifications)), 
                  paste0('Loaded data was not searched with TMT as a variable modification')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['evidence']]
    
    plotdata <- plotdata %>%
      # filter at 0.01 PEP
      dplyr::filter(PEP < 0.01) %>%
      dplyr::mutate(TMT=grepl('TMT', Modifications)) %>%
      dplyr::group_by(Raw.file, TMT) %>%
      dplyr::tally() %>%
      tidyr::spread(key=TMT, value=n) %>%
      dplyr::rename_all(funs(c('Raw.file', 'Unlabelled', 'Labelled'))) %>%
      dplyr::mutate(`Efficiency (%)`=Labelled / (Labelled + Unlabelled) * 100)
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    plotdata
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
