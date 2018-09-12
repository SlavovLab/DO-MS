title <- 'Retention length of peptides at base'

init <- function() {
  return(list(
    tab='Instrument Performance',
    boxTitle=title,
    help='Plotting the retention length of identified peptide peaks at the base.',
    moduleFunc=.module
  ))
}

.module <- function(input, output, session, data) {
  
  .validate <- function() {
    validate(need(data()[['evidence']],paste0("Upload ", 'evidence',".txt")))
  }
  
  .plotdata <- function() {
    plotdata <- data()[['evidence']][,c("Raw.file","Retention.length","PEP")]
    plotdata$Retention.length <- plotdata$Retention.length*60
    plotdata$Retention.length[plotdata$Retention.length > 120] <- 120
    return(plotdata)
  }
  
  .plot <- function() {
    .validate()
    plotdata <- .plotdata()
    
    ggplot(plotdata, aes(Retention.length)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins=120) + 
      coord_flip() + 
      xlab('Retention Lengths at base (sec)') +
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

