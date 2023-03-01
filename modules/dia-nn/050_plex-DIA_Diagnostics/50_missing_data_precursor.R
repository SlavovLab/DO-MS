init <- function() {
  
  type <- 'plot'
  box_title <- 'Missing Data,  Precursor Level'
  help_text <- 'Plotting the Jaccard Index for identified precursors for all channel combinations. '
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload report.txt')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
  }
  
  
  .jaccard <- function(a, b) {
    intersection = length(intersect(a, b))
    union = length(a) + length(b) - intersection
    return (intersection/union)
  }
  
  .jaccard_by_label <- function(dataframe, experiment){
    
    outdf <- data.frame(Raw.file=factor(),
                        Order=factor(),
                        Jacc=double(),
                        Label=factor(),
                        X=double(),
                        stringsAsFactors=FALSE)
    
    labels = sort(unique(dataframe[["Label"]]))
    
    rows <- length(labels)
    idx <- which(lower.tri(matrix(, rows, rows), diag = FALSE) == TRUE, arr.ind=T)
    
    for(i in 1:nrow(idx)){
      first_index <- idx[i,'row']
      second_index <- idx[i,'col']
      
      first_label <- labels[[first_index]]
      second_label <- labels[[second_index]]
      
      precursors_first = dataframe[dataframe$Label == first_label, ]
      precursors_first = precursors_first[["Precursor.Id"]]
      
      precursors_second = dataframe[dataframe$Label == second_label, ]
      precursors_second = precursors_second[["Precursor.Id"]]
      
      dist <- .jaccard(precursors_first, precursors_second)
      
      x <- i/nrow(idx)
      if ((second_label == 'd8') || (first_label == 'd8')) {
        order <- 'reference'
      } else {
        order <- 'other'
      }
      outdf <- rbind(outdf, data.frame(Raw.file=experiment, Order=order, Jacc=dist, Label=first_label, X=x))
      
    }  
    
    return(outdf)
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['report']][,c('Raw.file', 'Ms1.Area', 'Precursor.Id','Label' )]


    plotdata <- plotdata[plotdata$Ms1.Area>0,]

    
    outdf <- data.frame(Raw.file=factor(),
                        Order=factor(),
                        Jacc=double(),
                        Label=factor(),
                        X=double(),
                        stringsAsFactors=FALSE)
    
    experiments = unique(plotdata[["Raw.file"]])
    for (i in 1:length(experiments)){
      experiment = experiments[[i]]
      subdf <- plotdata[plotdata$Raw.file==experiment,]
      jaccdf <- .jaccard_by_label(subdf, experiment)
      outdf <- rbind(outdf, jaccdf)
      
      
      
    }
    
    return(outdf)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata)+
      geom_point(data=plotdata, aes(x=X, y=Jacc, color=Order), size=6)+
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      scale_color_manual(name = "Comparison", values = c(custom_colors[[3]],custom_colors[[1]]))+
      theme(legend.position = "bottom")+
      theme_diann(input=input, show_legend=T) +
      theme(axis.text.x = element_blank())+
      xlim(-1,2)+
      ylab("Jaccard Index")+
      xlab("")+
      ylim(0,1)
    
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    dynamic_width=200,
    dynamic_width_base=50
  ))
}
