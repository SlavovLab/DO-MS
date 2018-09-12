title <- 'Retention Lengths (FWHM)'

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
    validate(need(data()[['allPeptides']],paste0("Upload ", 'allPeptides', '.txt')))
  }
  
  .plotdata <- function() {
    plotdata <- data()[['allPeptides']][,c("Raw.file","Retention.length..FWHM.")]
    
    plotdata$Retention.length..FWHM.[plotdata$Retention.length..FWHM. > 45] <- 49
    return(plotdata)
  }
  
  .plot <- function() {
    .validate()
    plotdata <- .plotdata()
    
    ggplot(plotdata, aes(Retention.length..FWHM.)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins = 49) + 
      coord_flip() + 
      xlab("Retention Length FWHM (sec)") +
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
