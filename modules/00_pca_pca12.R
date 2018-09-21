init <- function() {
  
  tab <- 'PCA'
  boxTitle <- 'Principle components 1 vs. 2'
  help <- 'Plotting the principle components for the data matrix of reporter ion signal'
  source.file<-"evidence"
  
  .validate <- function(data, input) {
    validate(need(data()[[source.file]], paste0("Upload ", source.file,".txt")))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source.file]]

    ############## Performed on whole data set: ################
    
    # Load data
    
    ev<-plotdata
    
    
    # Define experiment names and grab them from data
    exps<-as.character(unique(ev$Raw.file))
    exps.q<-paste0(exps,"_quant")
    
    # Define modified sequence + charge column
    ev$modch<-paste0(ev$Modified.sequence,ev$Charge)
    
    # Define Reporter ion columns:
    quant_cols<-colnames(ev)[grep("Reporter.intensity.corrected.",colnames(ev))]
    
    ############## Subset dataset per experiment: ################
    
    explist<-list()
    for(W in exps){
      
      ev.t<-ev[ev$Raw.file%in%W,]
      explist[[W]]<-ev.t
      
    }
    
    
    ############## Performed per experiment: ################
    exp.q.good<-c()
    for(W in exps){
      
      ev.t<-explist[[W]]
      
      # Column normalize
      
      for(Y in c(quant_cols)){
        
        ev.t[,Y]<-ev.t[,Y]/mean(ev.t[,Y], na.rm=T)
        
      }
      
      # Replace 0 with NA, for imputation
      
      for(w in 1:nrow(ev.t)){
        
        for(Y in c(quant_cols)){
          
          if(ev.t[w,Y]==0){ ev.t[w,Y]<-NA }
          
        }
        
      }
      
      # Do any of the columns have high missing data? If so, remove:
      kc<-c()
      for(k in quant_cols){
        
        pct.na<-length(which(is.na(ev.t[,k]))) / nrow(ev.t)
        if(pct.na < 0.5){ kc<-c(kc,k)}
        print(pct.na)
      }
      
      quant_cols.t<-kc
      
      # Impute missing RI values
      
      RI_imp<-as.matrix(ev.t[,c(quant_cols.t)])
      RI_imp_res<-impute.knn(RI_imp, k = 5)
      ev.t[,c(quant_cols.t)]<-RI_imp_res$data
      
      # Row normalize
      
      for(j in 1:nrow(ev.t)){
        
        # Normalize by Normalization channel
        mean.t<-(as.numeric(ev.t[j,c(quant_cols.t)])/mean(as.numeric(ev.t[j,quant_cols.t]), na.rm=T))
        #mean.t<-(mean.t)/mean(as.numeric(ev.t[j,scRI_new]), na.rm=T)
        
        ev.t[j,quant_cols.t] <- mean.t
        
      }
      
      
      
      # Apply cell types from plate design
      ev.t.quant<-ev.t[,c(quant_cols.t,"modch")]
      
      # Record results
      explist[[W]]<-ev.t
      explist[[paste0(W,"_quant")]]<-ev.t.quant
      
      if(length(quant_cols.t) > 0){
        
        exp.q.good<-c(exp.q.good, paste0(W,"_quant"))
        
      }
      
    }
    
    
    ############## Merge normalized data: ################
    
    # Which peptides seen in >x experiments?
    
    kp<-c()
    for(i in unique(ev$modch)){
      
      ev.t<-ev
      
      num.obs<-length(unique(ev.t$Raw.file[ev.t$modch%in%i]))
      if(num.obs>0.33*length(unique(ev$Raw.file))){ kp<-c(kp,i) }
      
    }
    
    # Recombine _quant data sets
    
    ev.q<-data.frame(modch=NA,type=NA,quant=NA,experiment=NA)
    ev.q<-ev.q[0,]
    
    for(W in exp.q.good){
      
      melt.t<-melt(explist[[W]], id="modch")
      
      if(length(colnames(melt.t)) > 2){
        melt.t$experiment<-W
        colnames(melt.t)<-c("modch","type","quant","experiment")
        ev.q<-rbind(ev.q,melt.t)
      }
    }
    
    ev.q$unique_type<-paste0(ev.q$type,"_",ev.q$experiment)
    
    ev.q2<-ev.q[,c("modch","unique_type","quant")]
    
    # Find unique entries by column1 and column2: 
    # Ex remove.duplicates(TMT50,c("Sequence","Charge"))
    remove.duplicates<-function(data,Cols){
      
      return(data[!duplicated(data[,Cols]),])
      
    }
    
    # Additional filtering: Keep peptides seen in >x sets
    ev.q2<-remove.duplicates(ev.q2,c("modch","unique_type"))
    ev.q2<-ev.q2[ev.q2$modch%in%kp,]
    
    
    
    
    # Create a PCA-able matrix 
    ev.mat<-dcast(ev.q2, modch ~ unique_type, value.var = "quant")
    
    
    # Do any of the columns have high missing data? If so, remove:
    
    kc<-c()
    for(k in 2:ncol(ev.mat)){
      
      pct.na<-length(which(is.na(ev.mat[,k]))) / length(ev.mat[,2])
      if(pct.na < 0.5){ kc<-c(kc,k)}
      
    }
    
    kc<-c(1,kc)
    
    ev.mat<-ev.mat[,kc]
    
    # Impute missing entries
    ev.mat.imp<-impute.knn(as.matrix(ev.mat[,-1]), k = 5)
    ev.mat.imp<-ev.mat.imp$data
    
    #ev.mat<-explist[["FP17B_quant"]]
    #ev.mat.imp<-explist[["FP17B_quant"]][,-ncol(explist[["FP17B_quant"]])]
    
    # Subtract row mean
    for(j in 1:nrow(ev.mat.imp)){
      
      # Normalize by row mean (for PCA)
      ev.mat.imp[j,] <- ev.mat.imp[j,] - mean(as.numeric(ev.mat.imp[j,]), na.rm=T)
      
    }
    
    # # Additional filtering: remove peptides that do not change
    kp2<-c()
    for(i in unique(ev.mat$modch)){
      
      var.obs<-var(as.numeric(ev.mat.imp[ev.mat$modch%in%i,-c(grep("carrier",colnames(ev.mat)),grep("modch",colnames(ev.mat))) ]))
      if(var.obs>0.05){ kp2<-c(kp2,i) }
      
    }
    ev.mat.imp2<-ev.mat.imp[ev.mat$modch%in%kp2,]
    
    
    
    
    
    
    
    ############## PCA: ################
    
    # PCA separation of cell types
    mat.pca <- prcomp(ev.mat.imp2 ,center = TRUE,scale. = TRUE)
    pca12<-mat.pca$rotation
    
    
    # Get vector of celltypes (redundant)
    
    cellnames<-c(rownames(pca12))
    
    cells<-c()
    for(i in 1:length(cellnames)){
      
      cells<-c(cells,strsplit(cellnames[i],split = "Reporter.intensity.corrected.", fixed=T)[[1]][2])
      
    }
    
    ggplot(melt(cor(data.frame(ev.mat.imp2))), aes(Var1,Var2,fill=value), xlab="Biological Replicates")+ 
      geom_tile() + theme(axis.text.x=element_text(angle=45,hjust=1))
    
    #cells<-c(rownames(pca12))
    
    pca12<-as.data.frame(pca12)
    pca12<-round(pca12,6)
    pca12$type<-cells
    
    plotdata<-pca12
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    # validate
    .validate(data, input)
    # get plot data
    plotdata <- .plotdata(data, input)
    
    pca12<-plotdata
    
    pca1explain<-round(mat.pca$sdev[1]/sum(mat.pca$sdev),2)
    pca2explain<-round(mat.pca$sdev[2]/sum(mat.pca$sdev),2)
    pca3explain<-round(mat.pca$sdev[3]/sum(mat.pca$sdev),2)
    
    ggscatter(pca12, x = "PC1", y = "PC2", size = 7,
              main = "", xlab=paste0("\nPC1 (",pca1explain*100,"%)"), ylab = paste0("PC2 (",pca2explain*100,"%)\n") ) + scale_colour_manual(values = c("black", "red", "blue")) +
      theme(axis.text.x=element_text(angle=45,hjust=1)) + font("xy", size = 28) + font("xy.text", size = 24) + rremove("legend") 
    
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
