source('global.R')

# list of menu items for switching tabs
# add static items for static tabs first
menu_items <- list(
  menuItem('Import', tabName='import')
)
# add menu item for each tab
for(i in 1:length(tabs)) {
  menu_items[[i+1]] <- menuItem(tabs[i], tabName=tabs[i])
}

# list of tab items for each tab
# add static items for static tabs first
tab_items <- list(
  tabItem(tabName='import', fluidPage(
    uiOutput('input_forms')
  ))
)
# add tab item for each tab
# each tab has a uiOutput (HTML output) that will be
# defined in server.R
for(i in 1:length(tabs)) {
  tab_items[[i+1]] <- tabItem(tabName=tabs[i], fluidPage(
    uiOutput(tabs[i])
  ))
}

shinyUI(
  dashboardPage(
    dashboardHeader(title = "SCOPE-QC"),
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