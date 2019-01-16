init <- function() {
  
  tab <- '030 Peptide Identifications'
  boxTitle <- 'Number of Confident Identifications'
  help <- 'Plotting the number of peptides identified at each given confidence
    level.'
  source.file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[[source.file]],paste0("Upload ", source.file, ".txt")))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[[source.file]][,c("Raw.file","PEP")]

    pep <- as.data.frame(table(plotdata[,c('Raw.file','PEP')]))
    pep <- pep[pep$Freq!=0,]
    pep<-data.frame(pep$Raw.file, as.numeric(as.character(pep$PEP)), as.numeric(pep$Freq))
    colnames(pep)<-c("Raw.file","PEP","Freq")
    plotdata <- pep %>% group_by(`Raw.file`) %>% mutate(cy=cumsum(Freq))

    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    
    # Rank the Experiments by most number of peptides observed
    
    maxnum <- c()
    rawnames <- c()
    
    for(X in unique(plotdata$Raw.file)){
      maxnum <- c(maxnum, max(plotdata$cy[plotdata$Raw.file%in%X]) )
      rawnames <- c(rawnames,X)
    }
    
    names(maxnum) <- rawnames
    rankExp <- maxnum[order(maxnum, decreasing = T)]
    rankExp_ord <- seq(1,length(rankExp),1)
    names(rankExp_ord) <- names(rankExp)
    plotdata$rank_ord <- NA
    
    for(X in levels(plotdata$Raw.file)) {
      plotdata$rank_ord[plotdata$Raw.file%in%X] <- rankExp_ord[X]
    }
    
    cc <- scales::seq_gradient_pal("red", "blue", "Lab")(seq(0,1,length.out=length(rankExp_ord)))
    
    ggplot(plotdata, aes(x=PEP, color = factor(rank_ord), y=cy, group=Raw.file)) + 
      geom_line(size = input$figure_line_width) +
      scale_colour_manual(name = "Experiment", values=cc, labels = names(rankExp_ord)) +
      coord_flip() + 
      scale_x_log10(limits = c(.00009,.1), breaks = c(.0001,.001,.01,.1), 
                    labels = scales::trans_format("log10", scales::math_format(10^.x))) + 
      theme_base(input=input) +
      theme(legend.position = "right") + 
      theme(legend.key = element_rect(fill = "white")) +
      ylab("Number of IDs") 
    
  }
  
  return(list(
    tab=tab,
    boxTitle=boxTitle,
    help=help,
    source.file=source.file,
    validateFunc=.validate,
    plotdataFunc=.plotdata,
    plotFunc=.plot
  ))
}
