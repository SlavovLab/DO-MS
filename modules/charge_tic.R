title <- 'TIC of ions by charge state'

init <- function() {
  return(list(
    tab='Contamination',
    boxTitle=title,
    help='Plotting the TIC of charge states observed. This will give an
if you are seeing mostly peptides or non-peptide species',
    moduleFunc=.module
  ))
}

.module <- function(input, output, session, data) {
  
  .validate <- function() {
    validate(need(data()[['allPeptides']],paste0("Upload ", 'allPeptides',".txt")))
  }
  
  .plotdata <- function() {
    plotdata <- data()[['allPeptides']][,c("Raw.file","Charge","Intensity")]
    
    plotdata$Charge[plotdata$Charge > 3] <- 4
    hc <- aggregate(plotdata$Intensity, 
                    by=list(Category=plotdata$Raw.file, plotdata$Charge), 
                    FUN=sum)
    colnames(hc) <- c("Raw.file","Charge","Intensity")
    
    return(hc)
  }
  
  .plot <- function() {
    .validate()
    plotdata <- .plotdata()
    
    ggplot(plotdata, aes(x=Raw.file, y=Intensity,colour=factor(Charge), group=Raw.file)) + 
      geom_point(size = 2) + 
      ylab("Number") + 
      labs(x = "Experiment", y = "Total Ion Current", col = "Charge State") + 
      scale_y_log10() + 
      scale_color_hue(labels = c("1","2","3",">3")) + 
      labs(x = "Experiment", y = "Count", col = "Charge State") +
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

