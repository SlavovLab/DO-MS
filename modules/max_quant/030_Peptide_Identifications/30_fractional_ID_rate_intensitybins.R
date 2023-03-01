init <- function() {
  
  type <- 'plot'
  box_title <- 'Fractional ID Rate by intensity'
  help_text <- 'Fractional ID rate by binned by MS1 intensity'
  source_file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[['allPeptides']], paste0('Upload allPeptides.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['allPeptides']]
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)

    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    plotdata$bins<-cut(plotdata$Intensity, breaks=c(0,1e4,1e5,1e6,1e7,1e8,1e9,1e10,1e20))
    
    plotdata$count<-plotdata$MS.MS.Count
    plotdata$count[plotdata$count > 0] <- 1
    
    plotdata <- plotdata %>% 
      dplyr::group_by(Raw.file, bins) %>%
      dplyr::mutate(idrat = mean(count))
    
    ggplot(plotdata, aes(Raw.file, idrat, fill=bins)) +
      geom_bar(stat='identity', position='dodge') +
      labs(x='Experiment', y='Fraction identified per interval', fill='MS1 intensity interval') +
      theme_base(input=input, show_legend=T) +
      # keep the legend
      theme(legend.position='right',
            legend.key=element_rect(fill='white'))
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
    dynamic_width_base=300
  ))
}

