init <- function() {
  
  type <- 'plot'
  box_title <- 'Missing data per TMT channel'
  help_text <- 'Calculating the missing values reporter per run per TMT channel, reported as 0 by MaxQuant.'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[[source_file]], paste0('Upload ', source_file, '.txt')))
    
    # require reporter ion quantification data
    validate(need(any(grepl('Reporter.intensity.corrected', colnames(data()[[source_file]]))), 
                  paste0('Loaded data does not contain reporter ion quantification')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source_file]]
    
    plotdata <- plotdata %>%
      select('Raw.file', starts_with('Reporter.intensity.corrected')) %>%
      group_by(Raw.file) %>%
      summarise_at(vars(starts_with('Reporter.intensity.corrected')), 
                   function(.) { sum(. == 0) / length(.) } )
    
    # make RI channel names shorter -- easier to plot
    ri_col_names <- colnames(plotdata)[grep('Reporter.intensity.corrected.', colnames(plotdata))]
    ri_col_names <- gsub('Reporter\\.intensity\\.corrected\\.', 'RI_', ri_col_names)
    colnames(plotdata)[-1] <- ri_col_names
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    # transform data into matrix for levelplot
    row_names <- plotdata$Raw.file
    plotdata <- data.matrix(plotdata[,-1])
    row.names(plotdata) <- row_names
    
    rgb.palette <- colorRampPalette(c('blue', 'yellow'), space = 'rgb')
    levelplot(t(plotdata), aspect='iso', main='Missing data per TMT Channel', 
              scales=list(x=list(rot=45)), xlab='', xaxt='n', ylab='', 
              col.regions=rgb.palette(120), cuts=100, at=seq(0, 1, 0.01))
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
