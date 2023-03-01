init <- function() {
  
  type <- 'plot'
  box_title <- 'm/z Distribution for +1 ions'
  help_text <- 'Plotting the m/z distribution of +1 ions.'
  source_file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[['allPeptides']], paste0('Upload allPeptides.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['allPeptides']][,c('Raw.file', 'Charge', 'm.z')] 
    
    plotdata <- plotdata %>% 
      dplyr::filter(Charge == 1)
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(m.z)) + 
      facet_wrap(~Raw.file, nrow=1, scales = "free_x") + 
      geom_histogram(bins=100) + 
      coord_flip() + 
      labs(y='Number of Ions', x='m/z') +
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
