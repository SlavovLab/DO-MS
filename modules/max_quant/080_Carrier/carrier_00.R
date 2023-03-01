init <- function() {
  
  type <- 'plot'
  box_title <- ''
  help_text <- ''
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['evidence']][,c('Raw.file', 'PEP','Type')]
    plotdata <- plotdata %>% dplyr::filter(Type != "MULTI-MATCH")
    plotdata <- plotdata %>% dplyr::select('Raw.file', 'PEP')
    # build log10 PEP vector
    peps <- seq(log10(max(c(min(plotdata$PEP)), 1e-5)), log10(max(plotdata$PEP)), length.out=500)
    peps <- c(log10(.Machine$double.xmin), peps)
    
    plotdata <- plotdata %>%
      dplyr::mutate(bin=findInterval(PEP, 10**peps)) %>%
      dplyr::group_by(Raw.file, bin) %>%
      dplyr::summarise(n=dplyr::n()) %>%
      dplyr::mutate(cy=cumsum(n),
                    pep=10**peps[bin])

    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    # Rank the Experiments by most number of peptides observed
    
    maxnum <- c()
    rawnames <- c()
    
    for(X in unique(plotdata$Raw.file)){
      maxnum <- c(maxnum, max(plotdata$cy[plotdata$Raw.file %in% X]) )
      rawnames <- c(rawnames, X)
    }
    
    names(maxnum) <- rawnames
    rank_exp <- maxnum[order(maxnum, decreasing = T)]
    rank_exp_ord <- seq(1, length(rank_exp),1)
    names(rank_exp_ord) <- names(rank_exp)
    plotdata$rank_ord <- NA
    
    for(X in levels(plotdata$Raw.file)) {
      plotdata$rank_ord[plotdata$Raw.file %in% X] <- rank_exp_ord[X]
    }
    
    cc <- scales::seq_gradient_pal('red', 'blue', 'Lab')(seq(0, 1, length.out=length(rank_exp_ord)))
    
    ggplot() + 
      annotate("text", x = 4, y = 25, size=8, label = "Please upload experiments searched\nwith TMT as a variable modification") + 
      theme_void()
    
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    box_width=12, # bootstrap column units
    plot_height=500, # pixels
    report_plot_width=7, # inches
    report_plot_height=5 # inches
  ))
}
