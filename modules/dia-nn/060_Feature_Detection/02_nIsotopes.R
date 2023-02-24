init <- function() {
  
  type <- 'plot'
  box_title <- 'Isotopic Peaks Identified per Feature'
  help_text <- 'The number of isotopic peaks identified is shown for features detected in the Dinosaur search.'
  source_file <- 'features'
  
  .validate <- function(data, input) {
    validate(need(data()[['features']], paste0('Please provide a features.tsv file')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['features']][,c('Raw.file', 'mz', 'rtStart','charge','rtApex','rtEnd','nIsotopes')]
    
    plotdata$nIsotopes[plotdata$nIsotopes > 5] <- 5
    
    plotdata <- plotdata %>%
      dplyr::group_by(Raw.file, nIsotopes) %>%
      dplyr::tally()
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    maxIsotopes <- max(plotdata$nIsotopes)
    
    ggplot(plotdata) + 
      geom_bar(aes(x=nIsotopes, y=n, fill=factor(nIsotopes), colour=factor(nIsotopes)), 
               stat='identity', position='dodge2', alpha=0.7) +
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      labs(x='Number of Isotopic Peaks', y='Features identified', fill='Isotopes') +
      scale_fill_manual(values = custom_colors)+
      scale_color_manual(values = custom_colors)+
      theme(axis.text.x=element_blank(),
            axis.ticks.x=element_blank(),
            legend.position = "bottom") +
      theme_diann(input=input, show_legend=T) +
      guides(fill = guide_legend(override.aes = list(color = NA)), 
             color = 'none', 
             shape = 'none') 

    
    
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
