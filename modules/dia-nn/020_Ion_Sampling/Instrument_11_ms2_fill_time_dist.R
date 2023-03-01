init <- function() {
  
  type <- 'plot'
  box_title <- 'Ms2 Fill Time Distribution'
  help_text <- 'Ms2 fill times along gradient'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['fill_times']],paste0('Upload fill_times.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['fill_times']]
    
    plotdata <- plotdata[plotdata$RT.Start > config[['RT.Start']], ]

    plotdata <- plotdata %>% 
      filter(Ms.Level == 2)
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    maxFT <- max(plotdata$Fill.Time)
    minFT <- min(plotdata$Fill.Time)
    rangeFT <- maxFT - minFT
    minFT <- minFT - rangeFT/(15)
    maxFT <- maxFT + rangeFT/(15)
    
    ggplot(plotdata) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      labs(x='Fill times in ms', y='Scans') +
      geom_histogram(aes(x=Fill.Time), bins=15, fill=custom_colors[[6]])+
      labs(x='Fill times in ms', y=' Number of Scans') + 
      theme_diann(input=input, show_legend=T)
      
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    box_width=12,
    plot_height=300, # pixels
    dynamic_width=300,
    dynamic_width_base=50
  ))
}
