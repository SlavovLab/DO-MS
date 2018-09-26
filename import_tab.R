# load import tab

file_vals <- names(input_files)
file_names <- lapply(input_files, function(i) {
  tags$div(class='input_file_choice',
    tags$span(i[['name']]),
    tags$button(class='btn btn-secondary tooltip-btn', 
                `data-toggle`='tooltip', `data-placement`='right', title=i[['help']],
                icon('question-sign', lib='glyphicon'))
  )
})
# this list can't be named -- shiny will complain
names(file_names) <- NULL

import_tab <- tabItem(tabName='import', fluidPage(
  titlePanel('Import your data'),
  fluidRow(
    column(5, div(
      wellPanel(
        div(class='well-header', h4('Status')),
        htmlOutput('data_status')
      ),
      div(class='upload-button-container',
        tags$button(id='confirm_folders', 
          class='btn btn-primary action-button shiny-bound-input',
          icon('file-upload'), 'Upload Data')
      ),
      wellPanel(
        div(class='well-header', h4('Folder Actions')),
        div(class='selected-folders-output',
          htmlOutput('selected_folders')
        ),
        tags$div(class='folder-button-list',
          actionButton('choose_folder', 'Add folder to list', 
                       icon=icon('plus', lib='glyphicon')),
          actionButton('folder_select_all', 'Select all folders', 
                       icon=icon('eraser')),
          actionButton('clear_folder_selection', 'Clear selection', 
                       icon=icon('eraser')),
          actionButton('delete_folders', 'Remove selected folders', 
                       icon=icon('trash'))
        )
      ),
      wellPanel(
        div(class='well-header', h4('Input File Selection')),
        div(class='exp_check_btn_row',
            tags$button(id='files_check_all', class='btn files_check_all',
                        'Select All'),
            tags$button(id='files_check_none', class='btn files_check_none',
                        'Select None')
        ),
        checkboxGroupInput('input_files', '', 
                           choiceNames=file_names, 
                           selected=file_vals, choiceValues=file_vals)
      )
    )), # end column5
    column(7, wellPanel(
      div(class='well-header', h4('Folder List')),
      DT::dataTableOutput('folder_table')
    ))
  )
  #p("After uploading your evidence.txt file, please wait for your experiments to appear in the sidebar before uploading msmsScans.txt and allPeptides.txt"),
  #p("You can then explore your data in the Dashboard."),
  #uiOutput('input_forms'),
  #tags$hr(),
  #p("Enter a comma-separated list of short labels for each Raw-file/exp"),
  #textInput("Exp_Names", "Exp Names", value = "", 
  #          width = NULL, placeholder = "Comma Sep Exp Names")
))