init <- function() {
  
  type <- 'plot'
  box_title <- 'XIC Reference vs. XIC Technical Standard'
  help_text <- 'This shows the Extracted Ion Chromatogram (XIC) of a reference run vs. a technical standard, intersected for the
  same precursors. The chosen precursors are highly abundant and are sampled across the gradient. This helps benchmark the chromatogrpahy of the instrument.'
  source_file <- 'xic_ref'
  
  .validate <- function(data, input) {
    validate(need(data()[['xic_ref']], paste0('Upload report.XIC.tsv')))
    validate(need((nrow(data()[['xic_ref']]) > 1), paste0('No Rows selected')))
  }
  
  .plotdata <- function(data, input) {
    ref_data <- data()[['xic_ref']]
    standard_data <- data()[['xic_standard']]
    
    
    file_org <- function(file){
      
      min_rt = as.numeric(min(file$RT))
      max_rt = as.numeric(max(file$RT))
      gradient_quartile = (max_rt - min_rt) / 4
      
      file$Type = 0
      file[((file$RT >= min_rt) & (file$RT <= min_rt + gradient_quartile)),  ]$Type <- 'Head'
      file[((file$RT > min_rt + gradient_quartile) & (file$RT <= min_rt + (3 * gradient_quartile))), ]$Type <- 'Middle'
      file[(file$RT > min_rt + (3 * gradient_quartile)) & (file$RT <= max_rt), ]$Type = 'Tail' 
      file <- file[file$Type != 0, ]
      
      return(file)
    }
    
    xic_func <- function(xic_file){
      
      xic_file = xic_file[xic_file$MS.Level == 1, ]
      xic_file = xic_file[!grepl("decoy", xic_file$Precursor.Id),]
      rt_values = xic_file[xic_file$Retention.Times == 1, ]
      xic_file = xic_file[xic_file$Intensities == 1, ]
      
      rt_values = rt_values[,grepl("[0-9]", colnames(rt_values))]
      rt_values$RT = apply(rt_values, 1, median, na.rm=T)
      
      rt_values = file_org(rt_values)
      xic_file$Type = rt_values$Type
      
      rt_values = rt_values[1:(ncol(rt_values)-2)]
      
      colnames(rt_values) <- seq(1, ncol(rt_values))
      colnames(rt_values) <- paste(colnames(rt_values), "rt",sep = "_")
      
      xic_file = cbind(xic_file, rt_values)
      colnames(xic_file)[grepl("X[0-9]*$", colnames(xic_file))] <- seq(1, length(xic_file[grepl("X[0-9]*$", colnames(xic_file))]))
      colnames(xic_file)[grepl("^[0-9]*$", colnames(xic_file))] <- paste(colnames(xic_file)[grepl("^[0-9]*$", colnames(xic_file))], "int",sep = "_")
      
      
      xic_file[grepl("int", colnames(xic_file))] <- apply(xic_file[grepl("int", colnames(xic_file))], 2, function(x) as.numeric(as.character(x)))
      
      
      xic_file$MS1.Area <- rowSums(xic_file[grepl("int", colnames(xic_file))], na.rm=TRUE)
      xic_file <- xic_file[xic_file$MS1.Area > 0, ]
      
      # Keep top 3 from each type
      xic_file_max <- xic_file %>% group_by(Stripped.Sequence, Type) %>% arrange_all() %>% filter(row_number() == n())
      top_3 <- xic_file_max %>% group_by(Type) %>% arrange(Type, desc(MS1.Area)) %>% top_n(3)
      top_3 <- top_3[top_3$MS1.Area > 0, ]
      
      return(top_3)
    }
    
    xic_file_ref <- xic_func(ref_data)
    xic_file_iqc <- xic_func(standard_data)
    common_precursors = intersect(xic_file_iqc$Stripped.Sequence, xic_file_ref$Stripped.Sequence)
    
    xic_file_iqc = xic_file_iqc[xic_file_iqc$Stripped.Sequence %in% common_precursors, ]
    xic_file_ref = xic_file_ref[xic_file_ref$Stripped.Sequence %in% common_precursors, ]
    
    xic_file_iqc_plot = xic_file_iqc[grepl("int", colnames(xic_file_iqc))]
    xic_file_iqc_plot$Type <- xic_file_iqc$Type
    xic_file_ref_plot = xic_file_ref[grepl("int", colnames(xic_file_ref))]
    xic_file_ref_plot$Type <- xic_file_ref$Type
    
    intensity_df_iqc = melt(xic_file_iqc_plot, value.name = "Intensity")
    intensity_df_iqc$rowid <- 1:nrow(xic_file_iqc) 
    intensity_df_iqc$Intensity <- intensity_df_iqc$Intensity * -1
    intensity_df_iqc$Run <- 'IQC'
    
    intensity_df_ref = melt(xic_file_ref_plot, value.name = "Intensity")
    intensity_df_ref$rowid <- 1:nrow(xic_file_ref) 
    intensity_df_ref$Run <- 'REF'
    
    
    plotdata <- rbind(intensity_df_iqc, intensity_df_ref)
    
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)

    ggplot(plotdata[plotdata$Run == 'REF', ], aes(variable, Intensity, group=factor(rowid))) + 
      geom_line(aes(color=factor(rowid))) + 
      geom_point(aes(color=factor(rowid))) +
      geom_hline(yintercept = 0) +
      theme_bw() +
      theme(plot.title = element_text(lineheight=0.5,family = "TNR"),
            axis.line = element_line(),
            axis.text.x = element_blank(),
            axis.ticks.x = element_blank(),
            axis.title.x = element_blank(), 
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.background = element_blank(),
            panel.border = element_blank(),
            legend.position = "none") + 
      scale_x_discrete(labels = 1:31) +
      scale_y_continuous(limits = c(max(plotdata$Intensity) * -1, max(plotdata$Intensity)), 
                         breaks = round(seq(max(plotdata$Intensity) * -1, max(plotdata$Intensity), 
                                            by = max(plotdata$Intensity) / 20), -4)) +
      facet_grid(cols = vars(Type), scales = 'free_y') +
      geom_line(data = plotdata[plotdata$Run == 'IQC', ], aes(color=factor(rowid))) + 
      geom_point(data = plotdata[plotdata$Run == 'IQC', ], aes(color=factor(rowid))) + 
      geom_text(
        data    = plotdata[plotdata$Run == 'IQC', ],
        mapping = aes(x = -Inf, y = -Inf, label = 'Standard'),
        hjust   = -0.1,
        vjust   = -1) +
      geom_text(
        data    = plotdata[plotdata$Run == 'REF', ],
        mapping = aes(x = -Inf, y = Inf, label = 'Reference'),
        hjust   = -0.1,
        vjust   = 1)
    
    
    
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    box_width=12,
    plot_height=600,
    plot_width = 600
  ))
}
