init <- function() {
  
  type <- 'plot'
  box_title <- 'Total ID Rate'
  help_text <- 'Number of MSMS scans, PSMs, and confident PSMs'
  source_file <- 'evidence, msmsScans'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
    validate(need(data()[['msmsScans']], paste0('Upload msmsScans.txt')))
  }
  
  .plotdata <- function(data, input) {
    
    # MS2 Scans and PSMs
    a <- data()[['msmsScans']] %>%
      dplyr::select('Raw.file', 'Sequence') %>%
      dplyr::group_by(Raw.file) %>%
      dplyr::summarise(scans=dplyr::n(),
                       psms=sum(as.character(Sequence) != ' ', na.rm=T)) %>%
      dplyr::arrange(Raw.file)
    
    # IDs at 5e-2 and 1e-2 PEP
    b <- data()[['evidence']] %>%
      dplyr::select('Raw.file', 'Sequence', 'PEP','Type') %>%
      dplyr::filter(Type != "MULTI-MATCH") %>%
      dplyr::group_by(Raw.file) %>%
      dplyr::summarise(ids_0p05=sum(PEP < 0.05, na.rm=T),
                       ids_0p01=sum(PEP < 0.01, na.rm=T)) %>%
      dplyr::arrange(Raw.file)
    if(nrow(a) == nrow(b)){
    plotdata <- cbind(a, b[,-1]) %>%
      # gather = dplyr equiv. of reshape2::melt
      tidyr::gather(key, value, -Raw.file) %>%
      # rename levels
      dplyr::mutate(key=factor(key, labels=c('IDs @ PEP < 0.01', 'IDs @ PEP < 0.05', 'PSMs', 'MSMSs')))
    }else if((nrow(a) > 0) & (nrow(b) == 0)){
      plotdata <- a %>%
        tidyr::gather(key, value, -Raw.file) %>%
        # rename levels
        dplyr::mutate(key=factor(key, labels=c('PSMs', 'MSMSs')))
    }else if((nrow(a) == 0) & (nrow(b) > 0)){
      plotdata <- b %>%
        tidyr::gather(key, value, -Raw.file) %>%
        # rename levels
        dplyr::mutate(key=factor(key, labels=c('IDs @ PEP < 0.01', 'IDs @ PEP < 0.05')))
    }
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(Raw.file, value, fill=key)) +
      geom_bar(stat='identity', position='dodge') +
      labs(x='Experiment', y='Count', fill='Category') +
      theme_base(input=input, show_legend=T) +
      # keep the legend
      theme(legend.position='right',
            legend.key=element_rect(fill='white'))
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    dynamic_width=150,
    dynamic_width_base=300
  ))
}

