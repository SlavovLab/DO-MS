init <- function() {
  return(list(
    tab='tab_1',
    boxTitle='Module 1',
    help='help for module 1',
    moduleFunc=testModule
  ))
}

testModule <- function(input, output, session, data) {
  
  output$plot <- renderPlot({
    validate(need(data()[['evidence']],"Upload evidence.txt"))
    #facetHist(df(), 'PIF')
    ggplot(data()[['evidence']]) + geom_histogram(aes(log10(Intensity)))
  })
  
  # output$downloadPDF <- downloadHandler(
  #   filename=function() {
  #     'test'
  #   },
  #   content=function(file) {
  #     ggsave(filename=file, genPlot(df()), device=pdf)
  #   }
  # )
  # 
  # output$downloadPNG <- downloadHandler(
  #   filename=function() {
  #     'test'
  #   },
  #   content=function(file) {
  #     ggsave(filename=file, genPlot(df()), device=png)
  #   }
  # )
  # 
  # output$downloadData <- downloadHandler(
  #   filename=function() {
  #     'test'
  #   },
  #   content=function(file) {
  #     write.table(df()$PEP, file=file)
  #   }
  # )
  
  
}