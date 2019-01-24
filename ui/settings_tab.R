# load settings tab

settings_tab <- tabItem(tabName='settings', fluidPage(
  h1('Plotting Options'),
  panel(
    h3('Global Display Options'),
    fluidRow(
      column(12, numericInput('ppi', 'Points per Inch (PPI)', 150, min=75, max=600, step=1))
    )
  ),
  panel(
    h3('Figure Download Options'),
    tags$p('Set the width, height, and units of plots when downloading as PDF or PNG'),
    selectInput('download_figure_units', 'Plot Units', selected='in',
                choices=list('Inches'='in', 'Centimeters'='cm', 'Millimeters'='mm')),
    fluidRow(
      column(6, numericInput('download_figure_width', 'Plot Width', 5, min=1, max=99, step=0.1)),
      column(6, numericInput('download_figure_height', 'Plot Height', 5, min=1, max=99, step=0.1))
    )
  ),
  panel(
    h3('Figure Display Options'),
    tags$p('Change the visual appearance of figures'),
    fluidRow(
      column(4, numericInput('figure_title_font_size', 'Label Font Size', 
                             min=4, max=48, step=1, value=16)),
      column(4, numericInput('figure_axis_font_size', 'Axis Font Size', 
                             min=4, max=48, step=1, value=12)),
      column(4, numericInput('figure_facet_font_size', 'Facet Font Size', 
                             min=4, max=48, step=1, value=12))
    ),
    fluidRow(
      column(12, numericInput('figure_line_width', 'Line Width', 
                              min=1, max=10, step=0.25, value=1))
    ),
    fluidRow(
      column(12, checkboxInput('figure_show_grid', 'Show Background Grid', value=TRUE))
    )
  )
))