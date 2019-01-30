init <- function() {

  type <- 'plot'
  box_title <- 'Number of ions by charge state'
  help_text <- 'Plotting the frequency of charge states observed. This will give an if you are seeing mostly peptides or non-peptide species'
  source_file <- 'allPeptides'

  
  .validate <- function(data, input) {
    validate(need(data()[['allPeptides']], paste0('Upload allPeptides.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['allPeptides']][,c('Raw.file', 'Charge')]
    
    plotdata$Charge[plotdata$Charge > 3] <- 4
    
    plotdata <- plotdata %>%
      group_by(Raw.file, Charge) %>%
      tally()
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata) + 
      geom_bar(aes(x=Raw.file, y=n, fill=factor(Charge), group=Raw.file), 
               stat='identity', position='dodge2') +
      scale_fill_hue(labels=c('1', '2', '3', '>3')) + 
      labs(x='Experiment', y='Count', fill='Charge State') +
      theme_base(input=input, show_legend=T)
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot
  ))
}
