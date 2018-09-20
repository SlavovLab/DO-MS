rm(list=ls())
dev.off(dev.list()["RStudioGD"])

#source("https://bioconductor.org/biocLite.R")
#biocLite("impute")
library(impute)
library(ggpubr)
library(reshape2)
library(ggplot2)
library(DMwR)


############## Performed on whole data set: ################

# Load data
#ev<-read.delim("G:/My Drive/MS/SCoPE/QC/dat/SQC95A/evidence.txt")
#ev<-read.delim("G:/My Drive/MS/SCoPE/QC/dat/QC87/evidence.txt")

ev<-read.delim("G:/My Drive/MS/SCoPE/mPOP/dat/FP1/evidence.txt")


# Define experiment names and grab them from data
exps<-as.character(unique(ev$Raw.file))
exps.q<-paste0(exps,"_quant")
exps.ind<-c()
ev$exp<-NA
for(Z in exps){
  
  exps.ind<-c(exps.ind,grep(Z, ev$Raw.file))
  ev$exp[grep(Z, ev$Raw.file)]<-Z
  
}
ev<-ev[exps.ind,]


# Define modified sequence + charge column
ev$modch<-paste0(ev$Modified.sequence,ev$Charge)


# Filter based on other criteria
ev<-ev[ev$PEP<0.02,]
ev<-ev[ev$Reverse!="+",]
ev<-ev[ev$Potential.contaminant!="+",]
ev<-ev[ev$PIF>0.8,]

# What is left after this level of filtering?
table(ev$Raw.file)

# Define Carrier(s)
#cRI<-paste0("Reporter.intensity.",c(0,1))
cRI<-paste0("Reporter.intensity.",c(0))

# Define norm channel(s)
nRI<-paste0("Reporter.intensity.",c(2))

# Define SC
#scRI<-paste0("Reporter.intensity.",seq(4,9,1))
scRI<-paste0("Reporter.intensity.",seq(3,10,1))


# # Record possible scRI contaminents (unexpected scRI:cRI ratios)

ev$scRI_contam<-0

for(i in 1:nrow(ev)){

  for(X in scRI){

    ratio.t <- ev[i,X] / mean(as.numeric(ev[i,cRI]), na.rm=T)

    if(!is.na(ratio.t)){
      # Contaminent
      if(log10(ratio.t) > -1){ ev$scRI_contam[i] <- ev$scRI_contam[i] + 1 }
      # 0 value measured in scRI
      if(log10(ratio.t)==-Inf){ ev$scRI_contam[i] <- ev$scRI_contam[i] + 1 }
      
    }

  }

}

# Remove peptides with spurious scRI
ev<-ev[ev$scRI_contam==0,]

############## Subset dataset per experiment: ################

explist<-list()
for(W in exps){
  
  ev.t<-ev[ev$exp%in%W,]
  explist[[W]]<-ev.t
  
}


############## Performed per experiment: ################
exps.good<-c()
for(W in exps){
  
  ev.t<-explist[[W]]
  
  # # Test that scRI channels' raw intensity correlates well to carrier, otherwise empty
  scRI_new<-c()
  for(X in scRI){

    cRI_intensity<-ev.t[,cRI]
    scRI_intensity<-ev.t[,X]

    ratio.t <- log10(median(scRI_intensity / cRI_intensity, na.rm = T))
    cor.t<-cor(cRI_intensity, scRI_intensity, method = "spearman", use="complete.obs")

    if( (cor.t > 0.4)&&(ratio.t > -1.6) ){ scRI_new <- c(scRI_new, X)}
    
    #cell.t<-as.character((plate[which(scRI%in%X),which(exps%in%W)]))
    
    #if(cell.t=="0"){ scRI_new <- c(scRI_new, X)}
    
  }
  
  #scRI_new<-scRI
  
  # Column normalize
  
  for(Y in c(scRI_new, cRI, nRI)){
    
    ev.t[,Y]<-ev.t[,Y]/median(ev.t[,Y], na.rm=T)
    
  }
  
  # Replace 0 with NA, for imputation
  
  
  for(w in 1:nrow(ev.t)){
    
    for(Y in c(scRI_new, cRI, nRI)){
      
      if(ev.t[w,Y]==0){ ev.t[w,Y]<-NA }
      
    }
    
  }
  
  # Impute missing RI values
  
  RI_imp<-as.matrix(ev.t[,c(cRI,scRI_new, nRI)])
  RI_imp_res<-impute.knn(RI_imp, k = 5)
  ev.t[,c(cRI,scRI_new, nRI)]<-RI_imp_res$data
  
  # Row normalize
  
  for(j in 1:nrow(ev.t)){

    # Normalize by Normalization channel
    mean.t<-(as.numeric(ev.t[j,c(scRI_new, cRI)])/mean(as.numeric(ev.t[j,nRI]), na.rm=T))
    #mean.t<-(mean.t)/mean(as.numeric(ev.t[j,scRI_new]), na.rm=T)
    
    ev.t[j,c(scRI_new, cRI)] <- mean.t

  }
  
  # Apply cell types from plate design
  ev.t.quant<-ev.t[,c(scRI_new,cRI,"modch")]
  plate.col<-which(exps%in%W)
  celltypes<-as.character(plate[scRI%in%scRI_new, plate.col])
  
  # Assign unique identifiers for same cell types
  for(X in unique(celltypes)){
    
    ind.X<-which(celltypes%in%X)
    celltypes[ind.X] <- paste0(X,".",1:length(ind.X))
    
  }
  
  colnames(ev.t.quant)<-c(celltypes,"carrier.","modch")
  
  # Record results
  explist[[W]]<-ev.t
  explist[[paste0(W,"_quant")]]<-ev.t.quant
  
  if(length(scRI_new)>0){
    
    exps.good<-c(exps.good,W)
  }
  
  
  
}

exps.good.q<-paste0(exps.good,"_quant")

exps<-exps.good
exps.q<-exps.good.q








############## Merge normalized data: ################

# Which peptides seen in >x experiments?

kp<-c()
for(i in unique(ev$modch)){
  
  ev.t<-ev[ev$exp%in%exps.good,]
  
  num.obs<-length(unique(ev.t$exp[ev.t$modch%in%i]))
  if(num.obs>2){ kp<-c(kp,i) }
  # if(num.obs>1){ kp<-c(kp,i) } # Fig
  
}

# Recombine _quant data sets

ev.q<-data.frame(modch=NA,type=NA,quant=NA,experiment=NA)
ev.q<-ev.q[0,]

for(W in exps.q){
  
  melt.t<-melt(explist[[W]], id="modch")
  melt.t$experiment<-W
  colnames(melt.t)<-c("modch","type","quant","experiment")
  ev.q<-rbind(ev.q,melt.t)
  
}

ev.q$unique_type<-paste0(ev.q$type,"_",ev.q$experiment)

source('sourceme.R')
ev.q2<-ev.q[,c("modch","unique_type","quant")]

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
  
  cells<-c(cells,strsplit(cellnames[i],split = ".", fixed=T)[[1]][1])
  
}

ggplot(melt(cor(ev.mat.imp2)), aes(Var1,Var2,fill=value), xlab="Biological Replicates")+ 
  geom_tile() + theme(axis.text.x=element_text(angle=45,hjust=1))

#cells<-c(rownames(pca12))

pca12<-as.data.frame(pca12)
pca12<-round(pca12,6)
pca12$type<-cells

pca1explain<-round(mat.pca$sdev[1]/sum(mat.pca$sdev),2)
pca2explain<-round(mat.pca$sdev[2]/sum(mat.pca$sdev),2)

ggscatter(pca12, x = "PC1", y = "PC2" , color="type", size = 7,
          main = "", xlab=paste0("PC1"), ylab = paste0("PC2") ) + scale_colour_manual(values = c("black", "red", "blue")) +
  theme(axis.text.x=element_text(angle=45,hjust=1)) + font("xy", size = 28) + font("xy.text", size = 24) + rremove("legend") + #+ggtitle(paste0(dim(ev.mat.imp2[,-grep("carrier",colnames(ev.mat.imp2))])[1]," peptides\n",dim(ev.mat.imp2[,-grep("carrier",colnames(ev.mat.imp2))])[2]," single cells")) + font("xy", size = 24) + font("xy.text", size = 20)
annotate("text", x=-0.15, y=-0.15, label= "HEK-293", size=10, col="red")+
annotate("text", x=0.1, y=-0.1, label= "U-937", size=10, col="blue") +
  annotate("text", x=-0.1, y=-.3, label= "carrier", size=10, col="black")

ggsave("HU_pca.png", device = "png", width = 7, height = 7)
ggsave("HU_pca.pdf", device = "pdf", width = 7, height = 7)


# ggscatter(pca12, x = "PC1", y = "PC2" , color="type", size = 5,
#           main = "", xlab=paste0("PC1 (",pca1explain*100,"%)"), ylab = paste0("PC2 (",pca2explain*100,"%)")) +
#   theme(axis.text.x=element_text(angle=45,hjust=1)) + rremove("legend") +
#   scale_x_continuous(limits = c(-0.3, 0.2)) +
#   annotate("text", x=-0.2, y=-0.1, label= "HEK-293", size=10, col="darkgreen")+
#   annotate("text", x=0.15, y=-0.05, label= "U-937", size=10, col="darkblue") +
#   theme(text = element_text(size = 24)) 

# ggscatter(pca12, x = "PC1", y = "PC2" , color="type", size = 5,
#           main = "", xlab=paste0("PC1"), ylab = paste0("PC2")) +
#   theme(axis.text.x=element_text(angle=45,hjust=1)) + rremove("legend") +
#   scale_x_continuous(limits = c(-0.3, 0.2)) +
#   annotate("text", x=-0.2, y=-0.1, label= "HEK-293", size=10, col="green3")+
#   annotate("text", x=0.15, y=-0.05, label= "U-937", size=10, col="blue1") +
#   annotate("text", x=-0.18, y=.09, label= "carrier", size=10, col="red3") +
#   theme(text = element_text(size = 24)) 


# ggscatter(pca12, x = "PC1", y = "PC2" , color="type", size = 5,
#           main = "", xlab=paste0("PC1"), ylab = paste0("PC2")) +
#   theme(axis.text.x=element_text(angle=45,hjust=1)) + rremove("legend") +
#   scale_x_continuous(limits = c(-0.2, 0.2)) +
#   annotate("text", x=-0.15, y=0.1, label= "HEK-293", size=10, col="green3")+
#   annotate("text", x=0.15, y=0.14, label= "U-937", size=10, col="blue1") +
#   annotate("text", x=-0.18, y=.3, label= "carrier", size=10, col="red3") +
#   theme(text = element_text(size = 24)) 
# 
# ggsave("sc_draft_pipeline_pca2.pdf", width=8, height =6)


# Plot: number of quantified proteins as a function of number of cells quantified
# - bootstraped sampling for different cell amounts