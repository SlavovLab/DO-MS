init <- function() {
  
  type <- 'plot'
  box_title <- 'Miscleavage rate, PEP < 0.01'
  help_text <- 'Plotting frequency of miscleavages in confidently identified peptides.'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['evidence']][,c('Raw.file', 'Missed.cleavages', 'PEP','Type')]
    plotdata <- plotdata[plotdata$PEP<0.01, ]
    plotdata <- plotdata %>% dplyr::filter(Type != "MULTI-MATCH")
    plotdata <- plotdata %>% dplyr::select('Raw.file', 'Missed.cleavages', 'PEP')
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    plotdata <- plotdata %>% dplyr::filter(!is.na(Missed.cleavages))
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(Missed.cleavages)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_vline(aes(xintercept = mean(Missed.cleavages)),col='red',size=1) + 
      geom_histogram(bins=10) + 
      coord_flip() + 
      labs(x='Missed Cleavages', y='Count') +
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
