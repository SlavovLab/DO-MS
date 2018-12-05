init <- function() {
  
  tab <- '050 SCoPE-MS Diagnostics'
  boxTitle <- 'Missing data per TMT channel'
  help <- 'Calculating the missing values reporter per run per TMT channel, reported as 0 by MaxQuant.'
  source.file<-"evidence"
  
  .validate <- function(data, input) {
    validate(need(data()[[source.file]], paste0("Upload ", source.file,".txt")))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source.file]]

    ev<-plotdata
    
    RI<-colnames(ev)[grep("Reporter.intensity.corrected.", colnames(ev))]
    
    # make RI channel names shorter -- easier to plot
    ri_col_names <- colnames(ev)[grep('Reporter.intensity.corrected.', colnames(ev))]
    new_ri_col_names <- gsub('Reporter\\.intensity\\.corrected\\.', 'RI_', ri_col_names)
    colnames(ev)[grep('Reporter.intensity.corrected.', colnames(ev))] <- new_ri_col_names
    RI <- new_ri_col_names
      
    
    nraw<-length(unique(ev$Raw.file))
    
    na.mat<-matrix(data = NA, nrow = nraw, ncol = length(RI))
    row.names(na.mat)<-unique(ev$Raw.file); colnames(na.mat)<-RI
    
    for(i in 1:dim(na.mat)[1]){
      
      for(j in 1:dim(na.mat)[2]){
        
        na.mat[i,j]<-length(which(ev[(ev$Raw.file%in%row.names(na.mat)[i]), colnames(na.mat)[j]  ] == 0 )) / length( ev[(ev$Raw.file%in%row.names(na.mat)[i]), colnames(na.mat)[j]  ] )
        
      }
      
    }
    
    
    plotdata<-na.mat
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    # validate
    .validate(data, input)
    # get plot data
    plotdata <- .plotdata(data, input)
    
    rgb.palette <- colorRampPalette(c("blue", "yellow"), space = "rgb")
    levelplot(t(plotdata), aspect="iso", main="Missing data per TMT Channel", 
              scales=list(x=list(rot=45)), xlab="", xaxt='n', ylab="", 
              col.regions=rgb.palette(120), cuts=100, at=seq(0,1,0.01))
    }
  
  return(list(
    tab=tab,
    boxTitle=boxTitle,
    help=help,
    source.file=source.file,
    validateFunc=.validate,
    plotdataFunc=.plotdata,
    plotFunc=.plot
  ))
}
