init <- function() {
  
  type <- 'plot'
  box_title <- ''
  help_text <- ''
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    
    validate(need(data()[['evidence']], paste0('')
    ))
    
  }
  
  .plotdata <- function(data, input) {

  }
  

  
  # plotting func:
  .plot <- function(data, input) {
    
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    ggplot() + 
      annotate("text", x = 4, y = 25, size=8, label = "The follow plots implement DART-ID\nto update identification confidence:\n\ndart-id.slavovlab.net") + 
      theme_void()
    
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

