init <- function() {
  
  type <- 'plot'
  box_title <- 'Median intensity per TMT Channel, log10'
  help_text <- 'This plot displays the intensity of reporter ion per run per TMT channel.'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
    
    # require reporter ion quantification data
    validate(need(any(grepl('Reporter.intensity.corrected', colnames(data()[['evidence']]))), 
                  paste0('Loaded data does not contain reporter ion quantification')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['evidence']]

    
    plotdata <- plotdata %>% dplyr::filter(Type != "MULTI-MATCH")
    plotdata <- plotdata %>%
      dplyr::select('Raw.file', starts_with('Reporter.intensity.corrected')) %>%
      dplyr::group_by(Raw.file) %>%
      dplyr::summarise_at(vars(starts_with('Reporter.intensity.corrected')), 
                          function(.) { log10(median(., na.rm=T)) } )
    
    # make RI channel names shorter -- easier to plot
    ri_col_names <- colnames(plotdata)[grep('Reporter.intensity.corrected.', colnames(plotdata))]
    #ri_col_names <- gsub('Reporter\\.intensity\\.corrected\\.', '', ri_col_names)
    ri_col_names <- paste0("C",1:length(ri_col_names))
    colnames(plotdata)[-1] <- ri_col_names
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) >= 1), paste0('No Rows selected')))
    
    # transform data into matrix for levelplot
    row_names <- plotdata$Raw.file
    plotdata <- data.matrix(plotdata[,-1])
    row.names(plotdata) <- row_names
    mv<-max(plotdata)
    plotdata[is.na(plotdata)]<-0
    plotdata[(plotdata)==-Inf]<-0
    
    rgb.palette <- colorRampPalette(c('red', 'green'), space = 'rgb')
    levelplot(t(plotdata), aspect='iso', main='Median log10 intensity per TMT Channel', 
              scales=list(x=list(rot=45)), xlab='', xaxt='n', ylab='', 
              col.regions=rgb.palette(120), cuts=100, at=seq(0, mv, mv/100))
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
