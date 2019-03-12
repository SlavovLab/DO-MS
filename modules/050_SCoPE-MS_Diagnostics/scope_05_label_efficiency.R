init <- function() {
  
  type <- 'plot'
  box_title <- 'TMT Labelling Efficiency'
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
      dplyr::tally()
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata) +
      geom_bar(aes(x=TMT, y=n, group=TMT, fill=TMT), stat='identity') +
      facet_wrap(~Raw.file, nrow=1) +
      scale_x_discrete(labels=c('Unlabeled', 'Labeled')) +
      scale_fill_discrete(guide=F) +
      labs(x=NULL, fill=NULL, y='# Peptides') +
      theme_base(input=input) + 
      theme(axis.text.x=element_text(angle=45, hjust=1, vjust=1))
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    dynamic_width_base=150,
    dynamic_width=150
  ))
}
