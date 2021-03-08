init <- function() {
  
  type <- 'plot'
  box_title <- 'Intensity of z=1 across gradient'
  help_text <- 'Plotting the intensity of z=1 ions observed.'
  source_file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[['allPeptides']], paste0('Upload allPeptides.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['allPeptides']][,c('Raw.file', 'Charge', 'Intensity', 'Retention.time')]
    plotdata$Intensity <- log10(plotdata$Intensity)
    
    plotdata <- plotdata %>%
      dplyr::filter(Charge == 1) %>%
      dplyr::mutate_at('Intensity', funs(ifelse(. == 0, NA, .))) %>%
      dplyr::mutate(Retention.time=floor(Retention.time))
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(x=Retention.time, y=Intensity)) + 
      geom_bar(stat='identity', width=1) + 
      facet_wrap(~Raw.file, nrow=1, scales = "free_x") + 
      scale_y_continuous(labels=scales::scientific) +
      coord_flip() + 
      labs(x='Retention Time (min)', y=expression(bold('Summed Precursor Intensity, log10'))) +
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
