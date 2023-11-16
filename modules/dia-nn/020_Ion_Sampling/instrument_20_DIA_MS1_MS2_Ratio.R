init <- function() {
  
  type <- 'plot'
  box_title <- 'MS2/MS1 Intensity Ratio for Intersected Precursors'
  help_text <- 'Plotting the MS2/MS1 Intensity Ratio for Intersected precursors.'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload report.txt')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
    
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['report']][,c('Raw.file', 'Ms1.Area', 'Precursor.Quantity', 'Precursor.Id')]
    plotdata$Ms1.Area <- as.numeric(plotdata$Ms1.Area)
    plotdata$Precursor.Quantity <- as.numeric(plotdata$Precursor.Quantity)
    
    
    #Assemble list of peptides in each Raw file
    plotdata$Raw.file <- factor(plotdata$Raw.file)
    expsInDF <- levels(plotdata$Raw.file)
    peplist <- list()
    for (i in 1:length(expsInDF)){
      peptidesDF <- dplyr::filter(plotdata, Raw.file == expsInDF[i])
      peptides <- dplyr::select(peptidesDF, Precursor.Id)
      peplist[[i]] <- peptides
    }
    #Get intersection of all peptides
    intersectList <- as.vector(Reduce(intersect, peplist))
    #Get reduced dataframe for elements that match intersection
    plotdata_Intersected <- dplyr::filter(plotdata, Precursor.Id %in% intersectList$Precursor.Id)
    plotdata <- plotdata_Intersected
    
    plotdata <- plotdata %>% 
      group_by(Raw.file, Precursor.Id) %>% 
        mutate(Ms2.Ms1.Ratio = Precursor.Quantity / Ms1.Area)
    
    plotdata <- dplyr::filter(plotdata, Ms2.Ms1.Ratio>0)
    plotdata$Ms2.Ms1.Ratio <- log2(plotdata$Ms2.Ms1.Ratio)
    # Thresholding data at 1 and 99th percentiles
    ceiling <- quantile(plotdata$Ms2.Ms1.Ratio, probs=.99, na.rm = TRUE)
    floor <- quantile(plotdata$Ms2.Ms1.Ratio, probs=.01, na.rm = TRUE)
    
    plotdata <- dplyr::filter(plotdata, is.finite(Ms2.Ms1.Ratio))
    if(nrow(plotdata) > 0){
      plotdata[plotdata$Ms2.Ms1.Ratio >= ceiling, 2] <- ceiling
      plotdata[plotdata$Ms2.Ms1.Ratio <= floor, 2] <- floor
    }
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    
    medianData = plotdata %>% group_by(Raw.file) %>%
      summarise(median = median(Ms2.Ms1.Ratio), .groups = "drop")

    
    ggplot(plotdata, aes(Ms2.Ms1.Ratio)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_histogram(bins=50, fill=custom_colors[[6]]) + 
      coord_flip() + 
      labs(x=expression(bold('Log'[2]*' Precursor Ratio')), y='Number of Precursors') +
      theme_diann(input=input, show_legend=T) +
      geom_text(data=medianData, 
                aes(label=paste0("median: ", round(median,2))), x = -Inf, y = -Inf, colour=custom_colors[[1]],
                hjust = 0, vjust=0) +
      geom_vline(data=medianData, aes(xintercept = median),col=custom_colors[[1]],size=1)
    
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
