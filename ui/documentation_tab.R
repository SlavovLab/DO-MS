# auto-generate documentation tab

documentation_tab <- list(
  h1("Documentation")
)

for(t in 1:length(tabs)) {
  # add tags for this tab
  tab_list <- list(
    h3(paste(tabs[t], 'Tab'))
  )
  
  modules_in_tab <- modules[[t]]
  
  for(m in 1:length(modules_in_tab)) {
    tab_list[[m+1]] <- div(class='documentation-module',
      h4(modules_in_tab[[m]]$box_title),
      p(paste0('Required file(s): ', modules_in_tab[[m]]$source.file)),
      p(modules_in_tab[[m]]$help_text)
    )
  }
  
  documentation_tab[[t+1]] <- div(
    class='documentation-tab', 
    style=paste0('border-left:10px solid ', tab_colors[t], ';'),
    tab_list)
}

documentation_tab <- tabItem(tabName = "documentation", fluidPage(
  documentation_tab
))