title <- 'm/z Distribution for +1 ions'

init <- function() {
  return(list(
    tab='Contamination',
    boxTitle=title,
    help='Plotting the m/z distribution of +1 ions, a diagnostic of 
non-peptide contaminants',
    moduleFunc=.module
  ))
}

.module <- function(input, output, session, data) {
  
  .validate <- function() {
    validate(need(data()[['allPeptides']],paste0("Upload ", 'allPeptides',".txt")))
  }
  
  .plotdata <- function() {
    plotdata <- data()[['allPeptides']][,c('Raw.file', 'Charge', 'm.z')]
    return(plotdata)
  }
  
  .plot <- function() {
    .validate()
    plotdata <- .plotdata()
    
    facetHist(plotdata[plotdata$Charge == 1, ], "m.z")
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

