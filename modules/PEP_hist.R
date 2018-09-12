title <- 'PEP Histogram'

init <- function() {
  return(list(
    tab='Sample Quality',
    boxTitle=title,
    help='Plotting the number of peptides identified at each given confidence
    level.',
    moduleFunc=.module
  ))
}

.module <- function(input, output, session, data) {
  
  .validate <- function() {
    validate(need(data()[['evidence']],paste0("Upload ", 'evidence',".txt")))
  }
  
  .plotdata <- function() {
    plotdata <- data()[['evidence']][,c("Raw.file","PEP")]
    PEP <- count(plotdata, c('Raw.file','PEP'))
    plotdata <- ddply(PEP, .(Raw.file), transform, cy = cumsum(freq)) 
    return(plotdata)
  }
  
  .plot <- function() {
    .validate()
    plotdata <- .plotdata()
    
    ggplot(plotdata, aes(x=PEP, y=cy, group=Raw.file)) + 
      geom_line(size = 1.2) + 
      coord_flip() + 
      scale_x_log10(limits = c(.00009,.1), breaks = c(.0001,.001,.01,.1), 
                    labels = scales::trans_format("log10", scales::math_format(10^.x))) + 
      ylab("Number of IDs") +
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

