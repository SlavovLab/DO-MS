init <- function() {
  
  type <- 'plot'
  box_title <- 'Retention length of peptides at base'
  help_text <- 'Plotting the retention length of identified peptide peaks at the base.'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[[source_file]], paste0("Upload ", source_file,".txt")))
    validate(need( 
      'Retention.length' %in% colnames(data()[[source_file]]),
      'Column "Retention length" not found. Please run search with "Calculate peak properties" enabled (under Global Parameters/Advanced) in order to generate this column in the MaxQuant output.'
    ))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source_file]][,c('Raw.file', 'Retention.length', 'PEP')]
    plotdata$Retention.length <- plotdata$Retention.length*60
    plotdata$Retention.length[plotdata$Retention.length > 120] <- 120
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata, aes(Retention.length)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins=120) + 
      coord_flip() + 
      labs(x='Retention Lengths at base (sec)', y='Count') +
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
