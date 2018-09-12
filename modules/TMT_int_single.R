title <- 'Reporter ion intensity'

init <- function() {
  return(list(
    tab='Abundance',
    boxTitle=title,
    help='Plotting the TMT reporter intensities for a single run.',
    moduleFunc=.module
  ))
}

.module <- function(input, output, session, data) {
  
  .validate <- function() {
    validate(need(data()[['evidence']],paste0("Upload ", 'evidence',".txt")))
  }
  
  .plotdata <- function() {
    plotdata <- dplyr::select(data()[['evidence']],starts_with("Reporter.intensity.corrected"))
    plotdata <- melt(plotdata)
    plotdata$log10tran <- log10(plotdata$value)
    return(plotdata)
  }
  
  .plot <- function() {
    .validate()
    plotdata <- .plotdata()
    
    uniqueLabelsSize <- length(unique(plotdata$variable))
    TMTlabels <- c("C1","C2","C3","C4","C5","C6","C7","C8","C9","C10","C11")
    plot2Labels <- TMTlabels[1:uniqueLabelsSize]
    
    ggplot(plotdata,aes(x=variable,y=log10tran))+ 
      geom_violin(aes(group=variable,colour=variable,fill=variable),alpha=0.5, 
                  kernel="rectangular")+    # passes to stat_density, makes violin rectangular 
      xlab("TMT Channel")+             
      ylab(expression(bold("Log"[10]*" RI Intensity")))+ 
      theme_bw() +                     # make white background on plot
      theme_base +
      scale_x_discrete(name ="TMT Channel", labels=plot2Labels) 
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
