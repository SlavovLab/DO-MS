init <- function() {
  
  type <- 'plot'
  box_title <- '# of Amino Acids in the Features Identified'
  help_text <- 'This provides the estimated molecular weight of the features identified. The assumed weight of an amino acid is 110Da and is used to divide the reported mass.'
  source_file <- 'allPeptides'
  
  .validate <- function(data, input) {
    validate(need(data()[['allPeptides']], paste0('Upload allPeptides.txt file')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['allPeptides']][,c('Raw.file', 'Charge', 'Retention.time', 'Retention.length', 'Mass')]
    plotdata$Retention.length <- as.numeric(plotdata$Retention.length)
    plotdata$Retention.time <- as.numeric(plotdata$Retention.time)
    plotdata$Mass <- as.numeric(plotdata$Mass)
    
    plotdata <- dplyr::mutate(plotdata, RT.Start = Retention.time)
    plotdata <- dplyr::mutate(plotdata, RT.End = RT.Start + Retention.length)
    
    # Apply retention time filter as specified in settings.yaml
    plotdata <- plotdata %>% 
      filter(RT.Start > config[['RT.Start']]) %>% 
      filter(RT.End < config[['RT.End']])

    plotdata$Category = 'z = 1'
    plotdata$Category[plotdata$Charge > 1] <- 'z > 1'
    
    # Assume amino acid weight is 110Da and make new column of # of AA's
    plotdata <- dplyr::mutate(plotdata, AACount = Mass / 110)
    plotdata$AACount <- round(plotdata$AACount)
    
    # Thresholding data at 1 and 99th percentiles
    ceiling <- quantile(plotdata$AACount, probs=.99, na.rm = TRUE)
    floor <- quantile(plotdata$AACount, probs=.01, na.rm = TRUE)
    
    plotdata <- dplyr::filter(plotdata, is.finite(AACount))
    if(nrow(plotdata) > 0){
      plotdata[plotdata$AACount >= ceiling, 2] <- ceiling
      plotdata[plotdata$AACount <= floor, 2] <- floor
    }

    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    maxRT <- max(plotdata$Retention.time)
    
    ggplot(plotdata, aes(x = AACount, fill = Category)) +
      geom_bar(stat = 'count', alpha = 0.5) +
      coord_flip() +
      xlim(0, 40) +
      labs(x='# of Amino Acids', y='Number of Features') +
      scale_color_manual(name='Charge:', values=c(custom_colors[[1]], custom_colors[[6]]))+
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
