# NOTE: don't actually try to load this module, unmodified, as it contains pseudocode

# Module is built from the "init" function
# which returns a named list of metadata and function definitions
init <- function() {
  
  # These variables are defined at the top of the module code for convenience
  # and easy reference. They are passed into the return list at the end, but
  # it is not required to define these variables up here.
  
  # can be either 'table' or 'datatable'
  # only difference is 'datatable' is rendered with the DT/DataTables package
  # which gives additional dynamic functionality, 
  # such as ordering and searching through the table with JavaScript
  
  type <- 'table'
  type <- 'datatable'
  
  box_title <- 'Title of the Module in the Dashboard'
  help_text <- 'Help text for module, shown in tooltip and in the Documentation tab'
  source_file <- 'one of evidence, msms, allPeptides, or msmsScans. Does not have to be functional (a module can depend on more than one file) -- only shown in plain text in the documentation tab'
  
  # require certain things in order for the plotting to work
  # if any of these validations fail, the error message specified will be displayed instead of
  # attempting to plot with the given data
  .validate <- function(data, input) {
    # require the user upload the specified source file
    validate(need(data()[['summary']], paste0('Upload summary.txt')))
    
    # you can get creative with the validate(need()) function here. for example:
    dat <- data()[['summary']]
    validate(need( nrow(dat) > 10 & !is.null(input$other_file) )) # just a random pseudocode example
  }
  
  # wrangle the data so it is in a form easy for plotting.
  # you can do variable selection, filtering, etc. here
  .plotdata <- function(data, input) {
    
    plotdata <- data()[['summary']]
    
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
    
    # for tabular display, just return the table object
    # rendering is handled later
    return(plotdata)
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
    
    # additional table type options
    
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
    box_height=600,
    
    # list of options to pass to DT/DataTables constructor
    # find more details about the (many entries) here:
    # https://rstudio.github.io/DT/
    # https://datatables.net/reference/option/.
    datatable_options=list(
      pageLength=10, 
      dom='lfptp', 
      lengthMenu=c(5, 10, 15, 20, 50) 
    )
  ))
}

