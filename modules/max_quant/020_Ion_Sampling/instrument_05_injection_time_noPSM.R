init <- function() {
  
  type <- 'plot'
  box_title <- 'Injection times, no PSM resulting'
  help_text <- 'Plotting distribution of MS2 injection times for scans that did not result in a PSM.'
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
    plotdata <- plotdata[is.na(plotdata$Sequence),]
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(Ion.injection.time)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_histogram(bins=30) + 
      coord_flip() + 
      labs(x='Ion Injection Time (ms)', y='Number of Ions') +
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

