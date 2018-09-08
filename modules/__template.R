init <- function() {
  return(list(
    tab='tab_id_for_module',
    boxTitle='Template Module',
    help='help text for module',
    moduleFunc=function(input, output, session, data) {
      
      output$plot <- renderPlot({
        validate(need(data()[['evidence']],"Upload evidence.txt"))
        #facetHist(df(), 'PIF')
        ggplot(data()[['evidence']]) + geom_histogram(aes(log10(Intensity)))
      })
      
    }
  ))
}