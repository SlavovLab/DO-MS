
init <- function() {
  
  type <- 'plot'
  box_title <- 'MS1 fill-times (ms)'
  help_text <- 'Plotting the distributions of MS1 fill times for scans with total ion current greater than the 80th percentile of total ion currents.'
  source_file <- 'msScans'
  
  .validate <- function(data, input) {
    validate(need(data()[['msScans']], paste0('Upload msScans.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['msScans']][,c('Raw.file', 'Ion.injection.time','Total.ion.current')]
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    

    
    plotdata$flx<-plotdata$Total.ion.current#/plotdata$Ion.injection.time
    
    plotdata$ticbin<-cut(plotdata$flx, breaks=quantile(plotdata$flx, probs = c(0,0.8,1)) )
    plotdata<-plotdata[!is.na(plotdata$ticbin), ]
    plotdata<-plotdata[plotdata$ticbin!=levels(plotdata$ticbin)[1], ]
    
    ggplot(plotdata, aes(y=Ion.injection.time)) + 
      geom_histogram(bins=30) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      labs(y = "MS1 Ion Fill-Time (ms)", x="Number of Scans")+
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


