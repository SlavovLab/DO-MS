init <- function() {
  
  tab <- '070 DART-ID'
  boxTitle <- 'Error Probability Update'
  help <- '2D Densities of PSM error probabilities, given by MaxQuant (Spectra) and DART-ID. Points below the 45 degree line indicate boosted confidence (and lowered error probability), and vice versa for above the 45 degree line. Set the PEP slider to 1 to see all PSMs regardless of initial confidence.'
  source.file <- 'evidence'
  
  .validate <- function(data, input) {
    # require the user upload the specified source file
    validate(need(data()[['evidence']],paste0("Upload ", source.file, ".txt")))
    # or, you can hard-code the source file
    validate(need(data()[['evidence']],paste0("Upload evidence.txt")))
    
    # ensure that table has the DART-ID PEP
    validate(need('pep_updated' %in% colnames(data()[['evidence']]), 
             paste0('Provide evidence.txt from DART-ID output, with updated PEP column')))
  }
  
  .plotdata <- function(data, input) {
    
    conf_limit <- 1e-8
    
    ev.f <- data()[['evidence']] %>%
      select(c('Sequence', 'PEP', 'pep_new')) %>%
      filter(!is.na(pep_new)) %>%
      filter(PEP > 0 & pep_new > 0 & PEP > conf_limit & pep_new > conf_limit) %>%
      mutate_at(c('PEP', 'pep_new'), funs(ifelse(. > 1, 1, .))) %>%
      mutate(pep_log=log10(PEP),
             pep_new_log=log10(pep_new))
    
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
    
    rng <- seq(-5, 0, 1)
    nbins <- 80
    
    p <- ggplot(plotdata, aes(x=PEP, y=pep_new)) +
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
    
    return(p)
    
    # nbins <- 80
    # conf_limit <- 1e-8
    # 
    # x.bin <- seq(log10(conf_limit), 0, length=nbins)
    # y.bin <- seq(log10(conf_limit), 0, length=nbins)
    # 
    # freq <- as.data.frame(table(findInterval(plotdata$pep_log, x.bin),
    #                             findInterval(plotdata$pep_new_log, y.bin)))
    # 
    # freq[,1] <- as.numeric(freq[,1])
    # freq[,2] <- as.numeric(freq[,2])
    # 
    # freq2D <- diag(nbins)*0
    # freq2D[cbind(freq[,1], freq[,2])] <- freq[,3]
    # 
    # colfunc <- colorRampPalette(c('white', 'black'))
    # 
    # # load user-defined font-sizes, convert to cex units
    # title_font_size <- input$figure_title_font_size / 16
    # axis_font_size <- input$figure_axis_font_size / 12
    # line_width <- input$figure_line_width
    # 
    # 
    # # plot to empty device
    # pdf(NULL)
    # dev.control(displaylist="enable")
    # 
    # layout(t(c(1, 2)), widths=c(5, 1))
    # 
    # par(mar=c(2.25,2.75,1.25,0.75),
    #     pty='s', las=1,
    #     cex.axis=axis_font_size, cex.lab=axis_font_size * 1.25, cex.main=title_font_size * 2)
    # 
    # cols <- colfunc(20)
    # 
    # # Normal
    # image(x.bin, y.bin, freq2D, col=cols,
    #       xlab=NA, ylab=NA,
    #       xaxs='i', yaxs='i',
    #       xaxt='n', yaxt='n', useRaster=F)
    # 
    # abline(a=0, b=1, col='black')
    # abline(h=-2, col='black', lty=2, lwd=1)
    # abline(v=-2, col='black', lty=2, lwd=1)
    # 
    # rect(xleft=-2, xright=0, ybottom=log10(conf_limit), ytop=-2,
    #      border=NA, col=rgb(1,0,0,0.05))
    # rect(xleft=log10(conf_limit), xright=-2, ybottom=-2, ytop=0,
    #      border=NA, col=rgb(0,0,1,0.05))
    # 
    # text(-7, -1, 'Downgraded', cex=axis_font_size * 1.5, adj=c(0, 0.5))
    # text(-1, -4.5, 'Upgraded', cex=axis_font_size * 1.5, adj=c(0, 0), srt=270)
    # 
    # rng <- seq(-10, 0, 2)
    # axis(1, tck=-0.02,  
    #      at=rng, labels=fancy_scientific(10^rng),
    #      mgp=c(0, 0.2, 0))
    # axis(2, tck=-0.02, 
    #      at=rng, labels=fancy_scientific(10^rng),
    #      mgp=c(0, 0.4, 0), las=1)
    # 
    # mtext('Spectra', 1, line=1.15, cex=axis_font_size*1.5)
    # mtext('DART-ID', 2, line=1.85, cex=axis_font_size*1.5, las=3)
    # mtext('Error Probability (PEP)', 3, line=0.1, cex=axis_font_size, font=2)
    # 
    # par(mar=c(2.5, 0.5, 2, 1.25), pty='m')
    # image(matrix(seq(-1, 1, length.out=nbins), ncol=nbins), col=colfunc(nbins),
    #       xlab=NA, ylab=NA, xaxt='n', yaxt='n')
    # mtext('Density', side=3, line=0.1, cex=axis_font_size)
    # 
    # # record plot, and return
    # p <- recordPlot()
    # invisible(dev.off())
    # return(p)
  }
  
  # package all these variables and functions into a named list
  # that our application can build its UI from
  return(list(
    tab=tab,
    boxTitle=boxTitle,
    help=help,
    source.file=source.file,
    validateFunc=.validate,
    plotdataFunc=.plotdata,
    plotFunc=.plot
  ))
}

