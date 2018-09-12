title <- 'Intensity of z=1 across gradient'

init <- function() {
  return(list(
    tab='Contamination',
    boxTitle=title,
    help='Plotting the intensity of z=1 ions observed. This will give an
if you are seeing mostly peptides or non-peptide species and where they occur
in the gradient',
    moduleFunc=.module
  ))
}

.module <- function(input, output, session, data) {
  
  .validate <- function() {
    validate(need(data()[['allPeptides']],paste0("Upload ", 'allPeptides',".txt")))
  }
  
  .plotdata <- function() {
    plotdata <- data()[['allPeptides']][,c("Raw.file","Charge","Intensity","Retention.time")]
    
    plotdata <- plotdata[plotdata$Charge == 1,]
    plotdata$Retention.time <- floor(plotdata$Retention.time)
    
    return(plotdata)
  }
  
  .plot <- function() {
    .validate()
    plotdata <- .plotdata()
    
    ggplot(plotdata, aes(x = Retention.time, y = Intensity)) + 
      geom_bar(stat = 'identity', width= 1) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      coord_flip() + 
      xlab("Retention Time (min)") + 
      ylab(expression(bold("Precursor Intensity"))) +
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

