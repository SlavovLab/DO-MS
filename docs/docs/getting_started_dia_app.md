---
layout: default
title: DIA Reports in the App
nav_order: 2
permalink: docs/getting-started-dia-app
parent: Getting Started
---

# Getting Started -- DIA Reports in the App

DO-MS is an application to visualize mass-spec data both in an interactive application and static reports generated via. the command-line. In this document we'll walk you through analyzing an example dataset in the interactive application.

**Table of Contents**

1. [Example Data](#example-data)
2. [Installation](#installation)
3. [Data Import](#data-import)
    1. [Adding Folders](#adding-folders)
    2. [Renaming Experiments](#renaming-experiments)
4. [Interacting with Modules](#interacting-with-modules)
5. [Generate Report](#generate-report)



## Example Data

We have provided an example data set online, which contains parts of the MS2 number optimization in the paper. This data can also be obtained by follwoing the guide on the preprocessing or can be downloaded as a zip file here: [https://drive.google.com/file/d/1BzWVKghIThtgYItgGy9vt6M214mHB74q/view?usp=share_link](https://drive.google.com/file/d/1BzWVKghIThtgYItgGy9vt6M214mHB74q/view?usp=share_link).


![]({{site.baseurl}}/assets/images/do-ms-dia-example.png){: width="70%" .center-image}

## Installation

Please make sure that you installed DO-MS as descibed in the [installation]({{site.baseurl}}/docs/installation) section. 


## Data Import
<span style="color:red">Make sure DO-MS has been configured for DIA-NN data. [Find out More]({{site.baseurl}}/docs/getting-started)</span> 

![]({{site.baseurl}}/assets/images/do-ms-dia-overview.png){: width="90%" .center-image}

### Adding Folders

DO-MS is designed to load _folders_ of analyses rather than individual files. To allow quick access to your analyses, as well as to allow analyzing multiple searches simultaneously, DO-MS provides a searchable "folder table" for all of your analyses. We will start loading the folder with the example output.

Start by clicking the "Add Folder" button at the top of the table

![]({{site.baseurl}}/assets/images/do-ms-dia-import.png){: width="70%" .center-image}

Then add the path of your folder into the textbox, as shown:

![]({{site.baseurl}}/assets/images/do-ms-dia-foldername.png){: width="70%" .center-image}

A folder path is the folder's absolute location on your machine. On Windows, you can get the folder path by navigating to it in Explorer, clicking on the top file path bar, and copying the resulting text with Ctrl+C. On Mac/OSX, you can get the folder path by right clicking on the folder while presing the 'option' key.

![]({{site.baseurl}}/assets/images/do-ms-dia-pathname.png){: width="70%" .center-image}

Note that in the example above we checked "Add Single Folder" to add just the folder path we pasted in. If for example, you have a folder that contains many MaxQuant searches, you can select "Add Child Folders" to add all subfolders of the path specified, or "Add Recursively" to add _all_ folders that are below the path specified.

Click "Confirm" and now you should see your folder added to the folder table. When you have multiple folders loaded into the table you can select more than one.

![]({{site.baseurl}}/assets/images/do-ms-dia-load.png){: width="70%" .center-image}

Finally, load the files from the selected folders by scrolling down and clicking on the big "Load Data" button

### Renaming Experiments

An important aspect of data visualization is easy-to-read labels for your experiments. DO-MS provides an accessible interface for renaming your raw file names so that generated figures will be easier to interpret.

Once your data is loaded, scroll down to the "Renaming Experiments" section. Here you will find a table of your loaded raw files and their associated "labels" that will be used when plotting. Double click a label and type enter the new labe:

![]({{site.baseurl}}/assets/images/do-ms-dia-rename.png){: width="100%" .center-image}

Please rename all experiments as following:

```
wGW027 => 4 MS2
wGW028 => 8 MS2
wGW029 => 10 MS2
```

## Interacting with Modules

Each module has a short description that can be accessed by hovering over the question mark icon next to the module title.

![]({{site.baseurl}}/assets/images/do-ms-dia-info.png){: width="70%" .center-image}

You can also download the module plot as a PNG or PDF, by clicking on the download buttons below each module plot. You can also download the underlying data used for the plot by clicking on the "Download Data" button. This tab-delimited file can be imported into many other visualization packages.

## Generate Report

Click on "Generate Report" in the sidebar to access the report generation page.

![]({{site.baseurl}}/assets/images/do-ms-dia-generate-report.png){: width="70%" .center-image}

Here you will find some options to customize your report. While we support PDF reports and PDF images, we strongly recommend that you generate your reports in HTML format with PNG image plots. Other configurations may result in graphical glitches or unwanted behavior. In addition we recommend that you check your `pandoc` installation ([more details here]({{site.baseurl}}/docs/known-issues#pandoc-not-found)) as any issues will prevent the report generation.

Click the "Download Report" button to begin generating the report. This takes a while as all plots have to be remade. A progress bar at the bottom of the page informs you of the progress.

All images in the report are embedded in the markup, so feel free to share this single file to your colleagues/collaborators and don't worry about having to include anything else.