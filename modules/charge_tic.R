##############################################################################
## Leave the following code alone:  ##########################################
##############################################################################

init <- function() {
  return(list(
    
##############################################################################
## Define information about the plot: ########################################
##############################################################################
    
    # What tab in the sidebar the plot will be added to:
    tab='Contamination',
    
    # Title for the box drawn around the plot
    boxTitle='TIC of ions by charge state',

    # Description of the plot and what it accomplishes
    help='Plotting the TIC of charge states observed. This will give an
if you are seeing mostly peptides or non-peptide species',

##############################################################################
## Leave the following code alone:  ##########################################
##############################################################################

    moduleFunc=testModule
  
    
    ))
}

testModule <- function(input, output, session, data) {
  
  output$plot <- renderPlot({

##############################################################################
## Define what MaxQuant data to use:  ########################################
##############################################################################
    
    # Options include some of the standard MaxQuant outputs:
    #   'evidence', 'msms', 'msmsScans', 'allPeptides'
    data.choice<-'allPeptides'

##############################################################################
## Leave the following code alone:  ##########################################
##############################################################################
    
    validate(need(data()[[data.choice]],paste0("Upload ", data.choice,".txt")))
    
##############################################################################
## Manipulate your data of choice and plot away!  ############################
##############################################################################
    
    # Data that you chose can be called as the variable data.loaded, this an
    # object of R class 'data frame':
    data.loaded <- data()[[data.choice]]
    
    histdata <- data.loaded[,c("Raw.file","Charge","Intensity")]

    histdata$Charge[histdata$Charge > 3] <- 4
    hc <- aggregate(histdata$Intensity, by=list(Category=histdata$Raw.file,histdata$Charge), FUN=sum)
    colnames(hc) <- c("Raw.file","Charge","Intensity")
    
    # Plot:
    ggplot(hc, aes(x=Raw.file, y=Intensity,colour=factor(Charge), group=Raw.file)) + 
      geom_point(size = 2)+ theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),axis.text.x =element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + 
      ylab("Number")  + labs(x = "Experiment", y = "Total Ion Current", col = "Charge State") + scale_y_log10() +  scale_color_hue(labels = c("1","2","3",">3")) + labs(x = "Experiment", y = "Count", col = "Charge State")
    
  })
  
}

