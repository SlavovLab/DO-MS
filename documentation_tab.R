# auto-generate documentation tab

documentation_tab <- list(
  h1("Documentation")
)

for(t in 1:length(tabs)) {
  # add tags for this tab
  tab_list <- list(
    h3(paste(tabs[t], 'Tab'))
  )
  
  modules_in_tab <- modules[sapply(modules, function(m) { m$tab == tabs[t] })]
  for(m in 1:length(modules_in_tab)) {
    tab_list[[m+1]] <- div(class='documentation-module',
      h4(modules_in_tab[[m]]$boxTitle),
      p(paste0('Required file(s): ', modules_in_tab[[m]]$source.file)),
      p(modules_in_tab[[m]]$help)
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


# documentation_tab <- tabItem(tabName = "documentation", fluidPage(
#   h1("Documentation"),
#   
#   tags$u(h3("Contamination Tab:")),
#   
#   h4("Parental Ion Fraction Plot"),
#   p(tags$u("Source:"), " evidence.txt"),
#   br(),
#   
#   h4("MS1 Intensity (z=1) Plot"),
#   p(tags$u("Source:")," allPeptides.txt"),
#   br(),
#   
#   h4("M/Z Distribution For All z=1 Plot"),
#   p(tags$u("Source:")," allPeptides.txt"),
#   br(),
#   
#   h4("Number of Ions by Charge State Plot"),
#   p(tags$u("Source:")," allPeptides.txt"),
#   p(tags$u("Notes:")," Charges greater than 3 were set to '4+'"),
#   br(),
#   
#   h4("Total Ion Current by Charge State Plot"),
#   p(tags$u("Source:")," allPeptides.txt"),
#   p(tags$u("Notes:")," Charges greater than 3 were set to '4+'"),
#   br(),
#   
#   
#   tags$u(h3("Abundance Tab:")),
#   
#   h4("MS1 Intensity for all z=1 Ions Plot"),
#   p(tags$u("Source:")," allPeptides.txt"),
#   br(),
#   
#   h4("MS1 Intensity for all MS/MSd Ions Plot"),
#   p(tags$u("Source:")," allPeptides.txt"),
#   br(),
#   
#   h4("MS1 Intensity for IDd Ions Plot"),
#   p(tags$u("Source:")," evidence.txt"),
#   br(),
#   
#   h4("Reporter Ion Intensity (Non-Normalized) Plot"),
#   p(tags$u("Source:")," evidence.txt"),
#   br(),
#   
#   
#   tags$u(h3("Sample Quality Tab")),
#   
#   h4("Number of Confident IDs Plot"),
#   p(tags$u("Source:")," evidence.txt"),
#   p(tags$u("Notes:")," This plot presents you with the number of IDs you have for a given PEP threshold"),
#   br(),
#   
#   h4(" Missed Cleavages (PEP < .01) Plot"),
#   p(tags$u("Source:")," evidence.txt"),
#   p(tags$u("Notes:")," This plot presents you with the missed cleavage distribution for all peptides that meet the .01 PEP threshold"),
#   br(),
#   
#   h4("MS1 Injection Times | No PSM Plot"),
#   p(tags$u("Source:"), " msmsScans.txt"),
#   br(),
#   
#   h4("MS1 Injection Times | PSM Plot"),
#   p(tags$u("Source:")," msmsScans.txt"),
#   br(),
#   
#   
#   tags$u(h3("Instrument Performance Tab")),
#   
#   h4("Precursor Apex Offset Plot"),
#   p(tags$u("Source:"),"msmsScans.txt"),
#   p(tags$u("Notes:")," Offsets greater than 8 were set to 9, and offsets less than -8 were set to -9."),
#   br(),
#   
#   h4("Retention Lengths (FWHM) Plot"),
#   p(tags$u("Source:"), " allPeptides.txt"),
#   p(tags$u("Notes:")," Retention Lengths greater than 45 seconds were set to 49 seconds"),
#   br(),
#   
#   h4("IDs By Retention Time Plot"),
#   p(tags$u("Source:")," evidence.txt"),
#   br(),
#   
#   h4("Retention Lengths for IDd Ions Plot"),
#   p(tags$u("Source:")," evidence.txt"),
#   p(tags$u("Notes:")," Retention lengths greater than 120 seconds were set to 120 seconds."),
#   br()
# ))