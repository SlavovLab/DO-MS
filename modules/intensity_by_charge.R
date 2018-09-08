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
    boxTitle='MS1 Intensity, +1 ions',

    # Description of the plot and what it accomplishes
    help='Plotting the intensity distribution of +1 ions, a diagnostic of 
non-peptide contaminants',

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
    
    # Plotting a histogram of Peptide Ion Fraction values for each 
    # experimental run chosen (This is a function that uses ggplot,
    # defined in global.R, see code at bottom of this document):
    facetHist(data.loaded[data.loaded$Charge == 1, ], "Intensity")
    
  })
  
}

