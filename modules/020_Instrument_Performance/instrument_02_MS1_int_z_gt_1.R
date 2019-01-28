init <- function() {
  
  type <- 'plot'
  box_title <- 'MS1 Intensity for z>1 ions'
  help_text <- 'Plotting the MS1 intensity for all peptide-like ions observed (not necessarily sent to MS2) across runs.'
  source_file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[[source_file]], paste0('Upload ', source_file, '.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source_file]][,c('Raw.file', 'Charge', 'Intensity')]
    plotdata$Intensity <- log10(plotdata$Intensity)
    plotdata <- plotdata[plotdata$Charge > 1,]
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata, aes(Intensity)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram() + 
      coord_flip() + 
      labs(x=expression(bold('Log'[10]*' Precursor Intensity')), y='Count') +
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
    dynamic_width=150
  ))
}
