init <- function() {
  
  type <- 'plot'
  box_title <- 'Reporter ion intensity'
  help_text <- 'Plotting the TMT reporter intensities for a single run.'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
    
    # require reporter ion quantification data
    validate(need(any(grepl('Reporter.intensity.corrected', colnames(data()[['evidence']]))), 
                  paste0('Loaded data does not contain reporter ion quantification')))
  }
  
  .plotdata <- function(data, input) {
    
    TMT_labels <- c('C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11')
    
    plotdata <- data()[['evidence']] %>% 
      dplyr::filter(Type != "MULTI-MATCH") %>%
      dplyr::select(Raw.file, starts_with('Reporter.intensity.corrected')) %>%
      # rename TMT channels - match the integer at the end of the column name
      dplyr::rename_at(vars(starts_with('Reporter.intensity.corrected')),
                       funs(TMT_labels[as.numeric(str_extract(., '\\d+$'))])) %>%
      tidyr::gather('Channel', 'Intensity', -c(Raw.file)) %>%
      # reorder manually instead of alphabetically so it doesn't put 10 and 11 before 2
      # also reverse so the carriers are at the top
      dplyr::mutate(Channel=factor(Channel, levels=rev(TMT_labels))) %>%
      dplyr::mutate(Intensity=log10(Intensity)) %>%
      #dplyr::filter(!is.infinite(Intensity) & !is.na(Intensity))
      dplyr::filter(!is.na(Intensity))
      
      plotdata$Intensity <- ifelse(is.infinite(plotdata$Intensity),2,plotdata$Intensity) 
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    # compute median channel intensities
    channel_medians <- plotdata %>%
      group_by(Channel) %>%
      summarise(m=median(Intensity, na.rm=T))
    
    # map back to plotdata
    plotdata$median_intensity <- channel_medians[plotdata$Channel,]$m
    
    ggplot(plotdata) + 
      geom_violin(aes(x=Channel, y=Intensity, group=Channel, fill=Channel), alpha=0.6,
                  kernel='gaussian') +    # passes to stat_density, makes violin rectangular 
      geom_point(aes(x=Channel, y=median_intensity), color='red', shape=3, size=2) +
      facet_wrap(~Raw.file, nrow = 1) + 
      coord_flip() +
      scale_fill_discrete(guide=F) +
      scale_x_discrete(name='TMT Channel') +
      labs(title=NULL, x='TMT Channel', y=expression(bold('Log'[10]*' RI Intensity'))) +
      theme_bw() + # make white background on plot
      theme_base(input=input)
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
