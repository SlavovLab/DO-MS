init <- function() {
  
  type <- 'plot'
  box_title <- 'Increase in Confident PSMs'
  help_text <- 'Fold-change increase of PSMs at given confidence thresholds (in this case, FDR thresholds)'
  source_file <- 'DART-ID'
  
  .validate <- function(data, input) {
    
    validate(need(data()[['DART-ID']], paste0('Upload evidence_updated.txt')))
    
    # ensure that table has the DART-ID PEP
    validate(need(
      'dart_PEP' %in% colnames(data()[['DART-ID']]), 
      paste0('Provide evidence.txt from DART-ID output, with updated dart_PEP column.  Visit https://dart-id.slavovlab.net/ for more information about DART-ID')
    ))
  }
  
  .plotdata <- function(data, input) {
    ev <- data()[['DART-ID']] 
    ev <- ev %>%
      filter(!is.na(PEP) & !is.na(dart_PEP)) %>%
      # ceil PEPs to 1
      dplyr::mutate_at(c('PEP', 'dart_PEP'), funs(ifelse(. > 1, 1, .))) %>%
      # calculate q-values
      dplyr::mutate(qval=(cumsum(PEP[order(PEP)]) /
                          seq(1, nrow(ev)))[order(order(PEP))],
                    qval_updated=(cumsum(dart_PEP[order(dart_PEP)]) /
                                  seq(1, nrow(ev)))[order(order(dart_PEP))])

    # flag peptides that don't have a single confident ID across all sets
    new_peptides <- ev %>%
      dplyr::group_by(Modified.sequence) %>%
      dplyr::summarise(min_pep=min(qval),
                       min_pep_new=min(qval_updated)) %>%
      dplyr::filter(min_pep > 0.01 & min_pep_new < 0.01) %>%
      dplyr::pull(Modified.sequence)

    ev$qval_prev <- ev$qval_updated
    ev$qval_prev[ev$Modified.sequence %in% new_peptides] <- ev$qval[ev$Modified.sequence %in% new_peptides]
    
    x <- seq(log10(5e-4), log10(1), length.out=100)

    # frame to hold the results
    df <- data.frame()
    method.names <- c('Spectra', 'DART-ID', 'DART-ID (conf only)')
    counter <- 1
    for(i in x) {
      counter <- counter + 1

      thresh <- 10 ** i

      ratios <- c(
        1,
        sum(ev$qval_updated < thresh) /      sum(ev$qval < thresh),
        sum(ev$qval_prev < thresh)    /      sum(ev$qval < thresh)
      )
      ident <- c(
        sum(ev$qval < thresh) /              nrow(ev),
        sum(ev$qval_updated < thresh) /      nrow(ev),
        sum(ev$qval_prev < thresh) /         nrow(ev)
      )

      df <- rbind(df, data.frame(
        x=as.numeric(thresh),
        ratio=as.numeric(ratios),
        ident=as.numeric(ident),
        Method=as.character(method.names)
      ))
    }
    df$Method <- factor(df$Method, levels=c('Spectra', 'DART-ID', 'DART-ID (conf only)'))

    return(df)
  }
  
  # helper functions for plotting:
  # fancy scientific scales
  # from: https://stackoverflow.com/questions/11610377/how-do-i-change-the-formatting-of-numbers-on-an-axis-with-ggplot
  fancy_scientific <- function(l) {
    # turn in to character string in scientific notation
    l <- format(l, scientific = TRUE)
    # quote the part before the exponent to keep all the digits
    l <- gsub("^(.*)e", "e", l)
    #l <- gsub("^(.*)e", "'\\1'e", l)
    # turn the 'e+' into plotmath format
    l <- gsub("e", "10^", l)
    #l <- gsub("e", "%*%10^", l)
    # make sure +0 just turns into 0
    l <- gsub("\\+00", "00", l)
    # return this as an expression
    return(parse(text=l))
  }
  
  # plotting func:
  .plot <- function(data, input) {
    
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    cb <- c('#20B2CF', '#FF6666', '#888888', '#FFFFFF')
    
    #return(qplot(1, 1))
    
    rng <- seq(-3, 0, 1)

    fold_change <- ggplot(plotdata) +
      geom_path(aes(x=x, y=(ratio-1)*100, color=Method), size=1) +
      geom_hline(aes(yintercept=1, color='Spectra'), size=1) +
      geom_vline(xintercept=1e-2, color='black', linetype='dotted', size=0.5) +
      scale_x_log10(limits=c(1e-3, 1), expand=c(0,0),
                    breaks=10**rng, labels=c('0.1%', '1%', '10%', '100%')) +
      scale_y_continuous(limits=c(-25, 200),
                         breaks=seq(0, 200, by=25),
                         expand=c(0,0)) +
      scale_color_manual(values=c(cb[1], cb[2], paste0(cb[2], '44'))) +
      labs(x='FDR Threshold', y='% Increase',
           title="Increase in confident PSMs",
           color='Method') +
      theme_base(input=input) + theme(
        legend.justification=c(0,1),
        legend.position=c(0.5, 1),
        legend.key.size=unit(0.5, 'cm'),
        legend.text=element_text(size=input$figure_axis_font_size)
      )

    return(fold_change)
  }
  
  # package all these variables and functions into a named list
  # that our application can build its UI from
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

