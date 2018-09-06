genPlot <- function(d) {
  ggplot(d) + geom_histogram(aes(PEP))
}

init <- function() {
  return(list(
    tab='asdf',
    boxTitle='',
    help='',
    moduleFunc=testModule
  ))
}

testModule <- function(input, output, session, data) {
  
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