init <- function() {
  
  type <- 'table'
  box_title <- 'Miscleavage rate percentage'
  help_text <- 'Percentages of missed cleavages - measure the efficiency of protein digest'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['evidence']][,c('Raw.file', 'Missed.cleavages', 'PEP')]
    
    # group by raw file and number of missed cleavages, wrangle data
    plotdata <- plotdata %>%
      dplyr:: filter(!is.na(Missed.cleavages)) %>%
      dplyr::group_by(Raw.file, Missed.cleavages) %>%
      dplyr::tally() %>%
      tidyr::spread(Missed.cleavages, n) %>%
      dplyr::mutate(`% Missed cleavages`=(`1` + `2`) / (`0` + `1` + `2`) * 100) %>%
      dplyr::rename(None='0')
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    plotdata
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
