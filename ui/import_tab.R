# load import tab

file_vals <- names(config[['input_files']])
file_names <- lapply(config[['input_files']], function(i) {
  tags$div(class='input_file_choice',
    tags$span(i[['name']]),
    tags$button(class='btn btn-secondary tooltip-btn', 
                `data-toggle`='tooltip', `data-placement`='right', title=i[['help']],
                icon('question-sign', lib='glyphicon'))
  )
})
default_selected_files <- file_vals[
  sapply(config[['input_files']], function(i) { i$default_enabled })
]

# this list can't be named -- shiny will complain
names(file_names) <- NULL

import_tab <- tabItem(tabName='import', fluidPage(
  titlePanel('Import Data'),
  
  tags$ol(class='breadcrumb',
    tags$li(tags$a(href='#folder-select', '1. Select Folder(s)')),
    tags$li(tags$a(href='#load-data', '2. Load Data')),
    tags$li(tags$a(href='#upload-optional-data', '3. Upload Optional Data')),
    tags$li(tags$a(href='#rename-files', '4. Rename Files'))
  ),
  
  ################################
  ###  STEP 1: SELECT FOLDERS  ###
  ################################
  
  a(name='folder-select'),
  div(class='import-header', span(class='num', '1'), 
      h2(paste('Select', config[['mode_name']], 'Output Folders'))),
  p(class='import-help', 'Click on a row in the table to select that folder. Click multiple rows to select multiple folders, and use Shift to select a series of folders.'),
  fluidRow(
    column(9, wellPanel(
      div(class='well-header', h4('Folder List')),
      fixedRow(class='folder-button-list',
        actionButton('show_add_folder_modal', 'Add Folder to Table', icon=icon('plus')),
        actionButton('folder_select_all', 'Select All', icon=icon('th-list', lib='glyphicon')),
        actionButton('clear_folder_selection', 'Clear selection', icon=icon('eraser')),
        actionButton('delete_folders', 'Remove selected folders', icon=icon('trash'))
      ),
      DT::dataTableOutput('folder_table')
    )),
    column(3, wellPanel(
      div(class='well-header', h4('Status')),
      div(class='selected-folders-output',
        htmlOutput('selected_folders')
      ),
      p('Click on a row in the table to select that folder. Click multiple rows to select multiple folders, and use Shift to select a series of folders.'),
      p('Once you are finished selecting folders, scroll down to continue the import process.'),
      p(tags$a('Click here for help adding folders', href='https://github.com/SlavovLab/DO-MS/wiki/Adding-Folders', target='_blank'))
    ))
  ),
  
  ###########################
  ###  STEP 2: LOAD DATA  ###
  ###########################
  
  a(name='load-data'),
  div(class='import-header', span(class='num', '2'), 
      h2('Load Data')),
  p(class='import-help', 'Once folders are selected, click "Load Data" to import the files and begin the analysis. The status panel below to the right will update when the data is imported.'),
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
  
  
  ##############################################
  ###  STEP 3: UPLOAD OTHER DATA (optional)  ###
  ##############################################
  
  a(name='upload-optional-data'),
  div(class='import-header', span(class='num', '3'), 
      h2('Upload Other Data (optional)')),
  p(class='import-help', 'Upload other miscellaneous files, such as inclusion lists, individually.'),
  fixedRow(column(12,
    uiOutput('misc_input_forms')
  )),
  
  ###############################################
  ###  STEP 4: RENAME EXPERIMENTS (optional)  ###
  ###############################################
  
  a(name='rename-files'),
  div(class='import-header', span(class='num', '4'), 
      h2('Rename Experiments (optional)')),
  p('Rename raw file names to more readable or sensible names, for easier interpretation of figures'),
  wellPanel(
    div(class='well-header', h4('Raw File Renaming')),
    p('Choose a format to name experiments. Use flags to automatically name experiments from their metadata. Available flags are listed below'),
    tags$ul(
      tags$li(tags$b('%i'), tags$span('  Index of the experiment. i.e., "3"')),
      tags$li(tags$b('%f'), tags$span('  Name of the folder the experiment was loaded from.')),
      tags$li(tags$b('%e'), tags$span('  Name of the experiment raw file.'))
    ),
    p('For example, "file_%f-%i" would render to "file_SCOPE-3" given the folder "SCOPE" and the index 3'),
    fixedRow(style='display:flex;flex-direction:row;align-items:center;',
      column(9,
        textInput('exp_name_format', 'Experiment Label Format', value=config[['exp_name_format']],
                  width=NULL, placeholder='Experiment naming format')),
      column(3,
        actionButton('exp_name_format_apply', 'Apply', width=100))
    ),
    p('Further process file names after applying the format string with a string extraction pattern'),
    p('For example, a pattern "[0-9]{6}" would extract the first 6 sequential numbers in the experiment name.'),
    fixedRow(style='display:flex;flex-direction:row;align-items:center;',
      column(9,
        textInput('exp_name_pattern', 'Experiment Extraction Pattern', value=config[['exp_name_pattern']],
                  width=NULL, placeholder='Regular expression. e.g., [0-9]{6}')),
      column(3,
        actionButton('exp_name_pattern_apply', 'Apply', width=100))
    ),
    p('Or, use the table below to manually rename experiments'),
    p('Double click on an entry in the "Label" column to begin editing. Press enter or click outside of the table to finish editing and confirm the changes.'),
    DT::dataTableOutput('exp_name_table'),
    tags$br()
  )
))
