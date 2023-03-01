init <- function() {
  
  type <- 'plot'
  box_title <- 'Features Identified across m/z'
  help_text <- 'The frequency of precursor identifications based on the Dinosaur search is plotted across the mass to charge ratio.'
  source_file <- 'features'
  
  .validate <- function(data, input) {
    validate(need(data()[['features']], paste0('Please provide a features.tsv file')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['features']][,c('Raw.file', 'mz', 'rtStart','charge','rtApex','rtEnd')]
    plotdata$Category = 'z = 1'
    plotdata$Category[plotdata$charge > 1] <- 'z > 1'

    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))

    maxMZ <- max(plotdata$mz)
    minMZ <- max(plotdata$mz)
    
    ggplot(plotdata, aes(x=mz, color = Category)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      
      stat_bin(aes(y=..count..), size = 0.8, bins=100,position = "identity",geom="step")+
      coord_flip() + 
      labs(x='m/z', y='Number of Precursors') +
      theme_diann(input=input, show_legend=T) +
      scale_color_manual(name='Charge:', values=c(custom_colors[[1]], custom_colors[[6]]))+
      theme(legend.position = "bottom")
    
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    dynamic_width=200,
    dynamic_width_base=50
  ))
}
