init <- function() {
  
  type <- 'plot'
  box_title <- 'TMT Channel Spearman Correlations vs. Intensity'
  help_text <- 'Calculating the spearman correlation between the peptide quantitation in different TMT channels to the carry channel for every experiment, plotted against the median RI intensity for that channel.'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
    
    # require reporter ion quantification data
    validate(need(any(grepl('Reporter.intensity.corrected', colnames(data()[['evidence']]))), 
                  paste0('Loaded data does not contain reporter ion quantification')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['evidence']]
    
    plotdata <- plotdata %>% 
      dplyr::select('Raw.file', starts_with('Reporter.intensity.corrected'))
  
    exps <- unique(plotdata$Raw.file)
    
    # Find the channel with the most intense RIs -- that one should be the carrier
    median_RI <- sapply(plotdata[,-1], median, na.rm=T)
    max_RI <- first(names(median_RI)[median_RI == max(median_RI)])
    
    raw_names <- c()
    cor_to_carry <- c()
    median_RIs <- c()
    RI_names <- c()
    
    # For each experiment, correlate each RI channel to the carrier
    for(x in exps) {
      cor_temp <- c()
      for(y in 2:ncol(plotdata)) {
        cor_t <- cor(plotdata[plotdata$Raw.file == x, y], 
                     plotdata[plotdata$Raw.file == x, max_RI], 
                     use='complete', method='spearman')
        
        cor_temp <- c(cor_temp, cor_t)
        
      }
      
      cor_to_carry <- c(cor_to_carry, cor_temp)
      RI_names <- c(RI_names, names(median_RI))
      median_RIs <- c(median_RIs, median_RI)
      raw_names <- c(raw_names, rep(x, length(median_RI)))
    }
    
    # repackage data
    df <- data.frame(raw_names, RI_names, median_RIs, cor_to_carry)
    df$medianRIs <- log10(df$median_RIs)
    colnames(df) <- c('Experiment', 'RI', 'MedianRI', 'Correlation')
    
    return(df)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata, aes(x=Correlation, y=MedianRI, color=Experiment)) +
      geom_point(size=1.5, alpha=0.5) +
      theme_base(input=input) + 
      theme(axis.text.x=element_text(angle=0, hjust=0.5),
            axis.ticks.x=element_blank(),
            axis.ticks.y=element_blank(),
            legend.position='right',
            legend.key=element_rect(fill='white'),
            panel.background=element_rect(fill='white', colour='white')) + 
      ylab(expression(bold('Median Reporter Ion Intensity (Log '[10]*')')))
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot
  ))
}
