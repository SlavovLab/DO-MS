init <- function() {
  
  type <- 'plot'
  box_title <-  'Precursors by Quantification Strategy'
  help_text <- 'Number of precursors found based on quantification startegy. MS2 precursors are counted based on Precursor.Quantity > 0 and MS1 precursors are counted based on Ms1.Area > 0.'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload report.txt')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
  }

  
  .plotdata <- function(data, input) {
    plotdata <- data()[['report']][,c('Raw.file','Precursor.Quantity', 'Ms1.Area')]
    #plotdata <- as.data.frame(read_tsv(file='/Users/georgwallmann/Documents/testdaten/2022_06_24_MS2_number_wGW011-wGW017/report.tsv',guess_max=1e5))

    full_counts = plotdata %>% 
      filter(Precursor.Quantity > 0) %>% 
      group_by(Raw.file) %>% 
      tally() %>%
      mutate(Label='MS2 Quantified')
    
    ms1_counts <- plotdata %>% 
      filter(Ms1.Area > 0)%>%
      group_by(Raw.file) %>% 
      tally() %>%
      mutate(Label='MS1 Quantified')
    
    outdf = rbind(full_counts, ms1_counts)
    outdf$Label = factor(outdf$Label, levels=c('MS2 Quantified','MS1 Quantified')) 
    
    return(outdf)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)

    ggplot(plotdata, aes(x=Label, y=n, fill=Label, colour=Label)) +
      geom_bar(stat="identity", alpha=0.7) +
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x")+
      labs(x='', y='Number of Precursors', fill='Quantification', colour='Quantification') +
      theme_diann(input=input, show_legend=T) +
      theme(legend.position = "bottom",
            axis.text.x = element_blank(), 
            axis.ticks = element_blank()) +
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

