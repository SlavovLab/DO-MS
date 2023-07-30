init <- function() {
  
  type <- 'plot'
  box_title <-  'Precursors by Modification'
  help_text <- 'Number of precursors found based on modification types specified.'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload report.txt')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
    validate(need(config[['ChemicalLabels']], paste0('Please provide a list of labels under the key: ChemicalLabels in the settings.yaml file')))
    validate(need(config[['modifications']], paste0('Please provide a list of modifications under the key: Modifications in the settings.yaml file')))
  }
  
  
  
  .get_occurence <- function(string, pattern){
    occurence <- str_count(string, pattern = pattern)
    if (occurence > 0){
      return(pattern)
    } else {
      return("Unmodified")
    }
  }
  
  .plotdata <- function(data, input) {
    
    #retrive modifications before report, so columns can be selected
    modsdata <- config[['modification_list']]
    modsdata <- modsdata[modsdata$real_mod, ]
    
    
    plotdata <- data()[['report']][,c('Raw.file', 'Ms1.Area', 'Precursor.Id', modsdata[['unimod']], 'mod_sum' )]
    plotdata <- plotdata[plotdata$Ms1.Area>0,]
    
    labelsdata <- config[['ChemicalLabels']]
    
    

    outdf <- data.frame(Raw.file=character(),
                        Modification=character(),
                        Identifications=integer(),
                        stringsAsFactors=FALSE)
    
    # Iterate over all modifications
    for (i in 1:nrow(modsdata)){
      
      current_mod <- modsdata$unimod[[i]]
      
      plotdata_mod <- plotdata[plotdata[[current_mod]] > 0, ]
      
      plotdata_mod <- plotdata_mod %>%
        dplyr::group_by(Raw.file) %>%
        dplyr::summarise(Identifications=n(), .groups = "drop")
      
      plotdata_mod$Modification <- modsdata$name[[i]]
      
      outdf <- rbind(outdf, plotdata_mod)
    }
    

    plotdata_total <- plotdata %>%
      dplyr::group_by(Raw.file) %>%
      dplyr::summarise(Identifications=n(), .groups = "drop")
    plotdata_total$Modification <- 'Total'
    
    outdf <- rbind(outdf, plotdata_total)
    
    plotdata_unmod <- plotdata[plotdata$mod_sum < 1, ]
    plotdata_unmod <- plotdata_unmod %>%
      dplyr::group_by(Raw.file) %>%
      dplyr::summarise(Identifications=n(), .groups = "drop")
    plotdata_unmod$Modification <- 'Unmodified'
    outdf <- rbind(outdf, plotdata_unmod)

    
    levels_plot = c(modsdata[['name']],'Unmodified','Total')
    outdf <- within(outdf, 
                    Modification <- factor(Modification, levels=levels_plot))
    
    return(outdf)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)

    validate(need((nrow(plotdata) > 0), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(x=Modification, y=Identifications, fill=Modification, colour=Modification)) +
      geom_bar(stat="identity", alpha=0.7) +
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x")+
      #theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
      labs(x='', y='Number of Precursors') +
      theme_diann(input=input, show_legend=T) +
      theme(legend.position = "bottom",
            axis.text.x = element_blank(), 
            axis.ticks = element_blank())+
      scale_fill_manual(values = custom_colors)+
      scale_color_manual(values = custom_colors)
    
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

