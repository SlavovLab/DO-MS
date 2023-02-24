init <- function() {
  
  type <- 'plot'
  box_title <- 'Labeled / unlabeled precursor ion intensity, PEP < 0.01'
  help_text <- 'Labeled / unlabeled precursor ion intensity. Only compatible with searches performed with TMT as a variable mod.'
  source_file <- 'evidence'
  repDiv <- ''
  
  .validate <- function(data, input) {
    validate(need(data()[['Labeling_Efficiency']], paste0('Upload evidence.txt in labeling efficiency input')))
    # require TMT as a variable mod
    #validate(need(any(grepl('TMT', data()[['Labeling_Efficiency']]$Modifications)), 
                  #paste0('Loaded data was not searched with TMT as a variable modification')))
    #validate(need(any(grepl('TMTPro_K_LE', colnames(data()[['Labeling_Efficiency']]))), 
                #  paste0('Loaded data was not searched with TMT as a variable modification')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['Labeling_Efficiency']]
    #plotdata <- read.delim("G:/My Drive/MS/cluster_searches/IZ_LAB0725/evidence.txt")
    plotdata$SeqCharge <- paste0(plotdata$Modified.sequence, plotdata$Charge)
    pdcol <-colnames(plotdata)
    pdcol_TMT <- pdcol[(grepl("TMT",pdcol)&(!grepl("Probabilities",pdcol))&(!grepl("Score.Diffs", pdcol))&(!grepl("site.IDs", pdcol)))]
    plotdata$SeqCharge <- gsub(paste0("\\(",pdcol_TMT[1],"\\)"),"",plotdata$SeqCharge)
    plotdata$SeqCharge <- gsub(paste0("\\(",pdcol_TMT[2],"\\)"),"",plotdata$SeqCharge)
    
    plotdata <- plotdata %>%
      # filter at 0.01 PEP
      dplyr::filter(PEP < 0.01)

      plotdata_unmod <- plotdata %>% filter(!grepl("TMT",Modifications))
      plotdata_mod <- plotdata %>% filter(grepl("TMT",Modifications))
      plotdata_join <- plotdata_unmod %>% dplyr::inner_join(plotdata_mod, by = "SeqCharge")
      plotdata_join$Log2IntRatio <- log2(plotdata_join$Intensity.y/plotdata_join$Intensity.x) 
      plotdata_join_lim <- plotdata_join %>% dplyr::select(Raw.file.x,SeqCharge,Log2IntRatio)
      
      plotdata_join_lim %>% ggplot(aes(Log2IntRatio)) + geom_histogram() + facet_wrap(~Raw.file.x)
    return(plotdata_join_lim)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)

    plotdata <- .plotdata(data, input)
    
    validate(need(nrow(plotdata) > 2, paste0('Less than 2 peptides with labeled and unlabeled precursors')))
    
    ggplot(plotdata, aes(Log2IntRatio)) +
      geom_histogram() +
      coord_flip() + 
      facet_wrap(~Raw.file.x, nrow=1) +
      labs(x="Log2(Precursor Intensity Ratio)\n(Labeled / Unlabeled)", y='# Peptides') +
      theme_base(input=input) +
      theme(axis.text.x=element_text(angle=45, hjust=1, vjust=1))
  }
  
  return(list(
    type=type,
    box_title=box_title,
    repDiv=repDiv,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot
  ))
}
