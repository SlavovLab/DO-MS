# Module UI function
csvFileInput <- function(id, label = "CSV file") {
  # Create a namespace function using the provided id
  ns <- NS(id)
  
  tagList(
  fileInput(ns("file"), "1. Choose MaxQuant Evidence File",
            accept = c(
              "text/csv",
              "text/comma-separated-values,text/plain",
              ".csv",'.txt', options(shiny.maxRequestSize=300*1024^2) )
  )
  )
}