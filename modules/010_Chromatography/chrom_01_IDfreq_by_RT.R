init <- function() {
  
  type <- 'plot'
  box_title <- 'Identification frequency across gradient'
  help_text <- 'Plotting the frequency of peptide identification across the chromatographic gradient.'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['evidence']][,c('Raw.file', 'Retention.time', 'PEP','Type')]
    plotdata <- plotdata %>% dplyr::filter(Type != "MULTI-MATCH")
    plotdata <- plotdata %>% dplyr::select('Raw.file', 'Retention.time', 'PEP')
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    maxRT <- max(plotdata$Retention.time)
    ggplot(plotdata, aes(Retention.time)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_histogram(bins=100) + 
      coord_flip() + 
      xlim(10, maxRT) +
      labs(x='Retention Time (min)', y='Number of Peptides') +
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
