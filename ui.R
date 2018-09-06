source('global.R')

shinyUI(
  
  dashboardPage(
    dashboardHeader(title = "Basic dashboard"),
    dashboardSidebar(
      
      #csvFileInput("datafile", "User data (.csv format)")
      fileInput("file", "1. Choose MaxQuant Evidence File",
                accept = c(
                  "text/csv",
                  "text/comma-separated-values,text/plain",
                  ".csv",'.txt', options(shiny.maxRequestSize=300*1024^2) )
      )
    ),
    dashboardBody(
      # tabs here
      # uiOutput(tab1), tab2 ....
      uiOutput("plots")
    )
  )
  
)