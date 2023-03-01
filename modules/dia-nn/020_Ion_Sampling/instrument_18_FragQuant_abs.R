init <- function() {
  
  type <- 'plot'
  box_title <- 'Median fragment intensities by MZ bin'
  help_text <- 'Plotting the median fragment intensities in 5 dalton m/z bin for top 10 most abundant intersected precursors. '
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload report.txt')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
    validate(need(config[['ChemicalLabels']], paste0('Please provide a list of labels under the key: ChemicalLabels in the settings.yaml file')))
    
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['report']][,c('Raw.file', 'Ms1.Area','Precursor.Id','Fragment.Quant.Raw','Fragment.Info')]
    
    
    
    plotdata_top10 <- plotdata %>% dplyr::filter(Raw.file == unique(plotdata$Raw.file)[1])
    plotdata_top10 <- plotdata_top10 %>% dplyr::filter(quantile(Ms1.Area, 0.9)<Ms1.Area)
    
    
    plotdata <- plotdata %>% dplyr::filter(Precursor.Id %in% plotdata_top10$Precursor.Id)
    
    
    # Remove runs with less than 200 IDs
    r_t<-table(plotdata$Raw.file)
    r_rmv<-names(r_t)[r_t<2]
    plotdata<-plotdata[!plotdata$Raw.file%in%r_rmv, ]
    
    
    
    
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
    plotdata <- dplyr::filter(plotdata, Precursor.Id %in% intersectList$Precursor.Id)
    plotdata <- plotdata %>% group_by(Raw.file) %>% distinct(Precursor.Id,.keep_all = T)
    
    plotdata$Raw.file <- as.character(plotdata$Raw.file)
     
    count = 0
    for(i in unique(plotdata$Raw.file)){
      count = count + 1
      plotdata_Intersected_file <- plotdata %>% filter(Raw.file == i)
      plotdata_Intersected_file <- plotdata_Intersected_file[order(plotdata_Intersected_file$Precursor.Id),]
      frag_df_quant <- matrix(data = NA,nrow = nrow(plotdata_Intersected_file), ncol = 13)
      frag_df_info <- matrix(data = NA,nrow = nrow(plotdata_Intersected_file), ncol = 13)

      for (j in 1:nrow(frag_df_quant)){
        frag_df_quant[j,1:length(unlist(str_split(plotdata_Intersected_file$Fragment.Quant.Raw[j],";")))] <- unlist(str_split(plotdata_Intersected_file$Fragment.Quant.Raw[j],";"))
        frag_df_info[j,1:length(unlist(str_split(plotdata_Intersected_file$Fragment.Quant.Raw[j],";")))] <- unlist(str_split(plotdata_Intersected_file$Fragment.Info[j],";"))

      }

      frag_df_info <- gsub(".*/","",frag_df_info)

      frag_df_info <- matrix(as.numeric(frag_df_info),    # Convert to numeric matrix
                             ncol = ncol(frag_df_info))
      frag_df_quant <- matrix(as.numeric(frag_df_quant),    # Convert to numeric matrix
                              ncol = ncol(frag_df_quant))


      frag_df_info <- melt(frag_df_info)
      frag_df_quant <- melt(frag_df_quant)

      frag_df_quant <- frag_df_quant %>% dplyr::select(value)
      frag_df_quant$Frag <- frag_df_info$value
      colnames(frag_df_quant)[1] <- 'Intensity'
      frag_df_quant$Run <- as.character(i)

      if(count == 1){
        frag_df_final_hold <- frag_df_quant
        frag_df_final <- frag_df_quant
        frag_df_final$Intensity <- log10(frag_df_final_hold$Intensity)

      }else{
        frag_df_quant$Intensity <- log10(frag_df_quant$Intensity)
        frag_df_final <- rbind(frag_df_final,frag_df_quant)
      }


    }

    frag_df_final <- frag_df_final %>% filter(Frag < 1201)
    frag_df_final$Frag <- round(frag_df_final$Frag/10)*10
    frag_df_final <- frag_df_final %>% group_by(Run,Frag) %>% summarise(Intensity = median(Intensity,na.rm = T))
    plotdata <- frag_df_final
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    validate(need(nrow(plotdata) > 19, paste0('Less than 20 peptides in common')))

    ggplot(plotdata,aes(y = Intensity,x = Frag)) + geom_line()+
      facet_wrap(~Run, nrow = 1, scales = "free_x")+
      ylab('log10(Median fragment intensity)') +xlab('Fragment M/Z')+rremove("legend")  + 
      theme_diann(input=input, show_legend=T)+coord_flip()


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
