title <- 'Injection times, no PSM resulting'
  
init <- function() {
  return(list(
    tab='Sample Quality',
    boxTitle=title,
    help='Plotting distribution of injection times for MS2 events that did not
    result in a PSM.',
    moduleFunc=.module
  ))
}

.module <- function(input, output, session, data) {
  
  .validate <- function() {
    validate(need(data()[['msmsScans']],paste0("Upload ", 'msmsScans',".txt")))
  }
  
  .plotdata <- function() {
    plotdata <- data()[['msmsScans']][,c("Raw.file","Ion.injection.time", "Sequence")]
    plotdata <- plotdata[is.na(plotdata$Sequence),]
    return(plotdata)
  }
  
  .plot <- function() {
    .validate()
    plotdata <- .plotdata()
    
    ggplot(plotdata, aes(Ion.injection.time)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram() + 
      coord_flip() + 
      xlab("Ion Injection Time (ms)") +
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

