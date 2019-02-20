init <- function() {
  
  type <- 'plot'
  box_title <- 'Precursor Ion Fraction (PIF)'
  help_text <- 'The distribution of PIFs for identified peptides across all sets, where PIF is a measure of coisolation (1 = pure, 0 = impure).'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
  }
  
  .plotdata <- function(data, input) {
    
    plotdata <- data()[['evidence']][,c('Raw.file', 'PIF')] %>%
      # restrict to between 0 and 1
      mutate_at('PIF', funs(ifelse(. > 1, 1, .), ifelse(. < 0, 0, .)))
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata, aes(PIF)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins = 49) + 
      coord_flip() +  
      labs(x='Precursor Ion Fraction (PIF)', y='Count') +
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

