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
    boxTitle='Intensity of z=1 across gradient',

    # Description of the plot and what it accomplishes
    help='Plotting the intensity of z=1 ions observed. This will give an
if you are seeing mostly peptides or non-peptide species and where they occur
in the gradient',

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
    
    histdata <- data.loaded[,c("Raw.file","Charge","Intensity","Retention.time")]

    histdata <- histdata[histdata$Charge == 1,]
    histdata$Retention.time <- floor(histdata$Retention.time)
   
    # Plot:
    ggplot(histdata, aes(x = Retention.time, y = Intensity)) + geom_bar(stat = 'identity', width= 1)+ facet_wrap(~Raw.file, nrow = 1) + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + xlab("Retention Time (min)") + ylab(expression(bold("Precursor Intensity"))) 
    
  })
  
}

