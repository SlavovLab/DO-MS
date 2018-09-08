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
    boxTitle='Peptide Ion Fraction',

    # Description of the plot and what it accomplishes
    help='Plotting the peptide ion fraction, which is a measure of MS1 signal
corresponding the peptide identified divided by the total MS1 signal isolated.
This gives a measure of co-isolating peptides.',

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
    
##############################################################################
## Manipulate your data of choice and plot away!  ############################
##############################################################################
    
    # Data that you chose can be called as the variable data.loaded, this an
    # object of R class 'data frame':
    data.loaded <- data()[[data.choice]]
    
    # Plotting a histogram of Peptide Ion Fraction values for each 
    # experimental run chosen (This is a function that uses ggplot,
    # defined in global.R, see code at bottom of this document):
    facetHist(data.loaded,'PIF')
    
  })
  
}

##############################################################################
## Placed here for edification purposes only:  ###############################
##############################################################################

# facetHist <- function(DF, X) {
#   ggplot(DF, aes_string(X)) + 
#     facet_wrap(as.formula(paste("~", "Raw.file")), nrow = 1) + 
#     geom_histogram(bins=100) + 
#     coord_flip() + 
#     theme(
#       panel.background = element_rect(fill="white", colour = "white"), 
#       panel.grid.major = element_line(size=.25, linetype="solid", color="lightgrey"), 
#       panel.grid.minor = element_line(size=.25, linetype="solid", color="lightgrey"),
#       legend.position="none",
#       axis.text.x = element_text(angle=45, hjust = 1, margin=margin(r=45)),
#       axis.title = element_text(size=rel(1.2), face="bold"), 
#       axis.text = element_text(size=rel(textVar)),
#       strip.text = element_text(size=rel(textVar))
#     ) 
# }