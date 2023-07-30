init <- function() {
  
  type <- 'plot'
  box_title <- 'Normalized Ion Mobility for Intersected Precursors'
  help_text <- 'Plotting the Ion Mobility for intersected precursors for all channels. Experiments are normalized to the first experiment. '
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload report.txt')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
    validate(need(config[['ChemicalLabels']], paste0('Please provide a list of labels under the key: ChemicalLabels in the settings.yaml file')))
    
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['report']][,c('Raw.file', 'IM','Precursor.Id')]
    labelsdata <- config[['ChemicalLabels']]
    
    # iterate over labels and calculate label-less ID 
    #for (i in 1:length(labelsdata)){
    #  current_label <- labelsdata[[i]]
      
      # subtract all label modifications, but not other modifications
   #   plotdata$Precursor.Id = gsub(paste0('\\Q',current_label,'\\E'),'',plotdata$Precursor.Id)
    #}
    
    #plotdata %>% 
    #  group_by(Raw.file, Precursor.Id) %>% 
    # summarise(IM = sum(IM), .groups = "drop")
    
    plotdata <- dplyr::filter(plotdata, IM>0)
    plotdata$Intensity = plotdata$IM
    
    # Remove runs with less than 200 IDs
    r_t<-table(plotdata$Raw.file)
    r_rmv<-names(r_t)[r_t<2]
    plotdata<-plotdata[!plotdata$Raw.file%in%r_rmv, ]
    
    # Thresholding data at 1 and 99th percentiles
    ceiling <- quantile(plotdata$Intensity, probs=.99, na.rm = TRUE)
    floor <- quantile(plotdata$Intensity, probs=.01, na.rm = TRUE)
    
    plotdata <- dplyr::filter(plotdata, is.finite(Intensity))
    
    plotdata[plotdata$Intensity >= ceiling, 2] <- ceiling
    plotdata[plotdata$Intensity <= floor, 2] <- floor
    
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
    
    
    
    plotdata <- plotdata_Intersected %>% group_by(Raw.file, Precursor.Id) %>%
      summarize(IntAvg=mean(Intensity, na.rm = TRUE), .groups = "drop")
    
    plotdata.w <- reshape2::dcast(plotdata, Precursor.Id ~ Raw.file, value = "IntAvg")
    baselineInd <- ncol(plotdata.w) + 1
    plotdata.w$baseline <- plotdata.w[,2]
    
    for (j in 2:(baselineInd-1)){
      plotdata.w[,j] <- (plotdata.w[,j])-(plotdata.w[,baselineInd])

    }
    
    plotdata.w.m <- melt(plotdata.w)
    plotdata.w.m.clean <- plotdata.w.m %>% filter(!(variable == "baseline"))
    colnames(plotdata.w.m.clean) <- c("Precursor.Id","Raw.file","Intensity")
    plotdata <- plotdata.w.m.clean

    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    validate(need(nrow(plotdata) > 19, paste0('Less than 20 peptides in common')))

    ggplot(plotdata, aes(Intensity)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_histogram(bins=50,  fill=custom_colors[[6]]) + 
      coord_flip() + 
      labs(x=expression(bold('Log2(Ion Mobility)')), y='Number of Precursors') + 
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
