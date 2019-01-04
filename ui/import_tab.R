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
  
  tags$ol(class='breadcrumb',
    tags$li(tags$a(href='#folder-select', '1. Select Folder(s)')),
    tags$li(tags$a(href='#file-select', '2. Select File(s)')),
    tags$li(tags$a(href='#load-data', '3. Load Data')),
    tags$li(tags$a(href='#upload-optional-data', '4. Upload Optional Data')),
    tags$li(tags$a(href='#rename-files', '5. Rename Files'))
  ),
  
  ################################
  ###  STEP 1: SELECT FOLDERS  ###
  ################################
  
  a(name='folder-select'),
  div(class='import-header', span(class='num', '1'), 
      h2('Select MaxQuant txt Output Folders')),
  p(class='import-help', 'Click on a row in the table to select that folder. Click multiple rows to select multiple folders, and use Shift to select a series of folders.'),
  p(class='import-help', 'Please see ',
    a(href='https://github.com/SlavovLab/DO-MS/blob/master/documentation/adding_folders.pdf',
      target='_blank', 'this document'),
    ' for help adding folders to the table'),
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
        shinyDirButton('choose_folder', label='Add folder to table', title='Please select a folder'),
        p('For help adding directories, please view ', 
          a(href='https://github.com/SlavovLab/DO-MS/blob/master/documentation/adding_folders.pdf',
            target='_blank', 'this document')),
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
  
  a(name='file-select'),
  div(class='import-header', span(class='num', '2'), 
      h2('Select Files to Load')),
  p(class='import-help', 'The text files to load from each folder selected. Unselect large files, such as "allPeptides.txt", if you are not analyzing unidentified ions and want to speed up load times.'),
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
  
  a(name='load-data'),
  div(class='import-header', span(class='num', '3'), 
      h2('Load Data')),
  p(class='import-help', 'Once folders and files are selected, click "Load Data" to import the files and begin the analysis. The status panel below to the right will update when the data is imported.'),
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
        # div(class='selected-folders-output',
        #     htmlOutput('selected_folders')
        # ),
        htmlOutput('data_status')
      )
    )
  ),
  
  
  ##############################################
  ###  STEP 4: UPLOAD OTHER DATA (optional)  ###
  ##############################################
  
  a(name='upload-optional-data'),
  div(class='import-header', span(class='num', '4'), 
      h2('Upload Other Data (optional)')),
  p(class='import-help', 'Upload other miscellaneous files, such as inclusion lists, individually.'),
  fixedRow(column(12,
    uiOutput('misc_input_forms')
  )),
  
  ###############################################
  ###  STEP 5: RENAME EXPERIMENTS (optional)  ###
  ###############################################
  
  a(name='rename-files'),
  div(class='import-header', span(class='num', '5'), 
      h2('Rename Experiments (optional)')),
  p('Rename raw file names to more readable or sensible names, for easier interpretation of figures'),
  wellPanel(
    div(class='well-header', h4('Raw File Renaming')),
    p('Enter a comma-separated list of short labels for each raw file/experiment. By default raw files will be named "Exp1, Exp2, Exp3, ..."'),
    p('For example: "Control,Drug1,Drug2,Drug3,2xDrug1"'),
    textInput("Exp_Names", "Exp Names", value = "",
              width = NULL, placeholder = "Comma-separated Exp Names")
  )

  # End tabs
  #p("After uploading your evidence.txt file, please wait for your experiments to appear in the sidebar before uploading msmsScans.txt and allPeptides.txt"),
  #p("You can then explore your data in the Dashboard."),
  #uiOutput('input_forms'),
  #tags$hr(),
  #p("Enter a comma-separated list of short labels for each Raw-file/exp"),
  #textInput("Exp_Names", "Exp Names", value = "", 
  #          width = NULL, placeholder = "Comma Sep Exp Names")
))
