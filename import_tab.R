# load import tab

import_tab <- tabItem(tabName='import', fluidPage(
  h1("Import your data"),
  p("After uploading your evidence.txt file, please wait for your experiments to appear in the sidebar before uploading msmsScans.txt and allPeptides.txt"),
  p("You can then explore your data in the Dashboard."),
  uiOutput('input_forms'),
  tags$hr(),
  p("Enter a comma-separated list of short labels for each Raw-file/exp"),
  textInput("Exp_Names", "Exp Names", value = "", 
            width = NULL, placeholder = "Comma Sep Exp Names")
))