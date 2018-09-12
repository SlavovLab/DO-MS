title <- 'Number of ions by charge state'

init <- function() {
  return(list(
    tab='Contamination',
    boxTitle=title,
    help='Plotting the frequency of charge states observed. This will give an
if you are seeing mostly peptides or non-peptide species',
    moduleFunc=.module
  ))
}

.module <- function(input, output, session, data) {
  
  .validate <- function() {
    validate(need(data()[['allPeptides']],paste0("Upload ", 'allPeptides',".txt")))
  }
  
  .plotdata <- function() {
    plotdata <- data()[['allPeptides']][,c("Raw.file","Charge")]
    
    plotdata$Charge[plotdata$Charge > 3] <- 4
    plotdata_charge <- count(plotdata, c("Raw.file","Charge"))
    
    hc <- aggregate(plotdata_charge$freq, 
                    by=list(Category=plotdata_charge$Raw.file,
                            plotdata_charge$Charge), 
                    FUN=sum)
    colnames(hc) <- c("Raw.file","Charge","Frequency")
    
    return(hc)
  }
  
  .plot <- function() {
    # validate
    .validate()
    # get plot data
    plotdata <- .plotdata()
    
    # Plot:
    ggplot(plotdata, aes(x=Raw.file, y=Frequency,colour=factor(Charge), group=Raw.file)) + 
      geom_point(size = 2) + 
      #ylab("Number") + 
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

