init <- function() {
  
  type <- 'plot'
  box_title <- 'Relative reporter ion intensity'
  help_text <- 'Plotting the TMT reporter intensities for a single run, normalized by the channel with the highest mean reporter ion intensity.'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
    
    # require reporter ion quantification data
    validate(need(any(grepl('Reporter.intensity.corrected', colnames(data()[['evidence']]))), 
                  paste0('Loaded data does not contain reporter ion quantification')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['evidence']] %>% 
      dplyr::select(starts_with('Reporter.intensity.corrected'))
    plotdata2 <- data()[['evidence']] %>%
      dplyr::select('Raw.file')
    exp <- unique(plotdata2$Raw.file)
    
    plotdata <- log10(plotdata)
    is.na(plotdata) <- sapply(plotdata, is.infinite)
    
    mean_int <- colMeans(plotdata, na.rm=T)
    plotdata <- plotdata - plotdata[,which.max(mean_int)]
    plotdata <- reshape2::melt(plotdata)
    plotdata$Raw.file <- exp
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    unique_labels_size <- length(unique(plotdata$variable))
    TMT_labels <- c('C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11')
    plot_to_labels <- TMT_labels[1:unique_labels_size]
    
    ggplot(plotdata, aes(x=variable, y=value)) + 
      geom_violin(aes(group=variable), alpha=0.6, fill='black', 
                  kernel='rectangular') +    # passes to stat_density, makes violin rectangular
      scale_x_discrete(name ='TMT Channel', labels=plot_to_labels) +
      xlab('TMT Channel') +             
      ylab(expression(bold('Log'[10]*' RRI Intensity'))) + 
      scale_y_continuous(limits = c(-2, NA)) +
      theme_bw() + # make white background on plot
      theme_base(input=input) +
      ggtitle(unique(plotdata$Raw.file))
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
