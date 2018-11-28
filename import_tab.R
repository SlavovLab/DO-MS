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
  titlePanel('Import Data'),
  
  
  ################################
  ###  STEP 1: SELECT FOLDERS  ###
  ################################
  
  div(class='import-header', span(class='num', '1'), h2('Select MaxQuant txt Output Folders')),
  p(class='import-help', 'Click on a row in the table to select that folder. Click multiple rows to select multiple folders, and use Shift to select a series of folders.'),
  fluidRow(
    column(9, wellPanel(
      div(class='well-header', h4('Folder List')),
      DT::dataTableOutput('folder_table')
    )),
    column(3, wellPanel(
      div(class='well-header', h4('Folder Actions')),
      div(class='selected-folders-output',
        htmlOutput('selected_folders')
      ),
      tags$div(class='folder-button-list',
        #actionButton('choose_folder', 'Add folder to list',
        #             icon=icon('plus', lib='glyphicon')),
        #shinyFilesButton('files', label='File select', title='Please select a file', multiple=T),
        shinyDirButton('choose_folder', label='Add folder to list', title='Please select a folder'),
        actionButton('folder_select_all', 'Select all folders',
                     icon=icon('th-list', lib='glyphicon')),
        actionButton('clear_folder_selection', 'Clear selection',
                     icon=icon('eraser')),
        actionButton('delete_folders', 'Remove selected folders',
                     icon=icon('trash'))
      )
    ))
  ),
  
  
  ##############################
  ###  STEP 2: SELECT FILES  ###
  ##############################
  
  div(class='import-header', span(class='num', '2'), h2('Select Files to Load')),
  fixedRow(column(12,
    div(class='well input-file-select-well',
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
  )),
  
  
  ###########################
  ###  STEP 3: LOAD DATA  ###
  ###########################
  
  div(class='import-header', span(class='num', '3'), h2('Load Data')),
  fluidRow(
    column(6,
      div(class='upload-button-container',
        tags$button(id='confirm_folders',
          class='btn btn-primary action-button shiny-bound-input',
          icon('file-upload'), 'Load Data')
      )
    ),
    column(6,
      wellPanel(
        div(class='well-header', h4('Status')),
        htmlOutput('data_status')
      )
    )
  ),
  
  
  ############################################
  ###  STEP 4: LOAD OTHER DATA (optional)  ###
  ############################################
  
  div(class='import-header', span(class='num', '4'), h2('Load Other Data (optional)')),
  fixedRow(column(12,
    uiOutput('misc_input_forms')
  ))
  
  
  #       wellPanel(
  #         div(class='well-header', h4('Raw File Renaming')),
  #         p("Enter a comma-separated list of short labels for each Raw-file/exp"),
  #         textInput("Exp_Names", "Exp Names", value = "", 
  #                   width = NULL, placeholder = "Comma-separated Exp Names")
  #       )

  # End tabs
  #p("After uploading your evidence.txt file, please wait for your experiments to appear in the sidebar before uploading msmsScans.txt and allPeptides.txt"),
  #p("You can then explore your data in the Dashboard."),
  #uiOutput('input_forms'),
  #tags$hr(),
  #p("Enter a comma-separated list of short labels for each Raw-file/exp"),
  #textInput("Exp_Names", "Exp Names", value = "", 
  #          width = NULL, placeholder = "Comma Sep Exp Names")
))