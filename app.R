#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

######################################################################################
######################################################################################
#
#
######################################################################################
######################################################################################

#Packages to check for
packages.needed <- c("shiny","shinydashboard","shinyWidgets","dplyr","plyr","ggplot2","reshape2","RColorBrewer")

#Checking installed packages against required ones
new.packages <- packages.needed[!(packages.needed %in% installed.packages()[,"Package"])]

#Install those which are absent
if(length(new.packages)) install.packages(new.packages, dependencies = TRUE) 

#Libraries to load
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(dplyr)
library(plyr)
library(ggplot2) 
library(reshape2)
library(RColorBrewer)

######################################################################################
######################################################################################
# GUI code block: 
#     Controls Dashboard appearance/interactivity
######################################################################################
######################################################################################


ui <- dashboardPage(skin = "blue",
  
   # Application title
   dashboardHeader(title = "SCoPE QC Dashboard"),
   dashboardSidebar(
     sidebarMenu(
       
       # Sidebar Menu Options
       menuItem("Import Data", tabName = "import", icon = icon("upload", lib="glyphicon")),
       menuItem("Dashboard", tabName = "dashboard", icon = icon("signal", lib = "glyphicon"), startExpanded = TRUE,
                # Dashboard Submenus
                menuSubItem("Contamination", tabName = "Contam"),
                menuSubItem("Abundance", tabName = "Abund"),
                menuSubItem("Sample Quality", tabName = "Sample"),
                menuSubItem("Instrument Performance", tabName = "Inst")
                ),
       menuItem("Documentation", tabName = "Doc", icon = icon("book", lib="glyphicon"))
   ),

   tags$hr(),
   
   #Experimental Subsetting Box
   selectInput('foo','sets', choices = NULL, multiple = TRUE),
   p("(Remove items via backspace)", style="padding:20px;"),
   tags$hr(),
   
   #PEP selection slider
   #sliderInput("slider", "PEP Threshold:",    min = 1e-04, max =1e-01 , value = -10^seq(-2, 2)),
   shinyWidgets::sliderTextInput("slider","PEP Threshold:" , choices=c(1e-4,0.001,.01,0.1), selected=0.1, grid = T),
   tags$script(HTML("$('body').addClass('fixed');")),
   
   textInput("Exp_Names", "Exp Names", value = "", width = NULL, placeholder = "Comma Sep Exp Names"),
   
   downloadButton("report.pdf","Download report")
   ),
   
   dashboardBody(
     tags$head(tags$style(HTML('
      .main-header .logo {
                               font-family: "Josefin slab", Times, "Times New Roman", serif;
                               font-weight: bold;
                               font-size: 24px;
                               }
                               '))),
     
     tabItems(
       
       # Body of Import Tab
       tabItem(tabName = "import",
               fluidPage(
                 h1("Import your data"),
                 p("After uploading your evidence.txt file, please wait for your experiments to appear in the sidebar before uploading msmsScans.txt and allPeptides.txt"),
                 p("You can then explore your data in the Dashboard."),
                 
                 tags$hr(),
                 fileInput("file", "1. Choose MaxQuant Evidence File",
                           accept = c(
                             "text/csv",
                             "text/comma-separated-values,text/plain",
                             ".csv",'.txt', options(shiny.maxRequestSize=300*1024^2) )
                 ),
                 
                 fileInput("file2", "2. Choose MaxQuant msmsScans File",
                           accept = c(
                             "text/csv",
                             "text/comma-separated-values,text/plain",
                             ".csv",'.txt', options(shiny.maxRequestSize=300*1024^2) )
                 ),
                 fileInput("file3", "3. Choose MaxQuant allPeptides File",
                           accept = c(
                             "text/csv",
                             "text/comma-separated-values,text/plain",
                             ".csv",'.txt', options(shiny.maxRequestSize=970*1024^2) )
                 ),
                 textOutput("UserExpList")
               )
               ),
       
       # Dashboard Content
       tabItem(tabName = "dashboard",
               fluidRow(
               #Dynamic infoBoxes
               #infoBoxOutput("peptideBox"),
               #infoBoxOutput("proteinBox"),
               #infoBoxOutput("geneBox")
               )
               
               ),
       ######################################################################################
       # Contaminants Plots
       ######################################################################################
       
       tabItem(tabName = "Contam",
               fluidRow(
                
                 box(
                   title = "Parental Ion Fraction", status = "warning", solidHeader = TRUE, 
                   collapsible = TRUE,
                   plotOutput("plot4", height = 370)
                 ),
                 
                 box(
                   title = "MS1 Intensity for all z=1 ions", status = "warning", solidHeader = TRUE, 
                   collapsible = TRUE, 
                   plotOutput("plot11", height = 370)
                 ),
                 
                 box(
                   title = "M/z distribution for all z=1 ions", status = "warning", solidHeader = TRUE, 
                   collapsible = TRUE, 
                   plotOutput("plot13", height = 370)
                 ),
                 box(
                   title = "Number of ions by charge state", status = "warning", solidHeader = TRUE, 
                   collapsible = TRUE, 
                   plotOutput("plot16", height = 370)
                 ),
                 
                 box(
                   title = "Total ion current by charge state", status = "warning", solidHeader = TRUE, 
                   collapsible = TRUE, 
                   plotOutput("plot17", height = 370)
                 ),
                 box(
                   title = "Intensity of z=1 ions along the gradient", status = "warning", solidHeader = TRUE, 
                   collapsible = TRUE, 
                   plotOutput("plot18", height = 370)
                 )
                 
               )
       ),
       
       ######################################################################################
       #Abundance Tab plots
       ######################################################################################
       
       tabItem(tabName = "Abund",
               fluidRow(
                 
                 box(
                   title = "MS1 Intensity for all z>1 ions", status = "success", solidHeader = TRUE, 
                   collapsible = TRUE, 
                   plotOutput("plot12", height = 370)
                 ),
                 
                 box(
                   title = "MS1 Intensity for MS/MSd Ions", status = "success", solidHeader = TRUE, 
                   collapsible = TRUE, 
                   plotOutput("plot14", height = 370)
                 ),
                 
                 box(
                   title = "MS1 Intensity for IDd Ions", status = "success", solidHeader = TRUE, 
                   collapsible = TRUE,
                   plotOutput("plot6", height = 370)
                 ),
                 
                 box(
                   title = "Reporter Ion Intensity (non-normalized)", status = "success", solidHeader = TRUE,
                   collapsible = TRUE,
                   plotOutput("plot15", height = 370)
                 )

                 #,
                 #box(
                  # title = "Controls", status = "primary", solidHeader = TRUE, 
                  # collapsible = TRUE,
                  # sliderInput("slider", "Number of observations:", 1, 100, 50)
                 #)
                 
                 #box(
                  # title = "Intensity by Channel", status = "primary", solidHeader = TRUE, 
                  # collapsible = TRUE,
                  # plotOutput("plot2", height = 370)
                 #),
                 
               )
       ),
       ######################################################################################         
       # Sample Quality Plots Tab
       ######################################################################################
       
       tabItem(tabName = "Sample",
                       fluidRow(
                         
                         box(
                           title = "Number of Confident IDs", status = "primary", solidHeader = TRUE, 
                           collapsible = TRUE,
                           plotOutput("plot1", height = 370)
                         ),
                         
                         box(
                           title = "Missed Cleavages (PEP < .01)", status = "primary", solidHeader = TRUE, 
                           collapsible = TRUE,
                           plotOutput("plot7", height = 370)
                         ),
                         
                         
                         box(
                           title = "MS2 Injection Times | No PSMs", status = "primary", solidHeader = TRUE, 
                           collapsible = TRUE, 
                           plotOutput("plot9", height = 370)
                         ),
                         
                         box(
                           title = "MS2 Injection Times | PSMs", status = "primary", solidHeader = TRUE, 
                           collapsible = TRUE, 
                           plotOutput("plot10", height = 370)
                         )
                         
                       )
               ),
       
        ######################################################################################       
        #Instrument Plots Tab
        ######################################################################################
       
        tabItem(tabName = "Inst",
                       fluidRow(
                         box(
                           title = "Precursor Apex Offset", status = "info", solidHeader = TRUE, 
                           collapsible = TRUE, 
                           plotOutput("plot8", height = 370)
                         ),
                         
                         box(
                           title = "Retention Lengths (FWHM)", status = "info", solidHeader = TRUE, 
                           collapsible = TRUE,
                           plotOutput("plot3", height = 370)
                         ),
                         
                         box(
                           title = "IDs by Retention Time", status = "info", solidHeader = TRUE, 
                           collapsible = TRUE,
                           plotOutput("plot5", height = 370)
                         ),
                         
                         box(
                           title = "Retention Lengths for IDd Ions", status = "info", solidHeader = TRUE, 
                           collapsible = TRUE,
                           plotOutput("plot2", height = 370)
                         )
                       )
               ),
       
       ######################################################################################
       #Documentation Tab
       ######################################################################################
       
        tabItem(tabName = "Doc",
                      fluidPage(
                        h1("Documentation"),
                        
                        tags$u(h3("Contamination Tab:")),
                        h4("Parental Ion Fraction Plot"),
                        p(tags$u("Source:"), " evidence.txt"),
                        br(),
                        h4("MS1 Intensity (z=1) Plot"),
                        p(tags$u("Source:")," allPeptides.txt"),
                        br(),
                        h4("M/Z Distribution For All z=1 Plot"),
                        p(tags$u("Source:")," allPeptides.txt"),
                        br(),
                        h4("Number of Ions by Charge State Plot"),
                        p(tags$u("Source:")," allPeptides.txt"),
                        p(tags$u("Notes:")," Charges greater than 3 were set to '4+'"),
                        br(),
                        h4("Total Ion Current by Charge State Plot"),
                        p(tags$u("Source:")," allPeptides.txt"),
                        p(tags$u("Notes:")," Charges greater than 3 were set to '4+'"),
                        br(),
                        
                        tags$u(h3("Abundance Tab:")),
                        h4("MS1 Intensity for all z=1 Ions Plot"),
                        p(tags$u("Source:")," allPeptides.txt"),
                        br(),
                        h4("MS1 Intensity for all MS/MSd Ions Plot"),
                        p(tags$u("Source:")," allPeptides.txt"),
                        br(),
                        h4("MS1 Intensity for IDd Ions Plot"),
                        p(tags$u("Source:")," evidence.txt"),
                        br(),
                        h4("Reporter Ion Intensity (Non-Normalized) Plot"),
                        p(tags$u("Source:")," evidence.txt"),
                        br(),
                        
                        tags$u(h3("Sample Quality Tab")),
                        h4("Number of Confident IDs Plot"),
                        p(tags$u("Source:")," evidence.txt"),
                        p(tags$u("Notes:")," This plot presents you with the number of IDs you have for a given PEP threshold"),
                        br(),
                        h4(" Missed Cleavages (PEP < .01) Plot"),
                        p(tags$u("Source:")," evidence.txt"),
                        p(tags$u("Notes:")," This plot presents you with the missed cleavage distribution for all peptides that meet the .01 PEP threshold"),
                        br(),
                        h4("MS1 Injection Times | No PSM Plot"),
                        p(tags$u("Source:"), " msmsScans.txt"),
                        br(),
                        h4("MS1 Injection Times | PSM Plot"),
                        p(tags$u("Source:")," msmsScans.txt"),
                        br(),
                        
                        tags$u(h3("Instrument Performance Tab")),
                        h4("Precursor Apex Offset Plot"),
                        p(tags$u("Source:"),"msmsScans.txt"),
                        p(tags$u("Notes:")," Offsets greater than 8 were set to 9, and offsets less than -8 were set to -9."),
                        br(),
                        h4("Retention Lengths (FWHM) Plot"),
                        p(tags$u("Source:"), " allPeptides.txt"),
                        p(tags$u("Notes:")," Retention Lengths greater than 45 seconds were set to 49 seconds"),
                        br(),
                        h4("IDs By Retention Time Plot"),
                        p(tags$u("Source:")," evidence.txt"),
                        br(),
                        h4("Retention Lengths for IDd Ions Plot"),
                        p(tags$u("Source:")," evidence.txt"),
                        p(tags$u("Notes:")," Retention lengths greater than 120 seconds were set to 120 seconds."),
                        br()
                        
                      )
                    )
               #fluidRow(
                 # Dynamic infoBoxes
                 #infoBoxOutput("peptideBox"),
                 #infoBoxOutput("proteinBox"),
                 #infoBoxOutput("geneBox")
               #)
       )
       
       # Second tab content
       #tabItem(tabName = "widgets",
      #         h2("Widgets tab content")
       #)
     )
)

######################################################################################
######################################################################################
# Server Code Block: 
# 1. Data Import
# 2. Dynamic Subsetting of Data
# 3. Plot Generation
# 4. PDF Report Generation
######################################################################################
######################################################################################


server <- function(input, output, session) {
  
    # Global Axis Tick Label Font Size Control
    textVar = 1.1
  
    #Reactive element for importing evidence.txt file
    data <- reactive({
    file1 <- input$file
    if(is.null(file1)){return()}
    read.delim(file=file1$datapath, header=TRUE)
    #evi <- data()
    #evLevels <- levels(evi$Raw.file)
    #updateSelectizeInput(session, 'foo', choices = eviLevels, server = TRUE)
    })
  
    #Reactive element for importing msmsScans.txt file
    data2 <- reactive({
    file2 <- input$file2
    if(is.null(file2)){return()}
    read.delim(file=file2$datapath, header=TRUE)
    })
    
    #Reactive element for importing allPeptides.txt file
    data3 <- reactive({
      file3 <- input$file3
      if(is.null(file3)){return()}
      read.delim(file=file3$datapath, header=TRUE)
    })
    
    #Generic titles for experiments
    levelsLib <- c("Exp1","Exp2","Exp3","Exp4","Exp5","Exp6","Exp7","Exp8","Exp9","Exp10","Exp11","Exp12","Exp13","Exp14","Exp15","Exp16","Exp17","Exp18","Exp19","Exp20","Exp21","Exp22","Exp23","Exp24","Exp25","Exp26","Exp27","Exp28","Exp29","Exp30")
    
    #Dynamically determine experiments in evidence.txt
    observe({
      evi <- data()
      
      output$UserExpList <- renderText({ input$Exp_Names })
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      print(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      print(levelsLib)
      
      eviLevels <- levels(evi$Raw.file)
      if(length(eviLevels) > 0){
        eviLevels <- levels(evi$Raw.file)
        #
        length_raw_levels <- length(eviLevels)
        raw_levels <- eviLevels
        raw_Levels_new <- paste0(levelsLib[1:length_raw_levels],": ",raw_levels)
        eviLevels <- raw_Levels_new
        exp_list <- as.list(setNames(levelsLib[1:length_raw_levels],raw_levels))
        #
      }
      else{
        eviLevels <- ""
        raw_levels <- ""
      }

      updateSelectInput(session, "foo", "Select Experiments to Display", choices = eviLevels, selected = eviLevels)
    })
    
    #Reactive element to test for the presence of evidence.txt prior to plot generation
    df <- reactive({
      validate(
        need(input$file != "", 'Please upload evidence.txt')
      )
      evi <- data()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      print(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      
      eviLevels <- levels(evi$Raw.file)
      #
      length_raw_levels <- length(eviLevels)
      raw_levels <- eviLevels
      raw_Levels_new <- paste0(levelsLib[1:length_raw_levels],": ",raw_levels)
      eviLevels <- raw_Levels_new
      print(eviLevels)
      levels(evi$Raw.file) <- raw_Levels_new
      #
      #raw_levels <- levels(evi$Raw.file)
      #length_raw_levels <- length(raw_levels)
      #raw_levels <- raw_levels
      #raw_Levels_new <- paste0(levelsLib[1:length_raw_levels],": ",raw_levels)
      #raw_levels$replacement <- raw_Levels_new
      #names(raw_levels) <- c("Raw.file","Replacement")
      #evi$Raw.file <- raw_levels$Replacement[match(evi$Raw.file, raw_levels$Raw.file)]
      #levels(evi$Raw.file) <- raw_Levels_new
      
      #
      #msmsScans <- data2()
      #allPep <- data3()
      evi <- filter(evi, !grepl("CON", Leading.razor.protein))
      evi <- filter(evi, !grepl("REV", Leading.razor.protein))
      #filter(evi, Raw.file %in% input$foo)
      filter(evi, Raw.file %in% input$foo)
      #print(levels(evi$Raw.file))
    })
    
    #Reactive element to test for the presence of msmsScans.txt prior to plot generation
    df2 <- reactive({
      validate(
        need(input$file2 != "", 'Please upload msmsScans.txt')
      )
      msmsScans <- data2()
      msmsLevels <- levels(msmsScans$Raw.file)
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      print(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      #
      length_raw_levels <- length(msmsLevels)
      raw_levels <- msmsLevels
      raw_Levels_new <- paste0(levelsLib[1:length_raw_levels],": ",raw_levels)
      msmsLevels <- raw_Levels_new
      levels(msmsScans$Raw.file) <- raw_Levels_new
      filter(msmsScans, Raw.file %in% input$foo)

    })
    
    #Reactive element to test for the presence of allPeptides.txt prior to plot generation
    df3 <- reactive({
      validate(
        need(input$file3 != "", 'Please upload allPeptides.txt')
      )
      aP <- data3()
      aPLevels <- levels(aP$Raw.file) 
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      print(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      #
      length_raw_levels <- length(aPLevels)
      raw_levels <- aPLevels
      raw_Levels_new <- paste0(levelsLib[1:length_raw_levels],": ",raw_levels)
      aPLevels <- raw_Levels_new
      levels(aP$Raw.file) <- raw_Levels_new
      filter(aP, Raw.file %in% input$foo)
    })
    
    
    #Function to generate abbreviated plot labels
    Exp_labeller <- function(variable,value){
      return(exp_list[value])
    }
    #print(exp_list)
    
    ##########################
    # User Inputted Experiments
    ##########################

  
   
    
    ######################################################################################
    ######################################################################################
    # Plot Generation 
    #
    ######################################################################################
    ######################################################################################
    
    
    ######################################################################################
    # Contamination Tab Plots (6 plots)
    ######################################################################################
    
    #Plot1: PIF distributions
    output$plot4 <- renderPlot({
      
      validate(need(input$file,"Upload evidence.txt"))
      validate(need((input$foo),"Loading"))
      df <- df()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      histdata <- df[,c("Raw.file","PIF","PEP")]
      histdata <- histdata[histdata$PEP < input$slider,]
      lengthLev <- length(levels(histdata$Raw.file))
      levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      #print(levels(histdata$Raw.file))
      #
      #raw_levels <- levels(df$Raw.file)
      #length_raw_levels <- length(raw_levels)
      #raw_levels <- raw_levels
      #raw_Levels_new <- paste0(levelsLib[1:length_raw_levels],": ",raw_levels)
      #raw_levels$replacement <- raw_Levels_new
      #levels(histdata$Raw.file) <- raw_Levels_new3k
      #levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      #data <- histdata[seq_len(input$slider)]
      ggplot(histdata, aes(PIF)) + facet_wrap(~Raw.file, nrow = 1)+ geom_histogram(bins=100) + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)),axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) 
      
      
      
    })
    
    #Plot 2: MS1 Intensity for all z=1 ions (allPeptides)
    output$plot11 <- renderPlot({
      validate(need(input$file3,"Upload allPeptides.txt"))
      validate(need((input$foo),"Loading"))
      df <- df3()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      histdata <- df[,c("Raw.file","Charge", "Intensity")]
      lengthLev <- length(levels(histdata$Raw.file))
      levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      histdata$Intensity <- log10(histdata$Intensity)
      histdata_Z1 <- histdata[histdata$Charge == 1,]
      #data <- histdata[seq_len(input$slider)]
      ggplot(histdata_Z1, aes(Intensity)) + facet_wrap(~Raw.file, nrow = 1)+ geom_histogram() + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + xlab(expression(bold("Log"[10]*" Precursor Intensity"))) 
      
      
    })
    
    #Plot 3: M/z dist for all z=1 ions (allPeptides)
    output$plot13 <- renderPlot({
      validate(need(input$file3,"Upload allPeptides.txt"))
      validate(need((input$foo),"Loading"))
      df <- df3()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      histdata <- df[,c("Raw.file","Charge", "m.z")]
      lengthLev <- length(levels(histdata$Raw.file))
      levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      histdata_Z1 <- histdata[histdata$Charge == 1,]
      #data <- histdata[seq_len(input$slider)]
      ggplot(histdata_Z1, aes(m.z)) + facet_wrap(~Raw.file, nrow = 1)+ geom_histogram() + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + xlab("M/z") 
      
      #panel.grid.major = element_line(colour="lightgrey", size=0.25)
    })
    
    #Plot 4: Ion Counts by Charge State (allPeptides)
    output$plot16 <- renderPlot({
      validate(need((input$file3),"Upload allPeptides.txt"))
      validate(need((input$foo),"Loading"))
      df <- df3()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      histdata <- df[,c("Raw.file","Charge")]
      lengthLev <- length(levels(histdata$Raw.file))
      levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      histdata$Charge[histdata$Charge > 3] <- 4
      histdata_Charge <- count(histdata,c("Raw.file","Charge"))
      hc <- aggregate(histdata_Charge$freq, by=list(Category=histdata_Charge$Raw.file,histdata_Charge$Charge), FUN=sum)
      colnames(hc) <- c("Raw.file","Charge","Frequency")
      ggplot(hc, aes(x=Raw.file, y=Frequency,colour=factor(Charge), group=Raw.file)) + 
        geom_point(size = 2)+ theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),axis.text.x =element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + 
        ylab("Number") + scale_color_hue(labels = c("1","2","3",">3")) + labs(x = "Experiment", y = "Count", col = "Charge State")  
      #scale_fill_manual(labels =c("1","2","3","4+"),values=c("black", "red", "blue","green"))
      #scale_color_brewer(palette = "Paired") + scale_fill_brewer(palette = "Paired")
      #+ scale_color_hue(labels = c("1","2","3",">3"))
      #scale_color_manual(labels =c("1","2","3","4+"), values=c("black", "red", "blue","green")) +
    })
    
    #Plot 5: Total Ion Current by Charge State (allPeptides)
    output$plot17 <- renderPlot({
      validate(need((input$file3),"Upload allPeptides.txt"))
      validate(need((input$foo),"Loading"))
      df <- df3()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      histdata <- df[,c("Raw.file","Charge","Intensity")]
      lengthLev <- length(levels(histdata$Raw.file))
      levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      histdata$Charge[histdata$Charge > 3] <- 4
      hc <- aggregate(histdata$Intensity, by=list(Category=histdata$Raw.file,histdata$Charge), FUN=sum)
      colnames(hc) <- c("Raw.file","Charge","Intensity")
      ggplot(hc, aes(x=Raw.file, y=Intensity,colour=factor(Charge), group=Raw.file)) + 
        geom_point(size = 2)+ theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),axis.text.x =element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + 
        ylab("Number")  + labs(x = "Experiment", y = "Total Ion Current", col = "Charge State") + scale_y_log10() +  scale_color_hue(labels = c("1","2","3",">3")) + labs(x = "Experiment", y = "Count", col = "Charge State")
      #scale_color_brewer(palette = "Paired") + scale_fill_brewer(palette = "Paired")
      #scale_color_manual(labels =c("1","2","3","4+"), values=c("black", "red", "blue","green")) + scale_fill_manual(labels =c("1","2","3","4+"),values=c("black", "red", "blue","green"))
      
    })
    
    #Plot 6: Intensity of z=1 ions across the gradient
    output$plot18 <- renderPlot({
      validate(need((input$file3),"Upload allPeptides.txt"))
      validate(need((input$foo),"Loading"))
      df <- df3()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      histdata <- df[,c("Raw.file","Charge","Intensity","Retention.time")]
      lengthLev <- length(levels(histdata$Raw.file))
      levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      histdata <- histdata[histdata$Charge == 1,]
      histdata$Retention.time <- floor(histdata$Retention.time)
      #histdata$log10Int <- log10(histdata$Intensity)
      #histdata$Intensity <- log10(histdata$Intensity)
      #hc <- aggregate(histdata$Intensity, by=list(Category=histdata$Raw.file,histdata$Charge), FUN=sum)
      #colnames(hc) <- c("Raw.file","Charge","Intensity")
      #ggplot(hc, aes(x=Raw.file, y=Intensity, colour=factor(Charge), group=Raw.file)) + 
      #  geom_point(size = 2)+ theme(axis.text.x =element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar))) + 
      #  ylab("Number") + scale_color_hue(labels = c("1","2","3",">3")) + labs(x = "Experiment", y = "Total Ion Current", col = "Charge State") + scale_y_log10() +
      #  #scale_color_brewer(palette = "Paired") + scale_fill_brewer(palette = "Paired")
      #  scale_color_manual(labels =c("1","2","3","4+"), values=c("black", "red", "blue","green")) + scale_fill_manual(labels =c("1","2","3","4+"),values=c("black", "red", "blue","green"))
      #ggplot(histdata, aes(y=log10, x=Retention.time, colour = Raw.file, fill = Raw.file)) + facet_wrap(~Raw.file, nrow = 1)+ geom_col(width=1) + coord_flip() + theme(legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar))) + xlab("Retention Time (min)") + ylab(expression(bold("Log"[10]*" Precursor Intensity"))) +
      #  scale_color_brewer(palette = "Paired") + scale_fill_brewer(palette = "Paired") 
      ggplot(histdata, aes(x = Retention.time, y = Intensity)) + geom_bar(stat = 'identity', width= 1)+ facet_wrap(~Raw.file, nrow = 1) + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + xlab("Retention Time (min)") + ylab(expression(bold("Precursor Intensity"))) 
      
      
    })
    ######################################################################################
    # Abundance Tab Plots (4 Plots)
    ######################################################################################
    
    #Plot 7: MS1 Intensity for all z>1 ions (allPeptides)
    output$plot12 <- renderPlot({
      validate(need(input$file3,"Upload allPeptides.txt"))
      validate(need((input$foo),"Loading"))
      df <- df3()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      histdata <- df[,c("Raw.file","Charge", "Intensity")]
      lengthLev <- length(levels(histdata$Raw.file))
      levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      histdata$Intensity <- log10(histdata$Intensity)
      histdata_Z1 <- histdata[histdata$Charge > 1,]
      #data <- histdata[seq_len(input$slider)]
      ggplot(histdata_Z1, aes(Intensity)) + facet_wrap(~Raw.file, nrow = 1)+ geom_histogram() + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + xlab(expression(bold("Log"[10]*" Precursor Intensity"))) 
      
    })
    
    #Plot 8: MS1 Intensity for all MS/MSd ions (allPeptides)
    output$plot14 <- renderPlot({
      validate(need(input$file3,"Upload allPeptides.txt"))
      validate(need((input$foo),"Loading"))
      df <- df3()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      histdata <- df[,c("Raw.file","MS.MS.Count", "Intensity")]
      lengthLev <- length(levels(histdata$Raw.file))
      levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      histdata$Intensity <- log10(histdata$Intensity)
      histdata_MSMS <- histdata[histdata$MS.MS.Count >= 1,]
      #data <- histdata[seq_len(input$slider)]
      ggplot(histdata_MSMS, aes(Intensity)) + facet_wrap(~Raw.file, nrow = 1)+ geom_histogram() + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + xlab(expression(bold("Log"[10]*" Precursor Intensity"))) 
      
    })
    
    #Plot 9: MS1 Intensity for IDd Ions
    output$plot6 <- renderPlot({
      validate(need(input$file,"Upload evidence.txt"))
      validate(need((input$foo),"Loading"))
      df <- df()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      histdata <- df[,c("Raw.file","Intensity","PEP")]
      histdata <- histdata[histdata$PEP < input$slider,]
      lengthLev <- length(levels(histdata$Raw.file))
      levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      histdata$Intensity <- log10(histdata$Intensity)
      #data <- histdata[seq_len(input$slider)]
      ggplot(histdata, aes(Intensity)) + facet_wrap(~Raw.file, nrow = 1)+ geom_histogram(bins=100) + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + xlab(expression(bold("Log"[10]*" Precursor Intensity")))
      
    })
    
    #Plot 10: Intensity Information for Single Experiment
    output$plot15 <- renderPlot({
      validate(need(input$file,"Upload evidence.txt"))
      validate(need((length(input$foo) == 1),"Please select a single experiment"))
      df <- df()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      histdata2 <- dplyr::select(df,starts_with("Reporter.intensity.corrected"))
      histdata2.m <- melt(histdata2)
      histdata2.m$log10tran <- log10(histdata2.m$value)
      uniqueLabelsSize <- length(unique(histdata2.m$variable))
      TMTlabels <- c("C1","C2","C3","C4","C5","C6","C7","C8","C9","C10","C11")
      plot2Labels <- TMTlabels[1:uniqueLabelsSize]
      ggplot(histdata2.m,aes(x=variable,y=log10tran))+ 
        geom_violin(aes(group=variable,colour=variable,fill=variable),alpha=0.5, 
                    kernel="rectangular")+    # passes to stat_density, makes violin rectangular 
        xlab("TMT Channel")+             
        ylab(expression(bold("Log"[10]*" RI Intensity")))+ 
        theme_bw()+                     # make white background on plot
        theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position = "none",axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + scale_x_discrete(name ="TMT Channel", 
                                                                                                                                                                                                                                                                                                                                                                                                                                                 labels=plot2Labels) 
    })
    
    ######################################################################################
    # Sample Quality Tab Plots (4 Plots)
    ######################################################################################
    
    #Plot 11: Cumulative sum of peptides that fall at a given PEP value
    output$plot1 <- renderPlot({
      validate(need((input$file),"Upload evidence.txt"))
      validate(need((input$foo),"Loading"))
      df <- df()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      histdata <- df[,c("Raw.file","PEP")]
      histdata <- histdata[histdata$PEP < input$slider,]
      lengthLev <- length(levels(histdata$Raw.file))
      #eviLevels_new <- paste0(levelsLib[1:length(levels(eviLevels))],": ",levels(eviLevels))
      #levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      histdata_PEP <- count(histdata,c('Raw.file','PEP'))
      DF.t <- ddply(histdata_PEP, .(Raw.file), transform, cy = cumsum(freq)) 
      ggplot(DF.t, aes(x=PEP, y=cy, group=Raw.file)) + geom_line(size = 1.2) + coord_flip() + scale_x_log10(limits = c(.00009,.1), breaks = c(.0001,.001,.01,.1), labels = scales::trans_format("log10", scales::math_format(10^.x))) + theme( panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"), axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=textVar)) + ylab("Number of IDs") 
      
      #ggplot(histdata, aes(x = PEP, y = cumsum(..count..), colour = factor(Raw.file))) + 
      #  geom_line(size = 1)+
      #  geom_point() 
      
    })
    
    #Plot 12: Missed Cleavages (Evidence)
    output$plot7 <- renderPlot({
      validate(need(input$file,"Upload evidence.txt"))
      validate(need((input$foo),"Loading"))
      df <- df()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      histdata <- df[,c("Raw.file","Missed.cleavages","PEP")]
      histdata <- histdata[histdata$PEP < .01,]
      histdata <- histdata[histdata$PEP < input$slider,]
      lengthLev <- length(levels(histdata$Raw.file))
      levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      #data <- histdata[seq_len(input$slider)]
      ggplot(histdata, aes(Missed.cleavages)) + facet_wrap(~Raw.file, nrow = 1)+ geom_histogram(bins=10) + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + xlab("Missed Cleavages") 
      
    })
    
    #Plot 13: MS2 Injection Times | No PSMs (msmsScans)
    output$plot9 <- renderPlot({
      validate(need(input$file2,"Upload msmsScans.txt"))
      validate(need((input$foo),"Loading"))
      df <- df2()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      histdata <- df[,c("Raw.file","Ion.injection.time", "Sequence")]
      lengthLev <- length(levels(histdata$Raw.file))
      levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      histdata_blank <- histdata[histdata$Sequence == " ",]
      #data <- histdata[seq_len(input$slider)]
      ggplot(histdata_blank, aes(Ion.injection.time)) + facet_wrap(~Raw.file, nrow = 1)+ geom_histogram() + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + xlab("Ion Injection Time (ms)") 
      
    })
    
    #Plot 14: MS2 Injection Times | PSMs (msmsScans)
    output$plot10 <- renderPlot({
      validate(need(input$file2,"Upload msmsScans.txt"))
      validate(need((input$foo),"Loading"))
      df <- df2()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      histdata <- df[,c("Raw.file","Ion.injection.time", "Sequence")]
      lengthLev <- length(levels(histdata$Raw.file))
      levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      histdata_notBlank <- histdata[histdata$Sequence != " ",]
      #data <- histdata[seq_len(input$slider)]
      ggplot(histdata_notBlank, aes(Ion.injection.time)) + facet_wrap(~Raw.file, nrow = 1)+ geom_histogram() + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + xlab("Ion Injection Time (ms)") 
      
    })
    
    ######################################################################################
    # Instrument Performance Tab Plots (4 Plots)
    ######################################################################################
    
    #Plot 15: Apex Offset (msmsScans)
    output$plot8 <- renderPlot({
      validate(need(input$file2,"Upload msmsScans.txt"))
      validate(need((input$foo),"Loading"))
      df <- df2()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      histdata <- df[,c("Raw.file","Precursor.apex.offset.time")]
      lengthLev <- length(levels(histdata$Raw.file))
      levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      histdata$Precursor.apex.offset.time <- histdata$Precursor.apex.offset.time*60
      histdata$Precursor.apex.offset.time[histdata$Precursor.apex.offset.time > 8] <- 9
      histdata$Precursor.apex.offset.time[histdata$Precursor.apex.offset.time < -8] <- -9
      #data <- histdata[seq_len(input$slider)]
      ggplot(histdata, aes(Precursor.apex.offset.time)) + facet_wrap(~Raw.file, nrow = 1)+ geom_histogram() + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + xlab("Apex Offset (sec)") 
      
    })
    
    #Plot 16: Retention Length FWHM (allPeptides)
    output$plot3 <- renderPlot({
      validate(need(input$file3,"Upload allPeptides.txt"))
      validate(need((input$foo),"Loading"))
      df <- df3()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      histdata <- df[,c("Raw.file","Retention.length..FWHM.")]
      lengthLev <- length(levels(histdata$Raw.file))
      levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      histdata$Retention.length..FWHM.[histdata$Retention.length..FWHM. > 45] <- 49
      #data <- histdata[seq_len(input$slider)]
      ggplot(histdata, aes(Retention.length..FWHM.)) + facet_wrap(~Raw.file, nrow = 1)+ geom_histogram(bins = 49) + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)),axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + xlab("Retention Length FWHM (sec)")
      
    })
    
    #Plot 17: IDs By Retention Time 
    output$plot5 <- renderPlot({
      validate(need(input$file,"Upload evidence.txt"))
      validate(need((input$foo),"Loading"))
      df <- df()
      
      text_to_parse <-  paste(input$Exp_Names)
      User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
      #User_Exp_vector <- c(User_Exp_vector)
      if(length(User_Exp_vector) != 0){
        levelsLib <- User_Exp_vector
      }
      
      #df$Retention.time[df$Retention.time < 15] <- 15
      histdata <- df[,c("Raw.file","Retention.time","PEP")]
      histdata <- histdata[histdata$PEP < input$slider,]
      lengthLev <- length(levels(histdata$Raw.file))
      levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
      maxRT <- max(histdata$Retention.time)
      #histdata$Retention.time[histdata$Retention.time <= 10] <- 10
      #data <- histdata[seq_len(input$slider)]
      ggplot(histdata, aes(Retention.time)) + facet_wrap(~Raw.file, nrow = 1)+ geom_histogram(bins=100) + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(1.2),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) +
        xlim(10, maxRT)
      
    })
    
    
    # Plot 18: Retention Lengths for IDd Ions
    output$plot2 <- renderPlot({
    validate(need(input$file,"Upload evidence.txt"))
    validate(need((input$foo),"Loading"))
    df <- df()
    
    text_to_parse <-  paste(input$Exp_Names)
    User_Exp_vector <- unlist(strsplit(text_to_parse, ","))
    #User_Exp_vector <- c(User_Exp_vector)
    if(length(User_Exp_vector) != 0){
      levelsLib <- User_Exp_vector
    }
    
    histdata <- df[,c("Raw.file","Retention.length","PEP")]
    lengthLev <- length(levels(histdata$Raw.file))
    levels(histdata$Raw.file) <- levelsLib[1:lengthLev]
    histdata$Retention.length <- histdata$Retention.length*60
    histdata$Retention.length[histdata$Retention.length > 120] <- 120
    histdata <- histdata[histdata$PEP < input$slider,]
    maxRL <- max(histdata$Retention.length)
    #data <- histdata[seq_len(input$slider)]
    ggplot(histdata, aes(Retention.length)) + facet_wrap(~Raw.file, nrow = 1)+ geom_histogram(bins=120) + coord_flip() + theme(panel.background = element_rect(fill = "white",colour = "white"), panel.grid.major = element_line(size = .25, linetype = "solid",color="lightgrey"), panel.grid.minor = element_line(size = .25, linetype = "solid",color="lightgrey"),legend.position="none", axis.text.x = element_text(angle = 45,hjust = 1, margin=margin(r=45)), axis.title=element_text(size=rel(textVar),face="bold"), axis.text = element_text(size = rel(textVar)),strip.text = element_text(size=rel(textVar))) + xlab('Retention Lengths at base (sec)')
    })
    
    ######################################################################################
    ######################################################################################
    # End of Plot Generation
    ######################################################################################    
    ######################################################################################
          
    #Box 1
    #output$proteinBox <- renderInfoBox({
    #  df <- df()
    #  uniqueRazorCount <- length(unique(df$Leading.razor.protein))
    #  infoBox(
    #    "Unique Razor Proteins", uniqueRazorCount, icon = icon("list"),
    #    color = "green"
    #  )})
   
    #Box 2
    #output$peptideBox <- renderInfoBox({
    #  df <- df()
    #  uniquePeptides <- length(unique(df$Sequence))
    #  infoBox(
    #    "Unique Peptides", uniquePeptides, icon = icon("list"),
    #    color = "yellow"
    #  )})
     
    #Box 3
    #output$geneBox <- renderInfoBox({
    #  df <- df()
    #  uniquePeptides <- length(unique(df$Gene.names))
    #  infoBox(
    #    "Unique Genes", uniquePeptides, icon = icon("list"),
    #    color = "yellow"
    #  )})
    
    ######################################################################################
    ######################################################################################
    # PDF Report Generation Area 
    #
    ######################################################################################
    ######################################################################################
    
    output$report.pdf <- downloadHandler(
      # For PDF output, change this to "report.pdf"
      filename = "SCoPE_QC_Report.pdf",
      content = function(file) {
        # Copy the report file to a temporary directory before processing it, in
        # case we don't have write permissions to the current working dir (which
        # can happen when deployed).
        tempReport <- file.path(tempdir(), "SCoPE_QC_Report.Rmd")
        file.copy("SCoPE_QC_Report.Rmd", tempReport, overwrite = TRUE)
        

        
        # Set up parameters to pass to Rmd document
        params <- list(pep_in = input$slider, set_in = input$foo, evid = input$file, msmsSc = input$file2, aPep = input$file3)
        
        # Knit the document, passing in the `params` list, and eval it in a
        # child of the global environment (this isolates the code in the document
        # from the code in this app).
        rmarkdown::render(tempReport, output_file = file,
                          params = params,
                          envir = new.env(parent = globalenv())
        )
      }
    )
    
  }
  
  
# Run the application 
shinyApp(ui = ui, server = server)
#}
