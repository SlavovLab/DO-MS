init <- function() {
  
  type <- 'plot'
  box_title <- 'Intensity of z=1 across gradient'
  help_text <- 'Plotting the intensity of z=1 ions observed. This will give an if you are seeing mostly peptides or non-peptide species and where they occur in the gradient'
  source_file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[['allPeptides']], paste0('Upload allPeptides.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['allPeptides']][,c('Raw.file', 'Charge', 'Intensity', 'Retention.time')]
    
    plotdata <- plotdata %>%
      dplyr::filter(Charge == 1) %>%
      dplyr::mutate_at('Intensity', funs(ifelse(. == 0, NA, .))) %>%
      dplyr::mutate(Retention.time=floor(Retention.time))
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata, aes(x=Retention.time, y=Intensity)) + 
      geom_bar(stat='identity', width=1) + 
      facet_wrap(~Raw.file, nrow=1) + 
      scale_y_continuous(labels=scales::scientific) +
      coord_flip() + 
      labs(x='Retention Time (min)', y=expression(bold('Summed Precursor Intensity'))) +
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
