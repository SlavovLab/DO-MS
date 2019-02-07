# load settings tab

settings_tab <- tabItem(tabName='settings', fluidPage(
  h2('Import Options'),
  panel(
    div(class='import-header', 
        h3('Select Files to Load')),
    p(class='import-help', 'The text files to load from each folder selected. Unselect large files, such as "allPeptides.txt", if you are not analyzing unidentified ions and want to speed up load times.'),
    fixedRow(column(12,
      div(class='well input-file-select-well',
        div(class='well-header', h4('Input File Selection')),
        div(class='exp_check_btn_row',
          tags$button(id='files_check_all', class='btn files_check_all', 'Select All'),
          tags$button(id='files_check_none', class='btn files_check_none', 'Select None')
        ),
        checkboxGroupInput('input_files', '', choiceNames=file_names,
          selected=default_selected_files, choiceValues=file_vals)
      )
    ))
  ),
  h2('Plotting Options'),
  panel(
    h3('Global Display Options'),
    fluidRow(
      column(12, numericInput('ppi', 'Points per Inch (PPI)', value=config[['ppi']], 
                              min=75, max=600, step=1))
    )
  ),
  panel(
    h3('Figure Download Options'),
    tags$p('Set the width, height, and units of plots when downloading as PDF or PNG'),
    selectInput('download_figure_units', 'Plot Units', selected=config[['download_figure_units']],
                choices=list('Inches'='in', 'Centimeters'='cm', 'Millimeters'='mm')),
    fluidRow(
      column(6, numericInput('download_figure_width', 'Plot Width', value=config[['download_figure_width']], 
                             min=1, max=99, step=0.1)),
      column(6, numericInput('download_figure_height', 'Plot Height', value=config[['download_figure_height']], 
                             min=1, max=99, step=0.1))
    )
  ),
  panel(
    h3('Figure Display Options'),
    tags$p('Change the visual appearance of figures'),
    fluidRow(
      column(4, numericInput('figure_title_font_size', 'Label Font Size', 
                             min=4, max=48, step=1, value=config[['figure_title_font_size']])),
      column(4, numericInput('figure_axis_font_size', 'Axis Font Size', 
                             min=4, max=48, step=1, value=config[['figure_axis_font_size']])),
      column(4, numericInput('figure_facet_font_size', 'Facet Font Size', 
                             min=4, max=48, step=1, value=config[['figure_facet_font_size']]))
    ),
    fluidRow(
      column(12, numericInput('figure_line_width', 'Line Width', 
                             min=1, max=10, step=0.25, value=config[['figure_line_width']]))
    ),
    fluidRow(
      column(12, checkboxInput('figure_show_grid', 'Show Background Grid', 
                               value=config[['figure_show_grid']]))
    )
  )
))