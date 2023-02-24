init <- function() {
  
  type <- 'plot'
  box_title <- 'Summed precursor intensity by charge state'
  help_text <- 'Plotting the summed precursor intensity by charge state.'
  source_file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[['allPeptides']],paste0('Upload allPeptides.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['allPeptides']][,c('Raw.file', 'Charge', 'Intensity')]
    
    # aggregate charge states greater than 3
    plotdata$Charge[plotdata$Charge > 3] <- 4
    # make sure that no intensities are 0 -- will trip up the log10 scale
    plotdata$Intensity[plotdata$Intensity == 0] <- NA
    
    plotdata <- plotdata %>%
      dplyr::group_by(Raw.file, Charge) %>%
      dplyr::summarise(Intensity=sum(Intensity))
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata) + 
      geom_bar(aes(x=Raw.file, y=Intensity, fill=factor(Charge), group=Raw.file), 
               stat='identity', position='dodge2') +
      scale_y_continuous(labels=scales::scientific) +
      scale_fill_hue(labels = c('1', '2', '3', '>3')) + 
      labs(x='Experiment', y='Total Ion Current', fill='Charge State') +
      theme_base(input=input, show_legend=T)
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
