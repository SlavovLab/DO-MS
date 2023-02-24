init <- function() {
  
  type <- 'plot'
  box_title <- 'Number of Confident Precursor Identifications'
  help_text <- 'Plotting the number of precursors identified at each given confidence level.'
  source_file <- 'report'

  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload evidence.txt')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['report']][,c('Raw.file', 'PEP')]
    
    plotdata <- plotdata[complete.cases(plotdata[ , 'PEP']),]
    
    # build log10 PEP vector
    peps <- seq(log10(max(c(min(plotdata$PEP)), 1e-8)), log10(max(plotdata$PEP)), length.out=500)
    peps <- c(log10(.Machine$double.xmin), peps)
   
    
    plotdata <- plotdata %>%
      dplyr::mutate(bin=findInterval(PEP, 10**peps))

    
    plotdata <- plotdata %>%
      dplyr::group_by(Raw.file, bin)

      
    plotdata <- plotdata %>%
      dplyr::summarise(n=dplyr::n())
      
    
    
    plotdata <- plotdata %>%
      dplyr::mutate(cy=cumsum(n))
    
    
    
    plotdata$pep = 10**peps[plotdata$bin+1]
  
    
  
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
    
    ggplot(plotdata, aes(x=pep, color=Raw.file, y=cy, group=Raw.file)) + 
      geom_line(size = input$figure_line_width) +
      scale_colour_manual(name='Experiment', values=cc, labels=levels(plotdata$Raw.file)) +
      coord_flip() + 
      scale_x_log10(limits=c(.000009,max(plotdata$pep)), breaks=c(.00001,.0001,.001,.01,.1), 
                    labels=scales::trans_format('log10', scales::math_format(10^.x))) + 
      xlab('PEP') + ylab('Number of Precursors') +
      theme_diann(input=input, show_legend=T) +
      theme(panel.grid.major.x = element_line(colour = "grey80", size = 0.4), 
            legend.position='right',
            legend.key=element_rect(fill='white'))
    
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    #plot_height=500, # pixels
    report_plot_width=7, # inches
    report_plot_height=5 # inches
  ))
}
