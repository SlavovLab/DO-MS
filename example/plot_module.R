# NOTE: don't actually try to load this module, unmodified, as it contains pseudocode

# Module is built from the "init" function
# which returns a named list of metadata and function definitions
init <- function() {
  
  # These variables are defined at the top of the module code for convenience
  # and easy reference. They are passed into the return list at the end, but
  # it is not required to define these variables up here.
  type <- 'plot'
  box_title <- 'Title of the Module in the Dashboard'
  help_text <- 'Help text for module, shown in tooltip and in the Documentation tab'
  source_file <- 'one of evidence, msms, allPeptides, or msmsScans. Does not have to be functional (a module can depend on more than one file) -- only shown in plain text in the documentation tab'
  
  # require certain things in order for the plotting to work
  # if any of these validations fail, the error message specified will be displayed instead of
  # attempting to plot with the given data
  .validate <- function(data, input) {
    # require the user upload the specified source file
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
    
    # you can get creative with the validate(need()) function here. for example:
    dat <- data()[['evidence']]
    validate(need( nrow(dat) > 150 & !is.null(input$other_file) )) # just a random pseudocode example
  }
  
  # wrangle the data so it is in a form easy for plotting.
  # you can do variable selection, filtering, etc. here
  .plotdata <- function(data, input) {
    
    plotdata <- data()[['evidence']][,c('Raw.file', 'Retention.length..FWHM.')]
    
    # example data manipulation
    plotdata$Retention.length..FWHM.[plotdata$Retention.length..FWHM. > 45] <- 49
    
    # return data in a tabular format (data.table, tibble)
    return(plotdata)
  }
  
  # plot with the plotdata as generated in the previous function
  # return any plot object
  .plot <- function(data, input) {
    
    # here is where the validate and plotdata functions are called
    # you can remove these calls if you want, especially if your plot is very simple.
    # we recommend always checking for the data file in the .validate() function, however,
    # as without it the application will try plotting all the time, even when the user
    # has not loaded any data yet.
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    # ggplot:
    
    p <- ggplot(plotdata, aes(Retention.length..FWHM.)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins = 49) + 
      coord_flip() +  
      xlab("Retention Length FWHM (sec)") +
      theme_base(input=input)
    
    # return the saved plot
    return(p)
    
    # vanilla R plot:
    
    # if you want to use vanilla R plots, then you need to do some tricks
    # https://www.andrewheiss.com/blog/2016/12/08/save-base-graphics-as-pseudo-objects-in-r/
    # http://stackoverflow.com/a/14742001/120898
    # basically, plot into a null device in order to save it for later, such as when you
    # have to return the plot object from the .plot() function
    
    pdf(NULL)
    dev.control(displaylist="enable")
    plot(rnorm(50), rnorm(50))
    p <- recordPlot()
    invisible(dev.off())
    
    # return the saved plot
    return(p)
  }
  
  # package all these variables and functions into a named list
  # that our application can build its UI from
  return(list(
    # metadata
    type=type,
    box_title=boxTitle,
    help_text=help_text,
    source_file=source_file,
    
    # function definitions
    validateFunc=.validate,
    plotdataFunc=.plotdata,
    plotFunc=.plot,
    
    # additional plot type options
    
    # dynamic width - scale the width of this plot to the number of experiments
    # selected for plotting. used for many of the default plots, such as the
    # vertical histograms or boxplots
    # units are in pixels per experiment. 
    # when downloading figures or generating a report, pixels are converted to
    # inches with the ratio (PPI -- pixels-per-inch) of 75.
    # i.e., 75 pixels -> 1 inch. Fractions of inches are rounded up.
    #
    # if you do not intend to use dynamic width, then remove this line.
    dynamic_width=75,
    
    # dynamic width base - a fixed amount of pixels to add after
    # calculating the dynamic width. Useful for plots with legends that
    # take up a fixed amount of space and do not scale with the
    # number of experiments plotted. By default this is 150px
    # and 1 inch in the report.
    dynamic_width_base=150,
    
    # override default plot height (370px)
    plot_height=500, # in pixels
    
    # override default box width
    # this is the width of the box in the web interface
    # does not affect the image width or the 
    # width of plot in the generated reports
    # in bootstrap column units, 1-12. 
    # 12 = stretch to full width, 
    # 6 = half (default)
    box_width=8, 
    
    # override default box height
    # in pixels (default, plot height)
    box_height=600
  ))
}

