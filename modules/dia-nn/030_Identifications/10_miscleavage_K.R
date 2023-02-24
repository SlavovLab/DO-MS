init <- function() {
  
  type <- 'plot'
  box_title <- 'Miscleavage Rate (K), PEP < 0.01'
  help_text <- 'Plotting frequency of lysine miscleavages in confidently identified precursors.'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload report.txt')))
  }
  
  .get_internal_occurence <- function(string, char){
    occurence <- str_count(string, pattern = paste0(char,"."))
    occurence_w_proline <- str_count(string, pattern = paste0(char,"P"))
    return(occurence-occurence_w_proline)
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['report']][,c('Raw.file', 'Stripped.Sequence', 'PEP','Ms1.Area')]
    plotdata <- plotdata[plotdata$PEP<0.01, ]
    plotdata <- plotdata[plotdata$Ms1.Area>0, ]
    
    plotdata$Missed.cleavages = sapply(plotdata$Stripped.Sequence, .get_internal_occurence, char="K")
    
    plotdata <- plotdata %>%
      dplyr::group_by(Raw.file, Missed.cleavages) %>%
      dplyr::tally()

    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)

    plotdata <- plotdata %>% dplyr::filter(!is.na(Missed.cleavages))
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(x=factor(Missed.cleavages), y=n, fill=factor(Missed.cleavages), colour=factor(Missed.cleavages)), 
           stat='identity', position='dodge2') + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_bar(stat="identity", alpha=0.7) +
      labs(x='Missed K Cleavages', y='Count') +
      theme_diann(input=input, show_legend=T) +
      theme(legend.position = "bottom")+
      scale_fill_manual(name = "", values = custom_colors)+
      scale_color_manual(name = "", values = custom_colors)+
      theme(axis.text.x=element_blank(),
            axis.ticks.x=element_blank())
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
