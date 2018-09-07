init <- function() {
  return(list(
    tab='tab_2',
    boxTitle='Module 2',
    help='help for module 2',
    moduleFunc=testModule
  ))
}

testModule <- function(input, output, session, data) {
  
  output$plot <- renderPlot({
    validate(need(data()[['evidence']],"Upload evidence.txt"))
    #facetHist(df(), 'PIF')
    ggplot(data()[['evidence']]) + geom_histogram(aes(PIF))
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