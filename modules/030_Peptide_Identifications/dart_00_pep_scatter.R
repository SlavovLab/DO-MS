init <- function() {
  
  type <- 'plot'
  box_title <- 'Error Probability Update'
  help_text <- '2D Densities of PSM error probabilities, given by MaxQuant (Spectra) and DART-ID. Points below the 45 degree line indicate boosted confidence (and lowered error probability), and vice versa for above the 45 degree line. Set the PEP slider to 1 to see all PSMs regardless of initial confidence.'
  source_file <- 'DART-ID'
  
  .validate <- function(data, input) {
    
    validate(need(data()[['DART-ID']], paste0('Upload evidence_updated.txt')
    ))
    
    # ensure that table has the DART-ID PEP
    validate(need(
      'dart_PEP' %in% colnames(data()[['DART-ID']]), 
      paste0('Provide evidence.txt from DART-ID output, with updated dart_PEP column. Visit https://dart-id.slavovlab.net/ for more information about DART-ID')
    ))
  }
  
  .plotdata <- function(data, input) {
    
    conf_limit <- 1e-8
    
    ev.f <- data()[['DART-ID']] %>%
      dplyr::select(c('Sequence', 'PEP', 'dart_PEP')) %>%
      dplyr::filter(!PEP == dart_PEP) %>%
      dplyr::filter(PEP > 0 & dart_PEP > 0 & PEP > conf_limit & dart_PEP > conf_limit) %>%
      dplyr::mutate_at(c('PEP', 'dart_PEP'), funs(ifelse(. > 1, 1, .))) %>%
      dplyr::mutate(pep_log=log10(PEP),
                    pep_new_log=log10(dart_PEP))
    
    return(ev.f)
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
    
    rng <- seq(-5, 0, 1)
    nbins <- 80
    
    ggplot(plotdata, aes(x=PEP, y=dart_PEP)) +
      stat_bin2d(bins=nbins, drop=TRUE, geom='tile', aes(fill=..density..)) +
      geom_abline(slope=1, intercept=0, color='black', size=0.5) +
      geom_vline(xintercept=1e-2, linetype='dotted', color='black', size=0.5) +
      geom_hline(yintercept=1e-2, linetype='dotted', color='black', size=0.5) +
      scale_fill_gradient(low='white', high='red', labels=NULL) +
      scale_x_log10(expand=c(0.0,0), limits=c(1e-5, 1), 
                    breaks=10 ** rng, labels=fancy_scientific) +
      scale_y_log10(expand=c(0.0,0), limits=c(1e-5, 1), 
                    breaks=10 ** rng, labels=fancy_scientific) +
      labs(x='Spectra', y='DART-ID', fill='Density', title='Error Probability (PEP)') +
      theme_base(input=input)
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

