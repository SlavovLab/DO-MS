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
  
  df <- callModule(linkedScatter, "scatters", 
                   session = session,
                   data = reactive(mpg),
                   left = reactive(c("cty", "hwy")),
                   right = reactive(c("drv", "hwy")),
                   df = reactive(datafile)
  )
  
  # output$table <- renderDataTable({
  #   datafile()
  # })
  
  #plot1 <- callModule(plot_module, 'plot1', df=datafile)
  #output$plot <- renderPlot({ plot1() })
  
  #output$table <- renderPlot({
  #  df <- datafile()
    #ggplot(df, aes(PIF)) + facet_wrap(~Raw.file, nrow = 1)+ geom_histogram(bins=100) + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)),axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) 
  #  facetHist(df, "PIF")
  #  })
  
})

plot_module <- function(input, output, session, df) {
  output$plot <- renderPlot({ facetHist(df(), 'PIF') })
  
  reactive({
    #facetHist(df(), 'PIF')
  })
}

linkedScatter <- function(input, output, session, data, left, right, df) {
  # Yields the data frame with an additional column "selected_"
  # that indicates whether that observation is brushed
  dataWithSelection <- reactive({
    brushedPoints(data(), input$brush, allRows = TRUE)
  })
  
  output$plot1 <- renderPlot({
    scatterPlot(dataWithSelection(), left())
  })
  
  output$plot2 <- renderPlot({
    scatterPlot(dataWithSelection(), right())
  })
  
  output$plot3 <- renderPlot({
    facetHist(df(), 'PIF')
  })
  
  return(dataWithSelection)
}
scatterPlot <- function(data, cols) {
  ggplot(data, aes_string(x = cols[1], y = cols[2])) +
    geom_point(aes(color = selected_)) +
    scale_color_manual(values = c("black", "#66D65C"), guide = FALSE)
}
