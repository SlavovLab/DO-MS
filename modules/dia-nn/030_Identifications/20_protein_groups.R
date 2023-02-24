init <- function() {
  
  type <- 'plot'
  box_title <-  'Number of Protein Identifications'
  help_text <- 'Number of proteotypic protein IDs found per run. Protein IDs are shown across all channels in an experiment.'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload report.txt')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
}
  
  
  
  .plotdata <- function(data, input) {
    
    plotdata <- data()[['report']][,c('Raw.file', 'Ms1.Area', 'Precursor.Id','Proteotypic', 'Label', 'Protein.Ids','Protein.Group','Protein.Q.Value','PG.Q.Value')]
    plotdata <- plotdata[plotdata$Ms1.Area>0,]
    
    Proteins <- plotdata %>%
      dplyr::filter(Ms1.Area > 0) %>%
      dplyr::filter(Proteotypic == 1) %>%
      dplyr::group_by(Raw.file) %>%
      dplyr::summarise(Identifications=n_distinct(Protein.Ids), .groups = "drop")
    Proteins$Label <- 'Proteins'
    
    Proteins.Q <- plotdata %>%
      dplyr::filter(Ms1.Area > 0) %>%
      dplyr::filter(Protein.Q.Value < 0.01) %>%
      dplyr::filter(Proteotypic == 1) %>%
      dplyr::group_by(Raw.file) %>%
      dplyr::summarise(Identifications=n_distinct(Protein.Ids), .groups = "drop")
    Proteins.Q$Label <- 'Proteins, q-val < 1%'
    
    PG <- plotdata %>%
      dplyr::filter(Ms1.Area > 0) %>%
      dplyr::filter(Proteotypic == 1) %>%
      dplyr::group_by(Raw.file) %>%
      dplyr::summarise(Identifications=n_distinct(Protein.Group), .groups = "drop")
    PG$Label <- 'Protein Groups'
    
    PG.Q <- plotdata %>%
      dplyr::filter(Ms1.Area > 0) %>%
      dplyr::filter(PG.Q.Value < 0.01) %>%
      dplyr::filter(Proteotypic == 1) %>%
      dplyr::group_by(Raw.file) %>%
      dplyr::summarise(Identifications=n_distinct(Protein.Group), .groups = "drop")
    PG.Q$Label <- 'Protein Groups, q-val < 1%'
    
    plotdata <- rbind(Proteins, Proteins.Q, PG, PG.Q)
    # create custom factor levels to influence the order of labels
    levels_plot = c('Proteins', 'Proteins, q-val < 1%', 'Protein Groups', 'Protein Groups, q-val < 1%')
    plotdata <- within(plotdata, 
                       Label <- factor(Label, levels=levels_plot))
    
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)

    validate(need((nrow(plotdata) > 0), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(x=Label, y=Identifications, colour=Label, fill=Label )) +
      geom_bar(stat="identity", alpha=0.7) +
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x")+
      labs(x='', y='Number of Proteins', colour  ='Filter', fill  = 'Filter') +
      theme_diann(input=input, show_legend=T) +
      scale_fill_manual(values = custom_colors)+
      scale_color_manual(values = custom_colors)+
      theme(axis.text.x=element_blank(),
            axis.ticks.x=element_blank(),
            legend.position = "bottom")
    
    
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

