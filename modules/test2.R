test2Module <- function(input, output, session, df) {
  a <- 'not done'
  
  output$plot <- renderPlot({
    validate(need(df(),"Upload evidence.txt"))
    #facetHist(df(), 'PIF')
    genPlot()
    a <- 'done!!'
  })
  
  observeEvent(input$button, {
    print('yay')
  })
  
  genPlot <- function() {
    hist(df()$PIF)
  }
}