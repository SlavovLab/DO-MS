#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


source('global.R')

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  datafile <- callModule(csvFile, "datafile",
                         stringsAsFactors = FALSE)
  
  # output$table <- renderDataTable({
  #   datafile()
  # })
  
  output$table <- renderPlot({
    df <- datafile()
    #ggplot(df, aes(PIF)) + facet_wrap(~Raw.file, nrow = 1)+ geom_histogram(bins=100) + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)),axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) 
    facetHist(df, "PIF")
    })
  
})
