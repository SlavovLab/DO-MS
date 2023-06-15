init <- function() {
  
  type <- 'plot'
  box_title <- 'Ms2 Fill Time Matrix'
  help_text <- 'The average Ms2 fill times are shown across the gradient for every distinct Ms2 window.'
  source_file <- 'fill_times'
  
  .validate <- function(data, input) {
    validate(need(data()[['fill_times']],paste0('Upload tic.tsv')))
    validate(need(data()[['fill_times']][['Window.Lower']],paste0('Your fill_times.tsv file does not contain the Window.Lower column for the isolation window. Please make sure that you use the latest version of DO-MS DIA.')))
    validate(need(data()[['fill_times']][['Window.Upper']],paste0('Your fill_times.tsv file does not contain the Window.Upper column for the isolation window. Please make sure that you use the latest version of DO-MS DIA.')))
    validate(need(config[['RT.Start']],paste0('Please specify RT.Start parameter in the settings')))
    validate(need(config[['RT.End']],paste0('Please specify RT.End parameter in the settings')))
  }
  
  .plotdata <- function(data, input) {
    
    plotdata <- data()[['fill_times']]
    
    plotdata <- plotdata %>% 
      filter(RT.Start > config[['RT.Start']]) %>% 
      filter(RT.Start < config[['RT.End']])
      
    #plotdata <- as.data.frame(read_tsv(file='/Users/georgwallmann/Documents/testdaten/2022_06_24_MS2_number_wGW011-wGW017/fill_times.tsv',guess_max=1e5))
    
    plotdata <- plotdata %>%
      filter(Ms.Level > 1)

    num_rt_bins = 10
    
    rt_start = min(plotdata$RT.Start)
    rt_end = max(plotdata$RT.Start)
    
    # Create RT column which has labels for N RT bins
    plotdata <- plotdata %>% 
      mutate(RT = round((RT.Start - rt_start)/(rt_end-rt_start)*num_rt_bins))
    
    # calculate mean fill times
    plotdata <- plotdata %>%
      group_by(Raw.file, Ms.Level, Window.Lower, Window.Upper,  RT) %>%
      summarise(Fill.Time = mean(Fill.Time), .groups = "drop")
    
    # Transform RT bins back to real RTs
    plotdata <- plotdata %>% 
      mutate(RT = RT/num_rt_bins*(rt_end-rt_start)+rt_start)
    
    # create label columns eg. 100 - 200 (mz)
    plotdata <- plotdata %>% 
      mutate(Label = paste0(Window.Lower, '-', Window.Upper)) %>% 
      mutate(Window = (Window.Lower + Window.Upper)/2)
    
    label_index = sort(plotdata$Window, index.return=TRUE)
    
    label_sorted = plotdata$Label[label_index$ix]
    label_unique = unique(label_sorted)
    
    plotdata$Label = factor(plotdata$Label, levels = label_unique)
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)

    ggplot(plotdata) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free") + 
      geom_tile(aes(RT, Label, fill= Fill.Time)) +
      scale_fill_viridis(discrete=FALSE) +
      labs(y='m/z', x='Retention Time in minutes', fill='Fill time (ms)') +
      theme(legend.position = "bottom",legend.key.width = unit(2.5, "cm"), axis.text.y = element_text(angle = 45, vjust = 0.5, hjust=1, size=10))+
      theme_diann(input=input, show_legend=T)
      
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    box_width=12,
    plot_height=300, # pixels
    dynamic_width=300,
    dynamic_width_base=50
  ))
}
