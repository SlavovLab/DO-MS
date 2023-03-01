
init <- function() {
  
  type <- 'plot'
  box_title <- 'MS2 scans per duty cycle'
  help_text <- 'Plotting MS2 scans per duty cycle over the active gradient, defined as retention time of first and last confidently IDd peptides (PEP < 0.01).'
  source_file <- 'msScans'
  
  .validate <- function(data, input) {
    validate(need(data()[['msScans']], paste0('Upload msScans.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['msScans']][,c('Raw.file', 'Ion.injection.time', 'MS.MS.count', 'Retention.time')]
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    plotdata2 <- data()[['evidence']][,c('Retention.time', 'PEP')]
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    rtmin<-min(plotdata2$Retention.time[plotdata2$PEP<0.01])
    rtmax<-max(plotdata2$Retention.time[plotdata2$PEP<0.01])
    
    #plotdata<-plotdata[-which(is.na(plotdata$MS.MS.count)), ]
    plotdata<-plotdata[plotdata$Retention.time>rtmin, ]
    plotdata<-plotdata[plotdata$Retention.time<rtmax, ]
    

    ggplot(plotdata, aes(y=MS.MS.count)) + 
      geom_histogram(bins=30) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      labs(y = "MS/MS per duty cycle", x="Count")+
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


