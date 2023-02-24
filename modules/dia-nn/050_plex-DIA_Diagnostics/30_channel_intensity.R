init <- function() {
  
  type <- 'plot'
  box_title <- 'Relative Single-Cell Intensity'
  help_text <- 'Single-Cell intensity relative to the carrier channel for intersected precursors'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['report']], paste0('Upload report.txt')))
    validate(need((nrow(data()[['report']]) > 1), paste0('No Rows selected')))
  }
  
  
  # return the IDs for the carrier for a run
  .get_carrrier_ids <- function(rawfile, carriertable){
    carriertable <- carriertable[carriertable$Raw.file==rawfile,]
    
    if (nrow(carriertable) == 0){
      return(1)
    } else {
      return(carriertable$Identifications[1])
    }
 

  }
  
  .plotdata <- function(data, input) {
    
    plotdata <- data()[['report']][,c('Raw.file', 'Ms1.Area', 'Precursor.Id','Label')]
    
    plotdata <- plotdata[plotdata$Ms1.Area>0,]

    
    # create empty dataframe for output
    
    outdf <- data.frame(Raw.file=factor(),
                        logratio=double(),
                        Label=factor(),
                        stringsAsFactors=FALSE)
    
    # iterate all experiments
    
    experiments = unique(plotdata[["Raw.file"]])
    for (i in 1:length(experiments)){
      experiment = experiments[[i]]
      
      subdf <- plotdata[plotdata$Raw.file==experiment,]
      
      # get carrier label, eg. label with highest intensity
      meandf <- subdf %>%
        dplyr::group_by(Label) %>%
        dplyr::summarise(mean=mean(Ms1.Area), 
                       .groups = "drop")
      meandf <- meandf[order(meandf$mean),]
  
      carrier_label <- 'd8' #meandf[1:1,][['Label']]
      
      # Calculate ratio to carrier for all but carrier label
      

      
      for (channel in config[['channels']]) {
        current_label = channel[['name']]
        if (current_label != carrier_label){
          
          # join dataframes by intersected precursors
          carrier_df <- subdf[subdf$Label==carrier_label,]
          carrier_df <- carrier_df[,c("Precursor.Id","Ms1.Area")]
          current_df <- subdf[subdf$Label==current_label,]
          
          joineddf <- merge(carrier_df, current_df, by = "Precursor.Id")
          joineddf$logratio = log10(joineddf$Ms1.Area.y/joineddf$Ms1.Area.x)

          joineddf <- joineddf[,c("Raw.file","logratio","Label")]

          
          outdf <- rbind(outdf, joineddf)
          
        }
      }
      
    }
    
    return(outdf)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)

    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    
    ggplot(plotdata, aes(x=Label, y=logratio)) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      theme_diann(input=input, show_legend=T) +
      geom_boxplot()+
      ylim(-2.5,1)+
      labs(x='', y='log10 Intensity Ratio')
    
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

