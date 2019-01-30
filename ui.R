source('global.R')

source(file.path('ui', 'documentation_tab.R')) # loads documentation_tab var
source(file.path('ui', 'report_tab.R')) # loads report_tab var
source(file.path('ui', 'import_tab.R')) # loads import_tab var
source(file.path('ui', 'settings_tab.R')) # loads settings

# list of menu items for switching tabs
# add static items for static tabs first
menu_items <- list()
# add menu item for each tab
for(i in 1:length(tabs)) {
  # for tabName, replace spaces/whitespace with dashes '-'
  menu_items[[i]] <- menuSubItem(tabs[i], tabName=paste0(gsub('\\s', '-', tabs[i]), '-', i))
}

# list of tab items for each tab
# add static items for static tabs first
tab_items <- list(
  import_tab,
  report_tab,
  documentation_tab,
  settings_tab
)
# add tab item for each tab
# each tab has a uiOutput (HTML output) that will be
# defined in server.R
for(i in 1:length(tabs)) {
  # for tabName, replace spaces/whitespace with dashes '-'
  tab_items[[i+length(tab_items)]] <- tabItem(tabName=paste0(gsub('\\s', '-', tabs[i]), '-', i), 
    fluidPage( uiOutput(tabs[i]) )
  )
}

# set a lite regex in the css to override the default box-header colors
for(i in 1:length(tabs)) {
  tab_name <- paste0(gsub('\\s', '-', tabs[i]), '-', i)
  app_css <- paste0(app_css, ' .tab-pane[id*=\"', tab_name , '\"] .box-header {',
                    'background-color: ', config[['tab_colors']][i], '; color: white; }')
  # also add a border to the menu item
  app_css <- paste0(app_css, '.treeview ul.treeview-menu a[data-value*=\"', tab_name , '\"] {',
                    'border-left: 10px solid ', config[['tab_colors']][i], '; }')
  # and make the color the background when the menuitem is active
  app_css <- paste0(app_css, '.treeview-menu li.active a[data-value*=\"', tab_name , '\"] {',
                    'background-color: ', config[['tab_colors[i]']], '; color: white; }')
}

shinyUI(
  dashboardPage(skin='blue',
    dashboardHeader(title = "DO-MS Dashboard"
      # tags$li(class='dropdown',
      # tags$button(type='button', class='btn btn-default', `data-container`='body', `data-toggle`='popover',
      #             `data-placement`='bottom', 
      #             `data-content`=checkboxGroupInput('Exp_Sets', '', choices=NULL, selected=NULL,
      #                                               choiceNames=NULL, choiceValues=NULL),
      #             `data-html`=TRUE,
      #             'Popover on bottom')
      # )
    ),
    dashboardSidebar(
      sidebarMenu(
        # Sidebar Menu Options
        menuItem("Import Data", tabName = "import", icon = icon("upload", lib="glyphicon")),
        menuItem("Dashboard", tabName = "dashboard", 
                 icon = icon("signal", lib = "glyphicon"), startExpanded = TRUE,
          menu_items
        ),
        menuItem("Generate Report", tabName = "report", icon = icon("file", lib="glyphicon")),
        menuItem("Documentation", tabName = "documentation", icon = icon("book", lib="glyphicon")),
        menuItem("Plot Settings", tabName = "settings", icon = icon("cog", lib="glyphicon"))
      ),
      
      tags$hr(),
      #Experimental Subsetting Box
      #selectInput('Exp_Sets', 'sets', choices = NULL, multiple = TRUE),
      #p("(Remove items via backspace)", style="padding:20px;"),
      tags$h4('Select Experiments to Display'),
      div(class='exp_check_btn_row',
        tags$button(id='exp_check_all', class='btn exp_check_all',
               'Select All'),
        tags$button(id='exp_check_none', class='btn exp_check_none',
               'Select None')
      ),
      
      shinyWidgets::pickerInput(
        inputId = "Exp_Sets", choices = NULL, selected=NULL, multiple = TRUE, 
        options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = 'count > 1')
      ),
      
      tags$hr(),
      
      # PEP filter slider
      shinyWidgets::sliderTextInput('pep_thresh', 'PEP Threshold:', grid = T,
        choices=c(1e-4, 1e-3, 1e-2, 1e-1, 1), selected=config[['pep_thresh']]),
      
      # PIF filter slider
      shinyWidgets::sliderTextInput('pif_thresh', 'PIF Threshold:', grid = T,
        choices=seq(0, 1, by=0.1), selected=config[['pif_thresh']])
    ),
    dashboardBody(
      tags$head(
        tags$style(HTML(app_css)),
        tags$script(HTML(app_js))
      ),
      div(class='tab-content', tab_items)
    )
  )
)
