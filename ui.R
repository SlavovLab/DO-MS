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

linkedScatterUI <- function(id) {
  ns <- NS(id)
  
  fluidRow(
    #column(4, plotOutput(ns("plot1"), brush = ns("brush"))),
    #column(4, plotOutput(ns("plot2"), brush = ns("brush"))),
    column(12, plotOutput(ns('plot3')))
  )
}

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
          #plotOutput("plot", height = 370)
          
          linkedScatterUI("scatters")
        )
      )
    )
  )
  
)