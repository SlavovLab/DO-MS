init <- function() {
  
  type <- 'table'
  box_title <- 'Experiment Map'
  help_text <- 'Map of raw file names to short names'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['evidence']] %>%
      dplyr::select(c('Raw.file','Raw.file.orig', 'Folder.Name', 'Folder.Path')) %>%
      dplyr::distinct(Raw.file, .keep_all=T) %>%
      dplyr::arrange(Raw.file) %>%
      dplyr::rename(`Short name`=Raw.file,
                    `Raw file`=Raw.file.orig,
                    Folder=Folder.Name,
                    Path=Folder.Path)
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    # return the data
    plotdata
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    box_width=12
  ))
}

