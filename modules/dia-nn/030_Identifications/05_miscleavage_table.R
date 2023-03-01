init <- function() {
  
  type <- 'table'
  box_title <- 'Miscleavage Rate (percentage), PEP < 0.01'
  help_text <- 'Miscleavage rate (percentage) for precursors identified with confidence PEP < 0.01'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload report.txt')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
  }
  
  .get_internal_occurence <- function(string, char){
    occurence <- str_count(string, pattern = paste0(char,"."))
    occurence_w_proline <- str_count(string, pattern = paste0(char,"P"))
    return(occurence-occurence_w_proline)
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['report']][,c('Raw.file', 'Stripped.Sequence', 'PEP','Ms1.Area')]
    plotdata <- plotdata[plotdata$PEP<0.01, ]
    plotdata <- plotdata[plotdata$Ms1.Area>0, ]
    
    plotdata$Missed.cleavages.R = sapply(plotdata$Stripped.Sequence, .get_internal_occurence, char="R")
    plotdata$Missed.cleavages.K = sapply(plotdata$Stripped.Sequence, .get_internal_occurence, char="K")
    plotdata$Missed.cleavages = plotdata$Missed.cleavages.R + plotdata$Missed.cleavages.K
    
    # group by raw file and number of missed cleavages, wrangle data
    plotdata <- plotdata %>%
      dplyr:: filter(!is.na(Missed.cleavages)) %>%
      dplyr::group_by(Raw.file, Missed.cleavages) %>%
      dplyr::tally()
    
    max_missed = max(plotdata$Missed.cleavages)

    plotdata <- plotdata %>%
      tidyr::spread(Missed.cleavages, n)
    
    plotdata[is.na(plotdata)] = 0
      
    if (max_missed==1){
      plotdata <- plotdata %>%
        dplyr::mutate(`% Missed cleavages`=(`1`) / (`0` + `1`) * 100) %>%
        dplyr::rename(None='0')
      return(plotdata)
      
    } else if (max_missed==2){
      plotdata <- plotdata %>%
        dplyr::mutate(`% Missed cleavages`=(`1` + 2*`2`) / (`0` + `1` + 2*`2`) * 100) %>%
        dplyr::rename(None='0')
      return(plotdata)
      
    } else if (max_missed==3){
      plotdata <- plotdata %>%
        dplyr::mutate(`% Missed cleavages`=(`1` + 2*`2`+ 3*`3`) / (`0` + `1` + 2*`2`+ 3*`3`) * 100) %>%
        dplyr::rename(None='0')
      return(plotdata)
      
    } else {
      return("Not supported for more than 2 missed cleavage sites")
    }
    
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 0), paste0('No Rows selected')))
    
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
