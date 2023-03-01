init <- function() {
  
  type <- 'plot'
  box_title <- 'Features Identified by Charge'
  help_text <- 'Identified features are reported based on the charge. Precursors quantified in seperate channels are treated as separate precursors..'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['features']], paste0('Please provide a features.tsv file')))
    validate(need(data()[['report']], paste0('Upload report.tsv')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
    validate(need(config[['ChemicalLabels']], paste0('Please provide a list of labels under the key: ChemicalLabels in the settings.yaml file')))
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
    plotdata <- data()[['report']][,c('Raw.file', 'Ms1.Area', 'Precursor.Id','Protein.Group')]
    featuredata <- data()[['features']][,c('Raw.file', 'mz', 'rtStart','charge','rtEnd')]
    labelsdata <- config[['ChemicalLabels']]

    featuredata$charge[featuredata$charge > 3] <- 4
    
    featuredata_total <- featuredata %>%
      dplyr::group_by(Raw.file, charge) %>%
      dplyr::tally()
    
    
    
    return(featuredata_total)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata) + 
      geom_bar(aes(x=charge, y=n, fill=factor(charge), colour=factor(charge)), 
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

