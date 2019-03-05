init <- function() {
  
  type <- 'plot'
  box_title <- 'Inclusion List Evaluation'
  help_text <- 'Showing the success of targeting specific m/z values at specific Retention time (RT) windows.'
  source_file <- 'allPeptides, evidence, inclusion_list'
  
  .validate <- function(data, input) {
    validate(need(data()[['allPeptides']], paste0('Upload allPeptides.txt')))
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
    validate(need(data()[['inclusion_list']], paste0('Upload inclusion list')))
  }
  
  .plotdata <- function(data, input) {
    allPeptides <- data()[['allPeptides']]
    evidence <- data()[['evidence']]
    inc <- data()[['inclusion_list']]
    
    # Define variables
    mz <- inc$mz
    RT_start <- inc$RTstart
    RT_end <- inc$RTend
    mz_tolerance <- 20 # in 10^-6 Da
    inc_sequence <- inc$Sequence
    
    # Set up data frame
    inc[,'never_seen'] <- 1
    inc[,'seen_outside_RT'] <- 0
    inc[,'seen_inside_RT'] <- 0
    inc[,'seen_inside_RT_ID'] <- 0
    inc[,'sequence_match'] <- 0
    inc$Raw.file <- NA
    
    incF <- inc[0,]
    for(X in unique(allPeptides$Raw.file)){
      
      inc$Raw.file <- X
      allPeptides_t <- allPeptides[allPeptides$Raw.file %in% X,]
      
      
      for(i in 1:nrow(inc)) {
        
        # Never seen
        res_t <- sum(
          (allPeptides_t$Uncalibrated.m.z > mz[i] - mz[i] * mz_tolerance / 1e6) & 
          (allPeptides_t$Uncalibrated.m.z < mz[i] + mz[i] * mz_tolerance / 1e6)
        )
        
        if(res_t > 0){ inc$never_seen[i] <- 0 }
      
        # Seen outside RT
        res_t <- sum(
          (allPeptides_t$Uncalibrated.m.z > (mz[i] - mz[i] * mz_tolerance / 1e6 ) ) & 
          (allPeptides_t$Uncalibrated.m.z < (mz[i] + mz[i] * mz_tolerance / 1e6)) &
          (allPeptides_t$Retention.time < RT_start[i]) & 
          (allPeptides_t$Retention.time > RT_end[i])
        )
        
        if(res_t > 0){ inc$seen_outside_RT[i] <- 1 }
        
        # Seen inside RT  
        res_t <- sum(
          (allPeptides_t$Uncalibrated.m.z > (mz[i] - mz[i] * mz_tolerance / 1e6)) & 
          (allPeptides_t$Uncalibrated.m.z < (mz[i] + mz[i] * mz_tolerance / 1e6)) &
          (allPeptides_t$Retention.time > RT_start[i]) & 
          (allPeptides_t$Retention.time < RT_end[i])
        )
        
        if(res_t > 0){ inc$seen_inside_RT[i] <- 1 }
      
        # See inside RT and IDd  
        res_t <- sum(
          (allPeptides_t$Uncalibrated.m.z > mz[i] - mz[i] * mz_tolerance / 1e6) & 
          (allPeptides_t$Uncalibrated.m.z < mz[i] + mz[i] * mz_tolerance / 1e6) &
          (allPeptides_t$Retention.time > RT_start[i]) & 
          (allPeptides_t$Retention.time < RT_end[i]) & 
          (allPeptides_t$Score > 0)
        )
        
        if(res_t > 0){ inc$seen_inside_RT_ID[i] <- 1 }
        
      }
      
      inc$sequence_match <- as.numeric(
        as.character(inc_sequence) %in% as.character(evidence$Sequence[evidence$Raw.file %in% X])
      )
      
      incF <- rbind(incF,inc)
    }
    
    df <- aggregate(. ~ Raw.file, 
                    data = incF[,c('never_seen', 'seen_outside_RT', 'seen_inside_RT',
                                   'seen_inside_RT_ID', 'sequence_match', 'Raw.file')], 
                    mean)
    
    df_melt <- reshape2::melt(df, id='Raw.file')
    
    colnames(df_melt) <- c('Experiment', 'Observation', 'Percentage')
    levels(df_melt$Observation) <- c('Never observed', 'Observed outside RT', 
      'Observed inside RT, no ID', 'Observed inside RT, ID', 'Sequence match')
    
    return(df_melt)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata, aes(x=Experiment, y=Percentage, color=Observation)) + 
      geom_point(size=2) + 
      scale_y_continuous(limits=c(0, 1)) +
      theme_base() + 
      theme(legend.position='right', 
            legend.key=element_rect(fill='white'))
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot
  ))
}
