#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


source('global.R')

# Define UI for application that draws a histogram
# shinyUI(fluidPage(
#   sidebarLayout(
#     sidebarPanel(
#       csvFileInput("datafile", "User data (.csv format)")
#     ),
#     mainPanel(
#       dataTableOutput("table")
#     )
#   )
# )
# )


shinyUI(
  
  dashboardPage(
    dashboardHeader(title = "Basic dashboard"),
    dashboardSidebar(
      
      csvFileInput("datafile", "User data (.csv format)")
      
    ),
    dashboardBody(
      # Boxes need to be put in a row (or column)
      fluidRow(
        box(
          
          #dataTableOutput("table")
          plotOutput("table", height = 370)
          
        )
      )
    )
  )
  
)
