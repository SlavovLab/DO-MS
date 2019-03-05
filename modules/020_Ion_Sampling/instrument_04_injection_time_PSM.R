init <- function() {
  
  type <- 'plot'
  box_title <- 'Injection times, PSM resulting'
  help_text <- 'Plotting distribution of injection times for MS2 events that did result in a PSM.'
  source_file <- 'msmsScans'
  
  .validate <- function(data, input) {
    validate(need(data()[['msmsScans']], paste0('Upload msmsScans.txt')))
    
    # MQ: sometimes get this weird parsing error where all sequences are replaced with NAs
    # unless we provide the exact column definitions (which is not viable) we can't recover
    # the lost data. if this happens then this module will cause a global crash and prevent
    # report generation, etc.
    validate(need(
      any(!is.na(data()[['msmsScans']][,'Sequence'])), 
      paste0('Parsing of peptide sequences in msmsScans.txt failed.')
    ))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['msmsScans']][,c('Raw.file', 'Ion.injection.time', 'Sequence')]
    plotdata <- plotdata[!is.na(plotdata$Sequence),]
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata, aes(Ion.injection.time)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram() + 
      coord_flip() + 
      labs(x='Ion Injection Time (ms)', y='Count') +
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
