init <- function() {
  
  type <- 'plot'
  box_title <- 'Number of MS2s per PSM'
  help_text <- 'Plotting distribution of MS2 scans per PSM.'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
    
    # MQ: sometimes get this weird parsing error where all sequences are replaced with NAs
    # unless we provide the exact column definitions (which is not viable) we can't recover
    # the lost data. if this happens then this module will cause a global crash and prevent
    # report generation, etc.
    validate(need(
      any(!is.na(data()[['evidence']][,'Sequence'])), 
      paste0('Parsing of peptide sequences in Sequence.txt failed.')
    ))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['evidence']]
    plotdata <- plotdata[!is.na(plotdata$Sequence),]
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))

    ggplot(plotdata, aes(MS.MS.count)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_histogram(bins=30) + 
      coord_flip() + 
      labs(x='# MS2 per PSM', y='Number of MS2 scans') +
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
