title <- 'IDs by Retention Time'

init <- function() {
  return(list(
    tab='Instrument',
    boxTitle=title,
    help='help text for module',
    moduleFunc=.module
  ))
}

.module <- function(input, output, session, data) {
  
  .validate <- function() {
    validate(need(data()[['evidence']],paste0("Upload ", 'evidence', '.txt')))
  }

  .plotdata <- function() {
    plotdata <- data()[['evidence']][,c("Raw.file","Retention.time","PEP")]
    return(plotdata)
  }
  
  .plot <- function() {
    .validate()
    plotdata <- .plotdata()
    
    maxRT <- max(plotdata$Retention.time)
    
    ggplot(plotdata, aes(Retention.time)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins=100) + 
      coord_flip() + 
      xlim(10, maxRT) +
      theme_base
  }
  
  output$plot <- renderPlot({
    .plot()
  })
  
  output$downloadPDF <- downloadHandler(
    filename=function() { paste0(gsub('\\s', '_', title), '.pdf') },
    content=function(file) {
      ggsave(filename=file, plot=.plot(), 
             device=pdf, width=5, height=5, units='in')
    }
  )
  
  output$downloadPNG <- downloadHandler(
    filename=function() { paste0(gsub('\\s', '_', title), '.png') },
    content=function(file) {
      ggsave(filename=file, plot=.plot(), 
             device=png, width=5, height=5, units='in')
    }
  )
  
  output$downloadData <- downloadHandler(
    filename=function() { paste0(gsub('\\s', '_', title), '.txt') },
    content=function(file) {
      # validate
      .validate()
      # get plot data
      plotdata <- .plotdata()
      write_tsv(plotdata, path=file)
    }
  )
}
