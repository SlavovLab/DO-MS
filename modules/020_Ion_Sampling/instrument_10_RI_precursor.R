init <- function() {
  
  type <- 'plot'
  box_title <- 'MS2 Signal / MS1 Signal per peptide, log10'
  help_text <- 'This plot displays the sum of the reporter ion intensities divided by its precursor intensity per run on a log10 scale. This can serve as an indicator of transmission efficiency.'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
    
    # require reporter ion quantification data
    validate(need(any(grepl('Reporter.intensity.corrected', colnames(data()[['evidence']]))), 
                  paste0('Loaded data does not contain reporter ion quantification')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['evidence']]
    plotdata$SeqCharge <- paste(plotdata$Sequence, plotdata$Charge, sep="")
    duplicated_seqcharge <- plotdata[duplicated(plotdata$SeqCharge), ]
    
    
    potential_unique <- duplicated_seqcharge$SeqCharge
    subframes <- split(plotdata, plotdata$Raw.file)
    
    
    final_unique = c()
    for (i in 1:length(potential_unique)){
      bool_vec = c()
      for (k in 1:length(subframes)){
        if (potential_unique[i] %in% subframes[[k]][['SeqCharge']]){
          bool_vec = c(bool_vec, TRUE)
        }
      }
      if (sum(bool_vec, na.rm = TRUE) == length(subframes)){
        final_unique = c(final_unique, potential_unique[i])
      }
    }
    plotdata <- plotdata[plotdata$SeqCharge %in% final_unique,]
    
    plotdata <- plotdata %>% dplyr::filter(Type != "MULTI-MATCH")
    
    plotdata <- plotdata %>%
      rowwise() %>%
      mutate(RI.Sum = sum(across(starts_with("Reporter.intensity.corrected")), na.rm = T))
    plotdata <- plotdata %>%
      rowwise() %>%
      mutate(RI.Precursor.Ratio = log10(RI.Sum / Intensity))
    
    
    # Thresholding data at 1 and 99th percentiles
    ceiling <- quantile(plotdata$RI.Precursor.Ratio, probs=.99, na.rm = TRUE)
    floor <- quantile(plotdata$RI.Precursor.Ratio, probs=.01, na.rm = TRUE)
    
    plotdata <- dplyr::filter(plotdata, is.finite(RI.Precursor.Ratio))
    
    
    plotdata[plotdata$RI.Precursor.Ratio >= ceiling, ]['RI.Precursor.Ratio'] <- ceiling
    plotdata[plotdata$RI.Precursor.Ratio <= floor, ]['RI.Precursor.Ratio'] <- floor
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) >= 1), paste0('No Rows selected')))
    
    ggplot(plotdata, aes(RI.Precursor.Ratio)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_histogram(bins=100) + 
      coord_flip() + 
      labs(x=expression(bold('Log'[10]*' Ratio')), y='Number of Peptides')
    
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
