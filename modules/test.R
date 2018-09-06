genPlot <- function(d) {
  ggplot(d) + geom_histogram(aes(PEP))
}

testTab <- 'Tab1'

testModule <- function(input, output, session, evidence=NULL) {
  
  output$plot <- renderPlot({
    validate(need(evidence(),"Upload evidence.txt"))
    #facetHist(df(), 'PIF')
    genPlot(evidence())
  })
  
  output$downloadPDF <- downloadHandler(
    filename=function() {
      'test'
    },
    content=function(file) {
      ggsave(filename=file, genPlot(df()), device=pdf)
    }
  )
  
  output$downloadPNG <- downloadHandler(
    filename=function() {
      'test'
    },
    content=function(file) {
      ggsave(filename=file, genPlot(df()), device=png)
    }
  )
  
  output$downloadData <- downloadHandler(
    filename=function() {
      'test'
    },
    content=function(file) {
      write.table(df()$PEP, file=file)
    }
  )
}