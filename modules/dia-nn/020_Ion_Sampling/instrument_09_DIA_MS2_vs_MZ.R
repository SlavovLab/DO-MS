init <- function() {
  
  type <- 'plot'
  box_title <- 'MS2 Intensity vs M/Z'
  help_text <- 'Plotting the MS2 Intensity versus Mass/Charge ratio. '
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload report.txt')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
    validate(need(config[['ChemicalLabels']], paste0('Please provide a list of labels under the key: ChemicalLabels in the settings.yaml file')))
    
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['report']][,c('Raw.file', 'Precursor.Quantity','Precursor.Mz','Precursor.Id')]
    labelsdata <- config[['ChemicalLabels']]
    
    
    plotdata <- plotdata %>% filter(Precursor.Quantity != 0)
    # Remove runs with less than 200 IDs
    r_t<-table(plotdata$Raw.file)
    r_rmv<-names(r_t)[r_t<2]
    plotdata<-plotdata[!plotdata$Raw.file%in%r_rmv, ]
    
    
    
    plotdata$Precursor.Mz <- round(plotdata$Precursor.Mz/25)*25
    plotdata <- plotdata %>% 
      dplyr::group_by(Raw.file, Precursor.Mz) %>% 
      dplyr::summarise(Precursor.Quantity = median(Precursor.Quantity,na.rm=T), .groups = "drop")
    
    plotdata$Intensity <- plotdata$Precursor.Quantity
    

    

    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need(nrow(plotdata) > 2, paste0('Less than 20 peptides in common')),
             need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(y=log10(Intensity),x= Precursor.Mz)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_line() + 
      coord_flip() + 
      labs(y=expression(bold('Median Log'[10]*' MS2 Intensity')), x='Precursor M/Z') + 
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
    dynamic_width=200,
    dynamic_width_base=50
  ))
}
