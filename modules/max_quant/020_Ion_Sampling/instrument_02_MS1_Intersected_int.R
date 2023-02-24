init <- function() {
  
  type <- 'plot'
  box_title <- 'MS1 Intensity for precursors in common'
  help_text <- 'Plotting the MS1 intensity for precursors identified at any level of confidence in all loaded experiments'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['evidence']][,c('Raw.file', 'Intensity','Sequence','Charge','Type')]
    plotdata <- plotdata %>% dplyr::filter(Type != "MULTI-MATCH")
    plotdata <- plotdata %>% dplyr::select('Raw.file', 'Intensity','Sequence','Charge')
    plotdata$Intensity <- log10(plotdata$Intensity)

    # Remove runs with less than 200 IDs
    r_t<-table(plotdata$Raw.file)
    r_rmv<-names(r_t)[r_t<200]
    plotdata<-plotdata[!plotdata$Raw.file%in%r_rmv, ]
    
    plotdata$SeqCharge <- paste0(plotdata$Sequence,"_",plotdata$Charge)
    
    # Thresholding data at 1 and 99th percentiles
    ceiling <- quantile(plotdata$Intensity, probs=.99, na.rm = TRUE)
    floor <- quantile(plotdata$Intensity, probs=.01, na.rm = TRUE)
    
    plotdata <- dplyr::filter(plotdata, is.finite(Intensity))
    
    if(nrow(plotdata) > 0){
    plotdata[plotdata$Intensity >= ceiling, 2] <- ceiling
    plotdata[plotdata$Intensity <= floor, 2] <- floor
    
    #Assemble list of peptides in each Raw file
    plotdata$Raw.file <- factor(plotdata$Raw.file)
    expsInDF <- unique(plotdata$Raw.file)
    peplist <- list()
    for (i in 1:length(expsInDF)){
      peptidesDF <- dplyr::filter(plotdata, Raw.file == expsInDF[i])
      peptides <- dplyr::select(peptidesDF, SeqCharge)
      peplist[[i]] <- peptides
    }
    
    #Get intersection of all peptides
    intersectList <- as.vector(Reduce(intersect, peplist))
    
    #Get reduced dataframe for elements that match intersection
    plotdata_Intersected <- dplyr::filter(plotdata, SeqCharge %in% intersectList$SeqCharge)
    
    plotdata <- plotdata_Intersected
    }
    return(plotdata)

  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need(nrow(plotdata) > 19, paste0('Less than 20 peptides in common')),
             need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(Intensity)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_histogram(bins=100) + 
      coord_flip() + 
      labs(x=expression(bold('Log'[10]*' Precursor Intensity')), y='Number of Peptides') +
      theme_base(input=input)
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
    dynamic_width_base=150
  ))
}
