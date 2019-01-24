init <- function() {
  
  tab <- '040 Contamination'
  boxTitle <- 'm/z Distribution for +1 ions'
  help <- 'Plotting the m/z distribution of +1 ions, a diagnostic of non-peptide contaminants'
  type <- 'plot'
  source.file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file, ".txt")))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source.file]][,c('Raw.file', 'Charge', 'm.z')] %>% 
      filter(Charge == 1)
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata, aes(m.z)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins=100) + 
      coord_flip() + 
      labs(y='Count', x='m/z') +
      theme_base(input=input)
  }
  
  return(list(
    tab=tab,
    type=type,
    boxTitle=boxTitle,
    help=help,
    source.file=source.file,
    validateFunc=.validate,
    plotdataFunc=.plotdata,
    plotFunc=.plot,
    dynamic_width=75
  ))
}
