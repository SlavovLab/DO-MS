source('global.R')

menu_items <- list(
  menuItem('Import', tabName='import')
)
for(i in 1:length(tabs)) {
  menu_items[[i+1]] <- menuItem(tabs[i], tabName=tabs[i])
}

tab_items <- list(
  tabItem(tabName='import', fluidPage(
    uiOutput('input_forms')
  ))
)
for(i in 1:length(tabs)) {
  tab_items[[i+1]] <- tabItem(tabName=tabs[i], fluidPage(
    uiOutput(tabs[i])
  ))
}

shinyUI(
  
  dashboardPage(
    dashboardHeader(title = "Basic dashboard"),
    dashboardSidebar(
      sidebarMenu(
        menu_items
      )
    ),
    dashboardBody(
      #uiOutput('tabs')
      div(class='tab-content', tab_items)
    )
  )
  
)