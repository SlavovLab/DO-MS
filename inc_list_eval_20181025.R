
    allPeptides <- read.delim("C:/MQ_Searches/FP71/combined/txt/allPeptides.txt")
    evidence <- read.delim("C:/MQ_Searches/FP71/combined/txt/evidence.txt")
    inc <- read.csv("C:/R-dir/ed_udiff/20181023_list.csv")
    
    # Define variables
    mz<-inc$mz
    RT.start<-inc$RTstart
    RT.end<-inc$RTend
    mz.tolerance<-20
    inc.sequence<-inc$Sequence
    
    # Set up data frame
    inc[,"never.seen"]<-1
    inc[,"seen.outside.RT"]<-0
    inc[,"seen.inside.RT"]<-0
    inc[,"seen.inside.RT.ID"]<-0
    inc[,"sequence.match"]<-0
    inc$Raw.file<-NA
    
    incF<-inc[0,]
    for(X in unique(allPeptides$Raw.file)){
      
      inc$Raw.file<-X
      
      allPeptides.t<-allPeptides[allPeptides$Raw.file%in%X,]
      
      # Never seen
      for(i in 1:nrow(inc)){
        
        res.t<-length(which(
          
          (allPeptides.t$Uncalibrated.m.z > mz[i] - mz[i]*mz.tolerance/1e6) & (allPeptides.t$Uncalibrated.m.z < mz[i] + mz[i]*mz.tolerance/1e6)
          
        ))
        
        if(res.t>0){inc$never.seen[i] <- 0}
        
      }
      
      # Seen outside RT
      for(i in 1:nrow(inc)){
        
        res.t<-length(which(
          
          (allPeptides.t$Uncalibrated.m.z > (mz[i] - mz[i]*mz.tolerance/1e6 ) ) & (allPeptides.t$Uncalibrated.m.z < (mz[i] + mz[i]*mz.tolerance/1e6)) &
            (allPeptides.t$Retention.time < RT.start[i]) & (allPeptides.t$Retention.time > RT.end[i])
          
        ))
        
        if(res.t>0){inc$seen.outside.RT[i] <- 1}
        
      }
      
      # Seen inside RT
      for(i in 1:nrow(inc)){
        
        res.t<-length(which(
          
          (allPeptides.t$Uncalibrated.m.z > (mz[i] - mz[i]*mz.tolerance/1e6)) & (allPeptides.t$Uncalibrated.m.z < (mz[i] + mz[i]*mz.tolerance/1e6)) &
            (allPeptides.t$Retention.time > RT.start[i]) & (allPeptides.t$Retention.time < RT.end[i])
          
        ))
        
        if(res.t>0){inc$seen.inside.RT[i] <- 1}
        
      }
      
      # See inside RT and IDd
      for(i in 1:nrow(inc)){
        
        res.t<-length(which(
          
          (allPeptides.t$Uncalibrated.m.z > mz[i] - mz[i]*mz.tolerance/1e6) & (allPeptides.t$Uncalibrated.m.z < mz[i] + mz[i]*mz.tolerance/1e6) &
            (allPeptides.t$Retention.time > RT.start[i]) & (allPeptides.t$Retention.time < RT.end[i]) & (allPeptides.t$Score > 0)
          
        ))
        
        if(res.t>0){inc$seen.inside.RT.ID[i] <- 1}
        
      }
      
      inc$sequence.match<-as.numeric( as.character(inc.sequence) %in% as.character(evidence$Sequence[evidence$Raw.file%in%X]) )
      
      incF<-rbind(incF,inc)
      
    }
    
    df<-aggregate(. ~ Raw.file, data = incF[,c("never.seen","seen.outside.RT","seen.inside.RT","seen.inside.RT.ID","sequence.match","Raw.file")], mean)
    
    df_melt<-melt(df, id="Raw.file")
    
    #ggplot(df_melt, aes(x = Raw.file, y = value, fill = variable)) + geom_bar(stat = "identity") 
    
    colnames(df_melt)<-c("Experiment", "Observation", "Percentage")
    levels(df_melt$Observation) <- c("Never observed", "Observed outside RT", "Observed inside RT, no ID", "Observed inside RT, ID", "Sequence match")
    
    plotdata <- df_melt

    
    ggplot(plotdata, aes(x = Experiment, y = Percentage, color = Observation)) + geom_point(size=2) + theme_base() + theme(legend.position = "right", legend.key = element_rect(fill = "white")) + scale_y_continuous(limits = c(0, 1))
    #ggplot(plotdata, aes(x = Raw.file, y = value, color = variable)) + geom_point(size=2) + theme_base(input=input)
 