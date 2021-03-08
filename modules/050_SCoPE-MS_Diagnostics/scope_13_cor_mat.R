init <- function() {
  
  type <- 'plot'
  box_title <- 'Single experiment only:\nReporter ion channel spearman correlations'
  help_text <- 'Plotting all pairwise TMT reporter ion intensity channel correlations (Spearman) for a single run.'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
    
    # require reporter ion quantification data
    validate(need(any(grepl('Reporter.intensity.corrected', colnames(data()[['evidence']]))), 
                  paste0('Loaded data does not contain reporter ion quantification')))
    
    validate(need((length(unique(data()[['evidence']][,'Raw.file'])) == 1),
                  'Please select a single experiment'))
    
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['evidence']] %>% 
      dplyr::filter(Type != "MULTI-MATCH") %>%
      dplyr::select(starts_with('Reporter.intensity.corrected'))
    plotdata2 <- data()[['evidence']] %>% 
      dplyr::select('Raw.file', starts_with('Reporter.intensity.corrected'))
      exp <- unique(plotdata2$Raw.file)
    
    plotdata <- cor(plotdata, use="pairwise.complete.obs", method="spearman")

    plotdata <- reshape2::melt(plotdata)
    plotdata$Raw.file <- exp
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    unique_labels_size <- length(unique(plotdata$Var1))
    TMT_labels <- c('C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11',
                    'C12', 'C12', 'C14', 'C15', 'C16')
    plot_to_labels <- TMT_labels[1:unique_labels_size]
    
    ggplot(plotdata, aes(x=Var1, y=Var2, fill=value)) + 
      geom_tile() +
      scale_fill_gradient2(low="blue", mid = "white", high = "red", midpoint = 0.5) +
      scale_x_discrete(name='TMT Channel', labels=plot_to_labels) +
      scale_y_discrete(name='TMT Channel', labels=plot_to_labels) +
      labs(x='TMT Channel', y=NULL, fill='Correlation') +
      theme_bw() + # make white background on plot
      theme_base(input=input) +
      theme(axis.text.x=element_text(angle=0, hjust=0.5),
            axis.ticks.x=element_blank(),
            axis.ticks.y=element_blank(),
            legend.position='right',
            legend.key=element_rect(fill='white'),
            panel.background=element_rect(fill='white', colour='white')) +
      ggtitle(unique(plotdata$Raw.file))
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot
  ))
}
