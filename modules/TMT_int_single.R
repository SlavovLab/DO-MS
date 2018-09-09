##############################################################################
## Leave the following code alone:  ##########################################
##############################################################################

init <- function() {
  return(list(
    
    ##############################################################################
    ## Define information about the plot: ########################################
    ##############################################################################
    
    # What tab in the sidebar the plot will be added to:
    tab='Abundance',
    
    # Title for the box drawn around the plot
    boxTitle='Reporter ion intensity',
    
    # Description of the plot and what it accomplishes
    help='Plotting the TMT reporter intensities for a single run.',
    
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
    validate(need((length(input$Exp_Sets) == 1),"Please select a single experiment"))
    
    ##############################################################################
    ## Manipulate your data of choice and plot away!  ############################
    ##############################################################################
    
    # Data that you chose can be called as the variable data.loaded, this an
    # object of R class 'data frame':
    data.loaded <- data()[[data.choice]]
    
    # Plot:
    histdata2 <- dplyr::select(data.loaded,starts_with("Reporter.intensity.corrected"))
    histdata2.m <- melt(histdata2)
    histdata2.m$log10tran <- log10(histdata2.m$value)
    uniqueLabelsSize <- length(unique(histdata2.m$variable))
    TMTlabels <- c("C1","C2","C3","C4","C5","C6","C7","C8","C9","C10","C11")
    plot2Labels <- TMTlabels[1:uniqueLabelsSize]
    ggplot(histdata2.m,aes(x=variable,y=log10tran))+ 
      geom_violin(aes(group=variable,colour=variable,fill=variable),alpha=0.5, 
                  kernel="rectangular")+    # passes to stat_density, makes violin rectangular 
      xlab("TMT Channel")+             
      ylab(expression(bold("Log"[10]*" RI Intensity")))+ 
      theme_bw()+                     # make white background on plot
      theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position = "none",axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + scale_x_discrete(name ="TMT Channel", 
                                                                                                                                                                                                                                                                                                                                                                                                                                               labels=plot2Labels) 
  })
  
}

