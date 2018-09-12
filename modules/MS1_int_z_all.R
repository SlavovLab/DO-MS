title <- 'MS1 Intensity for all ions'
  
init <- function() {
  return(list(
    tab='Abundance',
    boxTitle=title,
    help='Plotting the MS1 intensity for all ions observed (not 
    necessarily sent to MS2) across runs.',
    moduleFunc=.module
  ))
}

.module <- function(input, output, session, data) {
  
  .validate <- function() {
    validate(need(data()[['allPeptides']],paste0("Upload ", 'allPeptides',".txt")))
  }
  
  .plotdata <- function() {
    plotdata <- data()[['allPeptides']][,c("Raw.file","Charge", "Intensity", 'MS.MS.Count')]
    plotdata$Intensity <- log10(plotdata$Intensity)
    plotdata$Intensity <- log10(plotdata$Intensity)
    plotdata <- plotdata[plotdata$MS.MS.Count >= 1,]
    return(plotdata)
  }
  
  .plot <- function() {
    .validate()
    plotdata <- .plotdata()
    
    ggplot(plotdata, aes(Intensity)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram() + 
      coord_flip() + 
      xlab(expression(bold("Log"[10]*" Precursor Intensity"))) +
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

