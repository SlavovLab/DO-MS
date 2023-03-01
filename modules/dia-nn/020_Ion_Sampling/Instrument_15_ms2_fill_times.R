init <- function() {
  
  type <- 'plot'
  box_title <- 'Ms2 Fill Times along Gradient'
  help_text <- 'The averge fill time is shown in magenta for different bins along the retention time gradient. The standard deviation is depicted as area in blue, scans outside this area are shown as single datapoints.'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['fill_times']],paste0('Upload fill_times.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['fill_times']]

    # Apply retention time filter as specified in settings.yaml
    plotdata <- plotdata %>% 
      filter(RT.Start > config[['RT.Start']]) %>% 
      filter(RT.Start < config[['RT.End']])
    
    binned_data <- plotdata %>% 
      filter(Ms.Level == 2) %>% 
      mutate(bin = ntile(RT.Start, 15))
    
    sum_data <- binned_data %>%
      group_by(bin, Raw.file) %>% 
      summarise(mean = mean(Fill.Time), 
                sd = sd(Fill.Time), 
                RT.Mean = mean(RT.Start), 
                max = max(Fill.Time), 
                .groups = "drop") %>% 
      mutate(lower = mean - sd/2, upper = pmin(mean + sd/2, max), type='sum')
    
    joined_data <- binned_data %>% 
      full_join(sum_data, by=c("bin", 'Raw.file')) %>% 
      mutate(type = 'joined')
    
    
    plotdata <- list("sum" = sum_data, "joined" = joined_data)
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    
    validate(need((nrow(plotdata$sum) > 1), paste0('No Rows selected')))
    
    
    sum_data <- plotdata$sum
    joined_data <- plotdata$joined
    
    maxRT <- max(sum_data$RT.Mean)
    
    ggplot(sum_data) + 
      geom_point(data=joined_data, aes(x = RT.Start, y = Fill.Time), fill = 'grey80', color = "grey80") +
      geom_ribbon(aes(ymin = lower, ymax = upper, x = RT.Mean), fill = custom_colors[[3]], alpha=0.6) +
      geom_line(aes(y = mean, x = RT.Mean), color = custom_colors[[1]], size = 1) +
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      labs(y='Fill Times in ms', x='Retention Time in minutes') +
      theme_diann(input=input, show_legend=T)
      
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
    plot_height=300, # pixels
    dynamic_width=300,
    dynamic_width_base=50
  ))
}
