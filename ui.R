source('global.R')

shinyUI(
  
  dashboardPage(
    dashboardHeader(title = "Basic dashboard"),
    dashboardSidebar(
      sidebarMenu(
        menuItem('Tab1', tabName='tab_1'),
        menuItem('Tab2', tabName='tab_2')
      ),
      #csvFileInput("datafile", "User data (.csv format)")
      # fileInput("file", "1. Choose MaxQuant Evidence File",
      #           accept = c(
      #             "text/csv",
      #             "text/comma-separated-values,text/plain",
      #             ".csv",'.txt', options(shiny.maxRequestSize=300*1024^2) )
      # )
      uiOutput('input_forms')
    ),
    dashboardBody(
      # tabs here
      # tablist(
      # uiOutput('tab1'),
      # uiOutput('tab2')
      #)
      # uiOutput(tab1), tab2 ....
      #uiOutput("plots")
      tabItems(
        uiOutput('tabs')
      )
      # tabItems(
      #   tabItem(tabName='tab_1',fluidPage(h1('1'))),
      #   tabItem(tabName='tab_2',fluidPage(h1('2')))
      # )
    )
  )
  
)