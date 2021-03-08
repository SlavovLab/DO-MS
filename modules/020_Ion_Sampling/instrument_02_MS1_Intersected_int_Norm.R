init <- function() {
  
  type <- 'plot'
  box_title <- 'MS1 intensity for identified peptides in common (normalized to reference)'
  help_text <- 'Plotting the precursor intensity for peptides identified in all experiments, normalized to the first experiment'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['evidence']][,c('Raw.file', 'Intensity','Sequence','Charge')]
    
    #plotdata<-read.delim("/Volumes/GoogleDrive/My Drive/MS/SCoPE/mPOP/dat/FP94_3/evidence.txt")[,c('Raw.file', 'Intensity','Sequence','Charge')]
    
    # Remove runs with less than 200 IDs
    r_t<-table(plotdata$Raw.file)
    r_rmv<-names(r_t)[r_t<200]
    plotdata<-plotdata[!plotdata$Raw.file%in%r_rmv, ]
    
    #plotdata$Intensity <- log2(plotdata$Intensity)
    plotdata$SeqCharge <- paste0(plotdata$Sequence,"_",plotdata$Charge)
    
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
      peptides <- dplyr::select(peptidesDF, SeqCharge)
      peplist[[i]] <- peptides
    }
    
    #Get intersection of all peptides
    intersectList <- as.vector(Reduce(intersect, peplist))
    
    #Get reduced dataframe for elements that match intersection
    plotdata_Intersected <- dplyr::filter(plotdata, SeqCharge %in% intersectList$SeqCharge)
    
    
    
    plotdata <- plotdata_Intersected %>% group_by(Raw.file, SeqCharge) %>%
      summarize(IntAvg=mean(Intensity, na.rm = TRUE))
    
    print("No Error 1")
    
    plotdata.w <- reshape2::dcast(plotdata, SeqCharge ~ Raw.file, value = "IntAvg")
    baselineInd <- ncol(plotdata.w) + 1
    print("num col")
    print(baselineInd)
    plotdata.w$baseline <- plotdata.w[,2]
    print("num col 2")
    print(ncol(plotdata.w))
    print("No Error 2")
    print(head(plotdata.w))
    
    for (j in 2:(baselineInd-1)){
      print("j =")
      print(j)
      plotdata.w[,j] <- log2(plotdata.w[,j])-log2(plotdata.w[,baselineInd])

    }
    
    print("No error 3")
    
    plotdata.w.m <- melt(plotdata.w)
    plotdata.w.m.clean <- plotdata.w.m %>% filter(!(variable == "baseline"))
    colnames(plotdata.w.m.clean) <- c("SeqCharge","Raw.file","Intensity")
    plotdata <- plotdata.w.m.clean
    print("The col names are")
    print(colnames(plotdata))
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    validate(need(nrow(plotdata) > 19, paste0('Less than 20 peptides in common')))

    print(colnames(plotdata))
    
    ggplot(plotdata, aes(Intensity)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_histogram(bins=100) + 
      xlim(c(-4,4))+
      coord_flip() + 
      labs(x=expression(bold('Log'[2]*' Intensity Relative to first experiment')), y='Number of Peptides') + 
      #xlim(-2.5, 2.5) +
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
