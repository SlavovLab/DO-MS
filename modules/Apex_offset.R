##############################################################################
## Leave the following code alone:  ##########################################
##############################################################################

init <- function() {
  return(list(
    
    ##############################################################################
    ## Define information about the plot: ########################################
    ##############################################################################
    
    # What tab in the sidebar the plot will be added to:
    tab='Instrument Performance',
    
    # Title for the box drawn around the plot
    boxTitle='Apex offset',
    
    # Description of the plot and what it accomplishes
    help='Plotting the distance from the peak of the elution profile the MS2
    events were executed.',
    
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
    data.choice<-'msmsScans'
    
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
    
    # Plot:
    histdata <- data.loaded[,c("Raw.file","Precursor.apex.offset.time")]
    histdata$Precursor.apex.offset.time <- histdata$Precursor.apex.offset.time*60
    histdata$Precursor.apex.offset.time[histdata$Precursor.apex.offset.time > 8] <- 9
    histdata$Precursor.apex.offset.time[histdata$Precursor.apex.offset.time < -8] <- -9

    ggplot(histdata, aes(Precursor.apex.offset.time)) + facet_wrap(~Raw.file, nrow = 1)+ geom_histogram() + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + xlab("Apex Offset (sec)") 
    
    })
  
}

