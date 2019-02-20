# load report tab

report_tab <- tabItem(tabName = "report", fluidPage(
  h1("Generate a Report"),
  panel(
    p('Once you\'re happy with how your plots look in the dashboard, press "download report" to generate a static report'),
    p('You can also output the figures as .png files alongside your report.'),
    p('We recommend an HTML report with PNG images for the most convenience and functionality'),
    p('Note: If running the application via. command line, required tools such as \"pandoc\" may not have been loaded, and this will result in an error when attempting to generate a report. Please see ',
  a(href='https://github.com/SlavovLab/DO-MS/wiki/Known-Issues#pandoc-not-found', 'the pandoc section in Known Issues ', target='_blank'),
  'for more details.'),
    tags$hr(),
    fluidRow(
      column(3, selectInput('report_format', 'Report Format',
                            choices=c('HTML' = 'html', 'PDF' = 'pdf'), 
                            selected=config[['report_format']])
      ),
      column(3, selectInput('report_figure_format', 'Plot Format', 
                            choices=c('PDF' = 'pdf', 'PNG' = 'png'), 
                            selected=config[['report_figure_format']])
      ), 
      # https://bootswatch.com/3/
      column(3, selectInput('report_theme', 'Report Theme (HTML only)',
                            choices=c('Default'='default', 'Cerulean'='cerulean', 'Flatly'='flatly',
                                      'Darkly'='darkly', 'Readable'='readable', 'Spacelab'='spacelab',
                                      'United'='united', 'Cosmo'='cosmo', 'Lumen'='lumen', 'Paper'='paper',
                                      'Sandstone'='sandstone', 'Simplex'='simplex', 'Yeti'='yeti'),
                            selected=config[['report_theme']])), 
      column(3)
    ),
    fluidRow(
      column(3, numericInput('report_figure_width', 'Plot Width (in)', value=config[['report_figure_width']], 
                             min=1, max=99, step=0.1)),
      column(3, numericInput('report_figure_height', 'Plot Height (in)', value=config[['report_figure_height']], 
                             min=1, max=99, step=0.1)),
      column(3), column(3)
    ),
    fluidRow(
      column(3, tags$a(id='download_report',
                       class='btn btn-primary shiny-download-link', href='', target='_blank',
                       download=NA, icon("download"), 'Download Report'))
    )
  )
))
