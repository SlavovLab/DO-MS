---
layout: default
title: Adding Input Folders
nav_order: 6
permalink: docs/adding-folders
---

# Adding Input Folders

Importing data in DO-MS is done by selecting one or more folders that correspond to the "txt" output from a MaxQuant search. The folder table starts out empty, and only when folders are added to the table can you select them for import and analysis.

Begin adding a folder by clicking on the "Add Folder" button above the folder table.

![]({{site.baseurl}}/assets/images/do-ms-add-folder-btn.png){:width="70%" .center-image}

Then add the path of your folder into the textbox, as shown:

![]({{site.baseurl}}/assets/images/do-ms-enter-path.png){:width="70%" .center-image}

A folder path is the folder's absolute location on your machine. On Windows, you can get the folder path by navigating to it in Explorer, clicking on the top file path bar, and copying the resulting text with Ctrl+C.

![]({{site.baseurl}}/assets/images/do-ms-windows-path-before.png){: width="70%" .center-image}

![]({{site.baseurl}}/assets/images/do-ms-windows-path-after.png){: width="70%" .center-image}

On Mac/OSX, you can get the folder path by right clicking on the folder at the bottom of the Finder application and hitting "Copy \<folder\> as pathname".

![]({{site.baseurl}}/assets/images/do-ms-osx-path-before.png){: width="60%" .center-image}

![]({{site.baseurl}}/assets/images/do-ms-osx-path-after.png){: width="60%" .center-image}

Paths must be absolute and start from the root of the filesystem. For Windows, this means starting from the disk ("C:\\", "D:\\", etc). For Mac OS/Linux, this means starting from the filesystem root ("/"). Also note that path separators are platform specific ("\\" for Windows, "/" for Mac OS/Linux)

## Adding subfolders

Instead of adding one folder at a time, you can select a parent folder and select either "Add Child Folders" or "Add Recursively". 

"Add Child Folders" only adds folders that are directly below the folder in the Folder Path textbox. 

"Add Recursively" adds *all* folders below the one specified, no matter how many levels below they are.

## Next Steps

Press the confirm button when you are finished entering in the folder path and optionally adding subfolders. The folder table should now populate with your selected folder(s). Click on a row or multiple rows to select them, and then scroll down to select file(s) and finally to start the import process.