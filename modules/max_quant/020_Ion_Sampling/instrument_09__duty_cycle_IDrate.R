
init <- function() {
  
  type <- 'plot'
  box_title <- 'Identification rate faceted by duty cycle scan order and duty cycle length'
  help_text <- 'Identification rate (peptides identified at PEP < 0.01 / all scans) faceted by duty cycle scan order and duty cycle length'
  source_file <- c('msmsScans')
  
  .validate <- function(data, input) {
    validate(need(data()[['msmsScans']], paste0('Upload msmsScans.txt')))
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
    
  }
  
  .plotdata <- function(data, input) {
    msmsscans <- data()[['msmsScans']][,c('Raw.file', 'Modified.sequence', 'Charge', 'MS.scan.number')]
    
    ev <- data()[['evidence']][,c('Raw.file', 'Charge', 'Retention.time', 'Modified.sequence', 'PEP')]
    
    ev <- ev[which(ev$PEP < 0.01),]
    msmsscans$MS.scan.number <- paste0(msmsscans$MS.scan.number,"_",msmsscans$Raw.file) #scan number and raw file
    duty_length <- msmsscans %>% count(MS.scan.number)
    
    msmsscans <- msmsscans %>% left_join(duty_length, by =c("MS.scan.number" = "MS.scan.number"))
    msmsscans$dutyScan <- ave(msmsscans$MS.scan.number, msmsscans$MS.scan.number, FUN=seq_along) #counts the duty cycle scan orders
    msmsscans$seqcharge <- paste0(msmsscans$Modified.sequence, msmsscans$Charge,"_",msmsscans$Raw.file)
    
    evorder <- ev %>% arrange(Retention.time)
    evorder$seqcharge <- paste0(evorder$Modified.sequence, evorder$Charge,"_",evorder$Raw.file)
    
    
    ### label as TRUE if confidently ID'ed
    msmsscans <- msmsscans %>% mutate(confident = ifelse(msmsscans$seqcharge%in%evorder$seqcharge, "TRUE", "FALSE"))
    
    idRates <- msmsscans %>% group_by(Raw.file,n,dutyScan) %>% count(confident)
    ungroup(idRates)
    idRates$group <- paste0(idRates$n,"_",idRates$dutyScan,"_",idRates$Raw.file)
    
    IDs_T <- idRates[grepl("TRUE", idRates$confident),]  #get the True variables (confident)
    IDs_T <- ungroup(IDs_T)
    
    IDs_T <- IDs_T%>% dplyr::select(Raw.file,group, nn)
    IDs_T <- ungroup(IDs_T)
    colnames(IDs_T) <- c("Raw.file","group", "num_true_IDs")
    
    IDs_F <- idRates[grepl("FALSE", idRates$confident),]  #get the False variables (confident)
    IDs_F <- IDs_F %>% dplyr::rename("num_False_IDs" = 5)
    
    
    joined_IDs <- IDs_F %>% full_join(IDs_T, by =c("group" = "group"))
    joined_IDs <- joined_IDs %>%
      mutate("Raw.file" = ifelse(is.na(Raw.file.x), paste0(Raw.file.y),
                                 ifelse(is.na(Raw.file.y), paste0(Raw.file.x), paste0(Raw.file.x))))
    joined_IDs <- joined_IDs[,-c(1,7)] #remove the extra raw files
    joined_IDs[is.na(joined_IDs)] <- 0  #NAs are produced if there werent any ID'ed confidently.. so replace with zero
    joined_IDs$total_scans <- joined_IDs$num_False_IDs+joined_IDs$num_true_IDs
    joined_IDs$IDrate <- joined_IDs$num_true_IDs/joined_IDs$total_scans
    
    return(joined_IDs)
  }
  
  
  .plot <- function(data, input) {
    .validate(data, input)
    joined_IDs <- .plotdata(data, input)
    
    validate(need((nrow(joined_IDs) > 1), paste0('No Rows selected')))
    
    ggplot(joined_IDs, aes(x=dutyScan, y=n, fill=IDrate)) + geom_tile() +
      labs(x="Scan number", y="Total number of scans in a duty cycle") +
      scale_fill_gradientn(colours = c("maroon","yellow")) +
      geom_text(aes(label=paste0(num_true_IDs,"/",total_scans)), size =2.5) +
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") +
      theme_bw()
    
  }
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    dynamic_width=350,
    dynamic_width_base=350
  ))
}


