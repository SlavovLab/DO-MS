# auto-generate documentation tab

documentation_tab <- list(
  h1("Documentation")
)

tab_nav_links <- list()

for(t in 1:length(tabs)) {
  tab_link <- tolower(gsub('_|\\s', '-', tabs[t]))
  
  # add tags for this tab
  tab_list <- list(
    h3(paste(tabs[t], 'Tab')),
    a(name=tab_link)
  )
  
  modules_in_tab <- modules[[t]]
  
  for(m in 1:length(modules_in_tab)) {
    tab_list[[m+2]] <- div(class='documentation-module',
      h4(modules_in_tab[[m]]$box_title),
      p(paste0('Required file(s): ', modules_in_tab[[m]]$source_file)),
      p(modules_in_tab[[m]]$help_text)
    )
  }
  
  documentation_tab[[t+1]] <- div(
    class='documentation-tab', 
    style=paste0('border-left:10px solid ', config[['tab_colors']][t], ';'),
    tab_list)
  
  tab_nav_links[[t]] <- tags$li(tags$a(href=paste0('#', tab_link), tabs[t]))
}


documentation_tab <- tabItem(tabName = "documentation", fluidPage(
  fluidRow(
    column(3,
      # table of contents
      tags$nav(class='documentation-nav',
        tags$ul(class='navbar nav', tab_nav_links)
      )
    ),
    column(9, documentation_tab)
  )
))