init <- function() {
  
  type <- 'plot'
  box_title <- 'Single experiment only:\nReporter Ion Intensities vs. Carrier Intensities'
  help_text <- 'Comparing the reporter ion intensities for all TMT channels to the carrier channel, chosen automatically as the most intense channel (median intensity).'
  source_file <- 'msms'
  
  .validate <- function(data, input) {
    validate(need(data()[['msms']], paste0('Upload msms.txt')))
    
    # require reporter ion quantification data
    validate(need(any(grepl('Reporter.intensity.corrected', colnames(data()[['msms']]))), 
                  paste0('Loaded data does not contain reporter ion quantification')))
    
    validate(need((length(unique(data()[['msms']][,'Raw.file'])) == 1),
                  'Please select a single experiment'))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['msms']]
  
    exps <- unique(plotdata$Raw.file)
    
    RI <- colnames(plotdata)[grep('Reporter.intensity.corrected', colnames(plotdata))]
    
    median_RI <- sapply(plotdata[,RI], median, na.rm=T)
    max_RI <- names(median_RI)[median_RI == max(median_RI)]
    
    plotdata_melt <- reshape2::melt(plotdata[,RI[ RI != max_RI ] ])
    plotdata_melt$max_RI <- rep(plotdata[,max_RI], length(RI) - 1)
    
    plotdata_melt[,c('value', 'max_RI')] <- log10(plotdata_melt[,c('value', 'max_RI')])
    colnames(plotdata_melt) <- c('TMT_RI', 'Other_Channels', 'Highest_Channel')
    plotdata_melt$Raw.file <- exps
    
    return(plotdata_melt)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(x=Highest_Channel, y=Other_Channels)) + 
      xlab('Highest TMT Channel (log10)') +
      ylab('All Other TMT Channels (log10)') + 
      ggtitle(unique(plotdata$Raw.file)) + 
      geom_point(size=0.1, alpha=0.1) + 
      theme_base(input=input) + 
      theme(axis.text.x=element_text(angle=0, hjust=0.5)) +
      geom_abline(intercept=0, slope=1, color='red', size=1)
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
