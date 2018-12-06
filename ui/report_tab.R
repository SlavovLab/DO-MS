# load report tab

report_tab <- tabItem(tabName = "report", fluidPage(
  h1("Generate a Report"),
  panel(
    p("Once you're happy with how your plots look in the dashboard, press 'download report' to generate a PDF report"),
    p("You can also output the figures as .png files alongside your PDF report."),
    p('Note: If running the application via. command line, required tools such as \"pandoc\" may not have been loaded, and this will result in an error when attempting to generate a report. Please see https://github.com/SlavovLab/SCoPE_QC/blob/master/documentation/pandoc.md for more details.'),
    tags$hr(),
    fluidRow(
      column(3, selectInput('report_format', 'Report Format',
                            choices=c("HTML" = "html", "PDF" = "pdf"), selected='html')
      ),
      column(3, selectInput('report_figure_format', 'Plot Format', 
                            choices=c("PDF" = "pdf", "PNG" = "png"), selected='png')
      ), 
      # https://bootswatch.com/3/
      column(3, selectInput('report_theme', 'Report Theme (HTML only)',
                            choices=c('Default'='default', 'Cerulean'='cerulean', 'Flatly'='flatly',
                                      'Darkly'='darkly', 'Readable'='readable', 'Spacelab'='spacelab',
                                      'United'='united', 'Cosmo'='cosmo', 'Lumen'='lumen', 'Paper'='paper',
                                      'Sandstone'='sandstone', 'Simplex'='simplex', 'Yeti'='yeti'),
                            selected='readable')), 
      column(3)
    ),
    fluidRow(
      column(3, numericInput('report_figure_width', 'Plot Width (in)', 5, min=1, max=99, step=0.1)),
      column(3, numericInput('report_figure_height', 'Plot Height (in)', 5, min=1, max=99, step=0.1)),
      column(3), column(3)
    ),
    fluidRow(
      column(3, tags$a(id='download_report',
                       class='btn btn-primary shiny-download-link', href='', target='_blank',
                       download=NA, icon("download"), 'Download Report'))
    )
  )
))