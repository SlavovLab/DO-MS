# Adding Folders

Importing data in DO-MS is done by selecting one or more folders that correspond to the "txt" output from a MaxQuant search. The folder table starts out empty, and only when folders are added to the table can you select them for import and analysis.

Begin adding a folder by clicking on the "Add Folder" button above the folder table.

<img src="https://github.com/SlavovLab/DO-MS/raw/master/documentation/images/do-ms-add-folder-btn.png" height="150">

Then add the path of your folder into the textbox, as shown:

<img src="https://github.com/SlavovLab/DO-MS/raw/master/documentation/images/do-ms-enter-path.png" height="250">

A folder path is the folder's absolute location on your machine. On Windows, you can get the folder path by navigating to it in Explorer, clicking on the top file path bar, and copying the resulting text with Ctrl+C.

<img src="https://github.com/SlavovLab/DO-MS/raw/master/documentation/images/do-ms-windows-path-before.png" height="100">
<img src="https://github.com/SlavovLab/DO-MS/raw/master/documentation/images/do-ms-windows-path-after.png" height="100">

On Mac/OSX, you can get the folder path by first going into the folder info panel (Right click -> "Get Info", or Cmd+I) and then copying the path with Cmd+C.

<img src="https://github.com/SlavovLab/DO-MS/raw/master/documentation/images/do-ms-osx-folder-info.png" height="250">

## Adding subfolders

Instead of adding one folder at a time, you can select a parent folder and select either "Add Child Folders" or "Add Recursively". "Add Child Folders" only adds folders that are directly below the folder in the Folder Path textbox. "Add Recursively" adds *all* folders below the one specified, no matter how many levels below they are.

## Next Steps

Press the confirm button when you are finished entering in the folder path and optionally adding subfolders. The folder table should now populate with your selected folder(s). Click on a row or multiple rows to select them, and then scroll down to select file(s) and finally to start the import process.
