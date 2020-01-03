init <- function() {
  
  type <- 'plot'
  box_title <- 'Retention length of peptides at base'
  help_text <- 'Plotting the retention length of identified peptide peaks at the base.'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
    validate(need( 
      ifelse('Retention.length' %in% colnames(data()[['evidence']]), T, NULL), # return NULL to fail loudly
      'Column "Retention length" not found. Please run search with "Calculate peak properties" enabled (under Global Parameters/Advanced) in order to generate this column in the MaxQuant output.'
    ))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['evidence']][,c('Raw.file', 'Retention.length', 'PEP','Type')]
    plotdata <- plotdata %>% dplyr::filter(Type != "MULTI-MATCH")
    plotdata <- plotdata %>% dplyr::select('Raw.file', 'Retention.length', 'PEP')
    plotdata$Retention.length <- plotdata$Retention.length*60
    #plotdata$Retention.length[plotdata$Retention.length > 120] <- 120
    
    # Thresholding data at 1 and 99th percentiles
    ceiling <- quantile(plotdata$Retention.length, probs=.99, na.rm = TRUE)
    floor <- quantile(plotdata$Retention.length, probs=.01, na.rm = TRUE)
    
    plotdata <- dplyr::filter(plotdata, is.finite(Retention.length))
    
    plotdata[plotdata$Retention.length >= ceiling, 2] <- ceiling
    plotdata[plotdata$Retention.length <= floor, 2] <- floor
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(Retention.length)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_histogram(bins=120) + 
      coord_flip() + 
      labs(x='Retention Lengths at base (sec)', y='Number of Peptides') +
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
