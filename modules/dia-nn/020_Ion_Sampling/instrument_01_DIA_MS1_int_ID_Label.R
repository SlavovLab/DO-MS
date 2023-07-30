init <- function() {
  
  type <- 'plot'
  box_title <- 'Channel wise MS1 Intensity for Precursors'
  help_text <- 'Plotting the MS1 intensity for all precursors associated with one of the defined channels.'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload report.txt')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
    validate(need(config[['ChemicalLabels']], paste0('Please provide a list of labels under the key: ChemicalLabels in the settings.yaml file')))
    
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['report']][,c('Raw.file', 'Ms1.Area', 'Precursor.Id', 'Label')]

  
    
    plotdata <- plotdata[plotdata$Ms1.Area>0,]
    

    plotdata$Intensity <- log10(plotdata$Ms1.Area)
    
    # Thresholding data at 1 and 99th percentiles
    ceiling <- quantile(plotdata$Intensity, probs=.99, na.rm = TRUE)
    floor <- quantile(plotdata$Intensity, probs=.01, na.rm = TRUE)
    
    plotdata <- dplyr::filter(plotdata, is.finite(Intensity))
    if(nrow(plotdata) > 0){
      plotdata[plotdata$Intensity >= ceiling, 2] <- ceiling
      plotdata[plotdata$Intensity <= floor, 2] <- floor
    }
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(x=Intensity, color = Label)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      stat_bin(aes(y=..count..), size = 0.8, bins=100,position = "identity",geom="step")+
      coord_flip() + 
      labs(x=expression(bold('Log'[10]*' Precursor Intensity')), y='Number of Precursors') +
      scale_fill_manual(name = "plexDIA Label:", values = custom_colors)+
      scale_color_manual(name = "plexDIA Label:", values = custom_colors)+
      theme_diann(input=input, show_legend=T)+
      theme(legend.position = "bottom")

    
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
