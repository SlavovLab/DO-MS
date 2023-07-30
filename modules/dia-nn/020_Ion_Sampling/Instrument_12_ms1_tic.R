init <- function() {
  
  type <- 'plot'
  box_title <- 'MS1 TIC along Gradient'
  help_text <- 'The total Ion Current (TIC) is shown for bins along the retention time gradient.'
  source_file <- 'report'
  
  .validate <- function(data, input) {
    validate(need(data()[['tic']],paste0('Upload tic.tsv')))
    validate(need(config[['RT.Start']],paste0('Please specify RT.Start parameter in the settings')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['tic']]
    
    # Apply retention time filter as specified in settings.yaml
    tic.matrix <- plotdata %>% 
      filter(Retention.time > config[['RT.Start']]) %>% 
      filter(Retention.time < config[['RT.End']])

    tic.mean <- tic.matrix %>%
      group_by(Raw.file, Retention.time) %>%
      summarise(mean = weighted.mean(MZ, TIC), .groups = "drop")
    
    plotdata <- list("matrix" = tic.matrix, "mean" = tic.mean)
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)

    tic.matrix <- plotdata$matrix
    tic.mean <- plotdata$mean
    
    ggplot(tic.matrix) + 
      facet_wrap(~Raw.file, nrow = 1, scales = "free_x") + 
      geom_tile(aes(Retention.time, MZ, fill= log10(TIC))) +
      scale_fill_viridis(discrete=FALSE) +
      geom_line(data = tic.mean, aes(y = mean, x =Retention.time, color = "TIC weighted m/z"), size = 1)+
      labs(y='m/z', x='Retention Time in minutes') +
      scale_color_manual(name = "", values = c( "TIC weighted m/z" = custom_colors[[1]]))+
      theme(legend.position = "bottom")+
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
