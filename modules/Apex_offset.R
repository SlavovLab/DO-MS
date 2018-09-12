title <- 'Apex Offset'

init <- function() {
  return(list(
    tab='Instrument Performance',
    boxTitle=title,
    help='Plotting the distance from the peak of the elution profile the MS2
    events were executed.',
    moduleFunc=.module
  ))
}

.validate <- function(data) {
  validate(need(data[['msmsScans']], paste0("Upload ", 'msmsScans',".txt")))
}

.plotdata <- function(data) {
  plotdata <- data[['msmsScans']][,c("Raw.file","Precursor.apex.offset.time")]
  
  plotdata$Precursor.apex.offset.time <- plotdata$Precursor.apex.offset.time * 60
  plotdata$Precursor.apex.offset.time[plotdata$Precursor.apex.offset.time > 8] <- 9
  plotdata$Precursor.apex.offset.time[plotdata$Precursor.apex.offset.time < -8] <- -9

  return(plotdata)
}

.plot <- function(.data) {
  # validate
  .validate(.data)
  # get plot data
  plotdata <- .plotdata(.data)
  
  ggplot(plotdata, aes(Precursor.apex.offset.time)) + 
    facet_wrap(~Raw.file, nrow = 1) + 
    geom_histogram() + 
    coord_flip() + 
    xlab("Apex Offset (sec)") + 
    theme_base
}


.module <- function(input, output, session, data) {
  
  output$plot <- renderPlot({
    .plot(data())
  })
  
  output$downloadPDF <- downloadHandler(
    filename=function() { paste0(gsub('\\s', '_', title), '.pdf') },
    content=function(file) {
      ggsave(filename=file, plot=.plot(data()), 
             device=pdf, width=5, height=5, units='in')
    }
  )
  
  output$downloadPNG <- downloadHandler(
    filename=function() { paste0(gsub('\\s', '_', title), '.png') },
    content=function(file) {
      ggsave(filename=file, plot=.plot(data()), 
             device=png, width=5, height=5, units='in')
    }
  )
  
  output$downloadData <- downloadHandler(
    filename=function() { paste0(gsub('\\s', '_', title), '.txt') },
    content=function(file) {
      .data <- data()
      # validate
      .validate(.data)
      # get plot data
      plotdata <- .plotdata(.data)
      write_tsv(plotdata, path=file)
    }
  )
}
