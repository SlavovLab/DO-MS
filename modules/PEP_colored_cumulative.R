##############################################################################
## Leave the following code alone:  ##########################################
##############################################################################

init <- function() {
  return(list(
    
    ##############################################################################
    ## Define information about the plot: ########################################
    ##############################################################################
    
    # What tab in the sidebar the plot will be added to:
    tab='Sample Quality',
    
    # Title for the box drawn around the plot
    boxTitle='PEP Histogram',
    
    # Description of the plot and what it accomplishes
    help='Plotting the number of peptides identified at each given confidence
    level.',
    
    ##############################################################################
    ## Leave the following code alone:  ##########################################
    ##############################################################################
    
    moduleFunc=testModule
    
    
  ))
}

testModule <- function(input, output, session, data) {
  
  output$plot <- renderPlot({
    
    ##############################################################################
    ## Define what MaxQuant data to use, manipulate that data, and plot:  ########
    ##############################################################################
    
    # Options include some of the standard MaxQuant outputs:
    #   'evidence', 'msms', 'msmsScans', 'allPeptides'
    data.choice<-'evidence'
    
    ##############################################################################
    ## Leave the following code alone:  ##########################################
    ##############################################################################
    
    validate(need(data()[[data.choice]],paste0("Upload ", data.choice,".txt")))
    #validate(need((length(input$Exp_Sets) == 1),"Please select a single experiment"))
    
    ##############################################################################
    ## Manipulate your data of choice and plot away!  ############################
    ##############################################################################
    
    # Data that you chose can be called as the variable data.loaded, this an
    # object of R class 'data frame':
    data.loaded <- data()[[data.choice]]
    
    data.loaded<-read.delim("G:/My Drive/MS/SCoPE/mPOP/dat/FP54/evidence.txt")
    
    # Plot:
    histdata <- data.loaded[,c("Raw.file","PEP")]
    histdata_PEP <- count(histdata,c('Raw.file','PEP'))
    DF.t <- ddply(histdata_PEP, .(Raw.file), transform, cy = cumsum(freq))
    
    # Cut off for display
    DF.t<-DF.t[DF.t$PEP<0.1,]
    
    # Rank the Experiments by most number of peptides observed
    maxnum<-c()
    rawnames<-c()
    for(X in levels(DF.t$Raw.file)){
      maxnum<-c(maxnum, max(DF.t$cy[DF.t$Raw.file%in%X]) )
      rawnames<-c(rawnames,X)
    }
    names(maxnum)<-rawnames
    rankExp<-maxnum[order(maxnum, decreasing = T)]
    rankExp_ord<-seq(1,length(rankExp),1); names(rankExp_ord)<-names(rankExp)
    DF.t$rank_ord<-NA
    for(X in levels(DF.t$Raw.file)){
      
      DF.t$rank_ord[DF.t$Raw.file%in%X] <- rankExp_ord[X]
      
    }
    
    cc <- scales::seq_gradient_pal("red", "blue", "Lab")(seq(0,1,length.out=length(rankExp_ord)))
    
    #ggplot(DF.t, aes(x=PEP, y=cy,group=Raw.file)) + geom_line(size = 1.2) + coord_flip() + scale_x_log10(limits = c(.00009,.1), breaks = c(.0001,.001,.01,.1), labels = scales::trans_format("log10", scales::math_format(10^.x))) + theme( panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"), axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=textVar)) + ylab("Number of IDs") 
    ggplot(DF.t, aes(x=PEP, color = factor(rank_ord), y=cy,group=Raw.file)) + geom_line(size = 1.2) +
      scale_colour_manual(name = "Experiment", values=cc, labels = names(rankExp_ord)) +
      coord_flip() + scale_x_log10(limits = c(.00009,.1), breaks = c(.0001,.001,.01,.1), labels = scales::trans_format("log10", scales::math_format(10^.x))) + theme( legend.key = element_rect(fill = "white"),panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"), axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=textVar)) + ylab("Number of IDs") 
    

    })
  
}

