init <- function() {
  
  type <- 'plot'
  box_title <- 'MS1 Quantification Variability'
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
    
    plotdata <- data()[['report']][,c('Raw.file', 'Ms1.Area', 'Precursor.Id', 'Label', 'Protein.Group','Stripped.Sequence','Precursor.Charge')]
    
    #plotdata <- as.data.frame(read_tsv(file='/Users/georgwallmann/Library/CloudStorage/OneDrive-Personal/Studium/Northeastern/DO-MS-DIA/supplementary_information/do_ms_testcase/report.tsv',guess_max=1e5))
    #plotdata['Raw.file'] <- plotdata['Run']
    #plotdata <- translate_diann_channel_format(plotdata)
    #plotdata <- separate_channel_info(plotdata)
    #plotdata <- plotdata[,c('Raw.file', 'Ms1.Area', 'Precursor.Id', 'Label', 'Protein.Group','Stripped.Sequence','Precursor.Charge')]
    
    # Add Label column
    #
    # Add column for modified precursor without channel
    #plotdata <- separate_channel_info(plotdata)
    
    plotdata <- plotdata[plotdata$Ms1.Area>0,]
    
    
    plotdata$seqcharge = paste0(plotdata$Stripped.Sequence, plotdata$Precursor.Charge)
    
    #normalize each sequence_charge to the mean of the set
    plotdata <- plotdata %>% dplyr::group_by(Raw.file, seqcharge) %>% dplyr::mutate("Ms1.Area"=Ms1.Area/mean(Ms1.Area, na.rm=T)) %>% ungroup()
    
    # Normalize Ms1.Area based with the median of each cell
    plotdata <- plotdata %>% 
      dplyr::group_by(Raw.file, Label) %>% 
      dplyr::mutate("Ms1.Area.Norm" = Ms1.Area/median(Ms1.Area, na.rm=T)) %>% dplyr::ungroup()
    
    # Filter for at least 3 Precursors / Protein.Group
    plotdata <- plotdata %>% 
      dplyr::group_by(Raw.file, Label, Protein.Group) %>% 
      dplyr::mutate("n" = n()) %>% dplyr::ungroup()
    plotdata <- plotdata[plotdata$n>3,]
    
    
    # Calculate CV for every protein group
    plotdata <- plotdata %>% 
      dplyr::group_by(Raw.file, Label, Protein.Group) %>% 
      dplyr::summarise("cv" = sd(Ms1.Area.Norm)/mean(Ms1.Area.Norm))
    
    # Calculate median cv for every cell
    plotdata <- plotdata %>% 
      dplyr::group_by(Raw.file, Label) %>% 
      dplyr::summarise('median_cv' = median(cv)) %>% 
      dplyr::ungroup()
    
    # Calculate x coordinate as id in set.
    # Only needed as heloper for plotting
    plotdata <- plotdata %>% 
      dplyr::group_by(Raw.file) %>% 
      dplyr::mutate('x' = row_number()) %>% 
      dplyr::ungroup()
     
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)

    validate(need((nrow(plotdata) > 1), paste0('No Rows selected')))
    
    
    ggplot(plotdata)+
      geom_jitter( aes(x=x, y=median_cv, color=Label), size=6)+
      theme_diann() +
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      ylab("Quantification Variability")+
      xlab("")+
      ylim(0,1)+
      xlim(0,4)+
      theme_diann() +
      theme(legend.position = "bottom")+
      theme(axis.text.x = element_blank())+
      scale_color_manual(name='plexDIA Label:', values = c(custom_colors[[1]],custom_colors[[2]],custom_colors[[3]]))
    
 
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

