init <- function() {

  type <- 'plot'
  box_title <- 'Number of Precursors by Charge State'
  help_text <- 'Number of precursors observed during MS1 scans by charge state'
  source_file <- 'report'

  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload report.txt')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
    validate(need(config[['ChemicalLabels']], paste0('Please provide a list of labels under the key: ChemicalLabels in the settings.yaml file')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['report']][,c('Raw.file', 'Precursor.Charge','Ms1.Area','Precursor.Id')]
    labelsdata <- config[['ChemicalLabels']]
    
    # iterate over labels and calculate label-less ID 
    for (i in 1:length(labelsdata)){
      current_label = labelsdata[[i]]
      
      # subtract all label modifications, but not other modifications
      plotdata$Precursor.Id = gsub(paste0('\\Q',current_label,'\\E'),'',plotdata$Precursor.Id)
      
    }
    
    plotdata <- plotdata %>% 
      group_by(Raw.file, Precursor.Id) %>% 
      summarise(Ms1.Area = sum(Ms1.Area), Charge = first(Precursor.Charge), .groups = "drop")
    
    plotdata <- dplyr::filter(plotdata, Ms1.Area>0)
    
    plotdata$Charge[plotdata$Charge > 3] <- 4
    
    plotdata <- plotdata %>%
      dplyr::group_by(Raw.file, Charge) %>%
      dplyr::tally()
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata) + 
      geom_bar(aes(x=factor(Charge), y=n, fill=factor(Charge), colour=factor(Charge)), 
               stat='identity', position='dodge2', alpha=0.7) +
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x")+
      scale_fill_hue(labels=c('1', '2', '3', '>3')) + 
      labs(x='Experiment', y='Count', fill='Charge State') +
      theme_diann(input=input, show_legend=T)+
      scale_fill_manual(values = custom_colors)+
      scale_color_manual(values = custom_colors)+
      theme(axis.text.x=element_blank(),
            axis.ticks.x=element_blank())+
      theme(legend.position = "bottom")+
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
