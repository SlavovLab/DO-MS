

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

## resolve dependency collisions between shinydashboard and shinyWidgets
## we'll use these dependency handles to suppress warnings and then reinject them

# # get bootstrap dependency
#bsDep <- shiny::bootstrapLib()
#bsDep$name <- "bootstrap2"
library(htmltools)
bsDep <- findDependencies(
  bootstrapLib()
)
bsDep[[1]]$name <- "bootstrap2"

# get pickerInput dependency
pkDep <- htmltools::findDependencies(shinyWidgets:::attachShinyWidgetsDep(tags$div(), widget = "picker"))
pkDep[[2]]$name <- "picker2"


global_filters <- list()

if (config[['do_ms_mode']] == 'max_quant'){
  
  global_filters <- list(
    shinyWidgets::sliderTextInput('pep_thresh', 
      label=tags$div(class='slider-label-header',
         tags$span(class='slider-title', 'PEP Threshold:'),
         # tooltip: https://getbootstrap.com/docs/3.3/javascript/#tooltips
         tags$button(class='btn btn-secondary tooltip-btn', icon('question-sign', lib='glyphicon'),
           `data-toggle`='tooltip', `data-placement`='right', 
           title='Filter identified peptides at an identification confidence threshold (Posterior error probability -- PEP). Peptides that have a PEP higher than this value will not be included in the module analyses or visualizations.'
         )
      ), 
      grid = T, choices=c(1e-4, 1e-3, 1e-2, 1e-1, 1), selected=config[['pep_thresh']]),
    # PIF filter slider
    shinyWidgets::sliderTextInput('pif_thresh', 
      label=tags$div(class='slider-label-header',
         tags$span(class='slider-title', 'PIF Threshold:'),
         # tooltip: https://getbootstrap.com/docs/3.3/javascript/#tooltips
         tags$button(class='btn btn-secondary tooltip-btn', icon('question-sign', lib='glyphicon'),
           `data-toggle`='tooltip', `data-placement`='right', 
           title='Filter identified peptides at an isolation purity score threshold (Precursor Ion Fraction -- PIF). Peptides that have a PIF lower than this value will not be included in the module analyses or visualizations'
         )
      ),
      grid = T, choices=seq(0, 1, by=0.1), selected=config[['pif_thresh']])
    
  )
} else if (config[['do_ms_mode']] == 'dia-nn'){
  global_filters <- list(
    shinyWidgets::sliderTextInput('pep_thresh', 
      label=tags$div(class='slider-label-header',
                     tags$span(class='slider-title', 'PEP Threshold:'),
                     # tooltip: https://getbootstrap.com/docs/3.3/javascript/#tooltips
                     tags$button(class='btn btn-secondary tooltip-btn', icon('question-sign', lib='glyphicon'),
                                 `data-toggle`='tooltip', `data-placement`='right', 
                                 title='Filter identified peptides at an identification confidence threshold (Posterior error probability -- PEP). Peptides that have a PEP higher than this value will not be included in the module analyses or visualizations.'
                     )
      ), 
      grid = T, choices=c(1e-4, 1e-3, 1e-2, 1e-1, 1), selected=config[['pep_thresh']]),
    shinyWidgets::pickerInput(
      inputId = "modification",
      choices = config[['modification_list']]$name,
      label=tags$div(class='slider-label-header',
         tags$span(class='slider-title', 'Modification:'),
         # tooltip: https://getbootstrap.com/docs/3.3/javascript/#tooltips
         tags$button(class='btn btn-secondary tooltip-btn', icon('question-sign', lib='glyphicon'),
             `data-toggle`='tooltip', `data-placement`='right', 
             title='Filter dataset for certain modifications.'
         )
      ),
    )
    
  )
  
}



shinyUI(
  dashboardPage(skin=config[['mode_skin']],
    dashboardHeader(title = "DO-MS Dashboard",
                    
                    tags$li(class='dropdown', style='display:flex;flex-direction:row;align-items:center;height:50px', 
                            tags$a(class='github-btn', style='padding:5px;border-radius:10px',
                                   href='https://github.com/SlavovLab/DO-MS/', target='_blank',
                                   tags$img(src='GitHub_Logo_White.png', height='30px')),
                            tags$span(class='version-string', paste0('Version: ', version)),
                            tags$span(class='version-string', paste0('Mode: ', config[['mode_name']])))
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
      tags$h4('Select Experiments to Display'),
      shinyWidgets::pickerInput(
        inputId = "Exp_Sets", choices = NULL, selected=NULL, multiple = TRUE, 
        options = list(`actions-box` = TRUE, size = 10, `selected-text-format` = 'count > 1')
      ),
      
      tags$hr(),
      # global filters for MQ mode
      global_filters
      
      # PEP filter slider
      

      
    ),
    dashboardBody(
      
      ## resolve dependency collisions between shinydashboard and shinyWidgets
      ## https://github.com/dreamRs/shinyWidgets/issues/147
      
      # Suppress dependencies
      htmltools::suppressDependencies("selectPicker"),
      htmltools::suppressDependencies("bootstrap"),
      
      # reinject them
      pkDep, bsDep,
      
      
      tags$head(
        tags$style(HTML(app_css)),
        tags$script(HTML(app_js))
      ),
      div(class='tab-content', tab_items)
    )
  )
)


