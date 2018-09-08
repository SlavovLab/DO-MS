source('global.R')

source('documentation_tab.R')

# list of menu items for switching tabs
# add static items for static tabs first
menu_items <- list()
# add menu item for each tab
for(i in 1:length(tabs)) {
  # for tabName, replace spaces/whitespace with dashes '-'
  menu_items[[i]] <- menuSubItem(tabs[i], tabName=gsub('\\s', '-', tabs[i]))
}

# list of tab items for each tab
# add static items for static tabs first
tab_items <- list(
  tabItem(tabName='import', fluidPage(
    h1("Import your data"),
    p("After uploading your evidence.txt file, please wait for your experiments to appear in the sidebar before uploading msmsScans.txt and allPeptides.txt"),
    p("You can then explore your data in the Dashboard."),
    uiOutput('input_forms'),
    tags$hr(),
    p("Enter a comma-separated list of short labels for each Raw-file/exp"),
    textInput("Exp_Names", "Exp Names", value = "", 
              width = NULL, placeholder = "Comma Sep Exp Names")
  )),
  tabItem(tabName = "report", fluidPage(
    h1("Generate a PDF Report"),
    p("Once you're happy with how your plots look in the dashboard, press 'download report' to generate a PDF report"),
    p("You can also output the figures as .png files alongside your PDF report."),
    
    tags$hr(),
    radioButtons("genPic", "Save figures as .png files?",
                 c("Yes" = "Y",
                   "No" = "N")),
    downloadButton("report.pdf","Download report"),
    textOutput("UserExpList")
  )),
  documentation_tab
)
# add tab item for each tab
# each tab has a uiOutput (HTML output) that will be
# defined in server.R
for(i in 1:length(tabs)) {
  # for tabName, replace spaces/whitespace with dashes '-'
  tab_items[[i+3]] <- tabItem(tabName=gsub('\\s', '-', tabs[i]), fluidPage(
    uiOutput(tabs[i])
  ))
}

shinyUI(
  dashboardPage(skin='blue',
    dashboardHeader(title = "SCoPE QC Dashboard"),
    dashboardSidebar(
      sidebarMenu(
        # Sidebar Menu Options
        menuItem("Import Data", tabName = "import", icon = icon("upload", lib="glyphicon")),
        menuItem("Dashboard", tabName = "dashboard", 
                 icon = icon("signal", lib = "glyphicon"), startExpanded = TRUE,
          menu_items
        ),
        menuItem("Generate Report", tabName = "report", icon = icon("book", lib="glyphicon")),
        menuItem("Documentation", tabName = "documentation", icon = icon("book", lib="glyphicon"))
      ),
      
      tags$hr(),
      #Experimental Subsetting Box
      selectInput('Exp_Sets', 'sets', choices = NULL, multiple = TRUE),
      p("(Remove items via backspace)", style="padding:20px;"),
      tags$hr(),
      
      #PEP selection slider
      shinyWidgets::sliderTextInput("slider", "PEP Threshold:", 
        choices=c(1e-4,0.001,.01,0.1), selected=0.1, grid = T),
      tags$script(HTML("$('body').addClass('fixed');"))
      
    ),
    dashboardBody(
      tags$head(tags$style(HTML('
      .main-header .logo { 
        font-family: "Josefin slab", Times, "Times New Roman", serif;
        font-weight: bold; font-size: 24px;
      }'))),
      div(class='tab-content', tab_items)
    )
  )
)