init <- function() {
  
  type <- 'plot'
  box_title <- 'Features Identified by Charge'
  help_text <- 'Identified features are reported based on the charge.'
  source_file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[['allPeptides']], paste0('Upload allPeptides.txt')))
    validate(need((nrow(data()[['allPeptides']]) > 1), paste0('No Rows selected')))
  }
  
  .get_label <- function(sequence, labelsdata){
    
    label = ''
    
    for (i in 1:length(labelsdata)){
      current_label <- labelsdata[[i]]
      
      if (grepl( current_label, sequence, fixed = TRUE)){
        label <- current_label
      }
      
    }
    
    return(label)
  }
  
  .plotdata <- function(data, input) {
    featuredata <- data()[['allPeptides']][,c('Raw.file', 'm.z', 'Charge')]
    labelsdata <- config[['ChemicalLabels']]

    featuredata$Charge[featuredata$Charge > 3] <- 4
    
    featuredata_total <- featuredata %>%
      dplyr::group_by(Raw.file, Charge) %>%
      dplyr::tally()
    
    
    
    return(featuredata_total)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata) + 
      geom_bar(aes(x=Charge, y=n, fill=factor(Charge), colour=factor(Charge)), 
               stat='identity', position='dodge2', alpha=0.7) +
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") +
      labs(x='Charge State', y='Count', fill='Charge State') +
      
      theme_diann(input=input, show_legend=T) +
      theme(axis.text.x=element_blank(),
            axis.ticks.x=element_blank(),
            legend.position = "bottom") +
      scale_fill_manual(values = custom_colors)+
      scale_color_manual(values = custom_colors) + 
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

