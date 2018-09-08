##############################################################################
## Leave the following code alone:  ##########################################
##############################################################################

init <- function() {
  return(list(
    ##############################################################################
    ## Define information about the plot: ########################################
    ##############################################################################
    
    # What tab in the sidebar the plot will be added to:
    tab='Instrument',
    
    # Title for the box drawn around the plot
    boxTitle='IDs by Retention Time',
    
    # Description of the plot and what it accomplishes
    help='help text for module',
    
    ##############################################################################
    ## Leave the following code alone:  ##########################################
    ##############################################################################
    
    moduleFunc=testModule
  ))
}

testModule <- function(input, output, session, data) {
  
  ##############################################################################
  ## Define what MaxQuant data to use:  ########################################
  ##############################################################################
  
  # Options include some of the standard MaxQuant outputs:
  #   'evidence', 'msms', 'msmsScans', 'allPeptides'
  data.choice<-'evidence'
  
  output$plot <- renderPlot({
    
    validate(need(data()[[data.choice]],paste0("Upload ", data.choice, '.txt')))
    #validate(need((input$Exp_Sets),"Loading"))
    
    ##############################################################################
    ## Manipulate your data of choice and plot away!  ############################
    ##############################################################################
    
    # Data that you chose can be called as the variable data.loaded, this an
    # object of R class 'data frame':
    
    data.loaded <- data()[[data.choice]]
    
    #df$Retention.time[df$Retention.time < 15] <- 15
    histdata <- df[,c("Raw.file","Retention.time","PEP")]
    lengthLev <- length(levels(histdata$Raw.file))
    
    maxRT <- max(histdata$Retention.time)
    
    ggplot(histdata, aes(Retention.time)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins=100) + 
      coord_flip() + 
      theme(panel.background = element_rect(fill = "white",colour = "white"), 
            panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), 
            panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),
            legend.position="none",
            axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), 
            axis.title=element_text(size=rel(1.2),face="bold"), 
            axis.text = element_text(size = rel(textVar)),
            strip.text = element_text(size=rel(textVar))) +
      xlim(10, maxRT)
  })
}
