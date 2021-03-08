
init <- function() {
  
  type <- 'plot'
  box_title <- 'z=1/z=>2 Summed Intensity and Duty Cycle Length'
  help_text <- 'Plotting z=1/z=>2 Ion Intensites over the gradient. Binned every 30 seconds and colored by the duty cycle length.'
  source_file <- c('msScans')
  
  .validate <- function(data, input) {
    validate(need(data()[['msScans']], paste0('Upload msScans.txt')))
    validate(need(data()[['allPeptides']], paste0('Upload allPeptides.txt')))
    
  }
  
  .plotdata <- function(data, input) {
    msScanDF <- data()[['msScans']][,c('Raw.file', 'Ion.injection.time', 'MS.MS.count', 'Retention.time')]
    
    allpeps <- data()[['allPeptides']][,c('Raw.file', 'Charge', 'Retention.time', 'Intensity')]
    
    
   # msScanDF<-read.delim("/Volumes/GoogleDrive/My Drive/MS/SCoPE/mPOP/dat/FP94_3/msScans.txt")[,c('Raw.file', 'Ion.injection.time', 'MS.MS.count', 'Retention.time')]
    #allpeps<-read.delim("/Volumes/GoogleDrive/My Drive/MS/SCoPE/mPOP/dat/FP94_3/allPeptides.txt")[,c('Raw.file', 'Charge', 'Retention.time', 'Intensity')]
    
    
    allpeps <- na.omit(allpeps) #remove rows with na-values (important for downstream column summation)
    
    
    
    df_charge_final<-data.frame()
    charge2plus <- allpeps[which(allpeps$Charge >1),]
    charge1 <- allpeps[which(allpeps$Charge ==1),]
    maxRT <- max(allpeps$Retention.time)
    minRT <- min(allpeps$Retention.time)
    #bin the RT every 30 seconds to sum the TIC +2+ and TIC +1
    RTrange <- seq(from = minRT, to = maxRT, by = 0.5)
    rawfiles <- as.vector(as.matrix(unique(msScanDF$Raw.file)))
    for(k in 1:length(rawfiles)){
      charge2plusraw <- charge2plus[grepl(paste0(rawfiles[k]), charge2plus$Raw.file),]  #get for a specific raw file
      charge1_raw <- charge1[grepl(paste0(rawfiles[k]), charge1$Raw.file),]  #get for a specific raw file
      df_charge <- data.frame(matrix(0, ncol = 5, nrow = length(RTrange)-1))
      colnames(df_charge) <- c("z1_int", "z2plus_int", "RT", "avg_MSMS_count", "Raw.file")
      df_charge[,5] <- paste0(rawfiles[k])
      
      for (i in 1:length(RTrange)){
        #every 30 sec, get the z>= 2+ intensity
        temp_charge2plus <- charge2plusraw[which(charge2plusraw$Retention.time > RTrange[i] & charge2plusraw$Retention.time < RTrange[i+1]),] %>% select("Intensity", "Retention.time")
        temp_charge1 <- charge1_raw[which(charge1_raw$Retention.time > RTrange[i] & charge1_raw$Retention.time < RTrange[i+1]),]
        
        #columns sum the intensities
        temp2Int <- as.matrix(temp_charge2plus$Intensity)
        temp2sum <- colSums(temp2Int)
        temp1Int <- as.matrix(temp_charge1$Intensity)
        temp1sum <- colSums(temp1Int)
        
        df_charge[i,1] <- temp1sum
        df_charge[i,2] <- temp2sum
        df_charge[i,3] <- RTrange[i]
        
        tempMSMScount <- msScanDF[which(msScanDF$Retention.time > RTrange[i] & msScanDF$Retention.time < RTrange[i+1]),] %>% select("MS.MS.count", "Retention.time")
        
        #columns sum the intensities
        tempms <- as.matrix(tempMSMScount$MS.MS.count)
        tempms <- colMeans(tempms)
        
        df_charge[i,4] <- tempms
      }
      if(nrow(df_charge_final)>0){
        df_charge_final <- rbind(df_charge, df_charge_final)
      }
      else{
        df_charge_final <- df_charge
      }
      
    }
      
    plotdata<-plotdata <- na.omit(df_charge_final)
    plotdata$Z1_Z2_ratio <- plotdata$z1_int/plotdata$z2plus_int  #calculate the ratio of Z=1 to Z=2+

      return(plotdata)
    }
    
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(y = RT, x=log10(Z1_Z2_ratio), color = avg_MSMS_count)) + 
      geom_point(alpha = 0.7) + 
      facet_wrap(~Raw.file, nrow = 1)+#, scales = "free_x") + 
      labs(x = "Ratio of summed intensity", y = "Retention Time (min)", color = "Number of\nMS2's taken") + 
      theme_base(input=input, show_legend=T)
    

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


