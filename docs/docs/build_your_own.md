---
layout: default
title: Building Your Own Modules
nav_order: 5
permalink: docs/build-your-own
---

# Building your own modules

DO-MS is designed to allow easy customization to in-house proteomics workflows through a modular plotting and data display system. Modules are a type of data display, such as plots, tables, and text. 

Write your code once in the module format, apply it automatically to different datasets, and get consistent data display through the web interface or generated reports.

**Table of Contents**

* [Tabs](#tabs)
    * [Tab Organization](#tab-organization)
    * [Removing Tabs](#removing-tabs)
* [Modules](#modules)
    * [Module Organization](#module-organization)
    * [Removing Modules](#removing-modules)
* [Module Types](#module-types)
    * [plot](#plot)
    * [table](#table)
    * [datatable](#datatable)
    * [text](#text)
* [Module Structure](#module-structure)
    * [Metadata Fields](#metadata-fields)
    * [Functions](#functions)
    * [Additional Options (Web Interface)](#additional-options-web-interface)
    * [Additional Options (Plot Type)](#additional-options-plot-type)
    * [Additional Options (Datatable Type)](#additional-options-datatable-type)

-----------

## Tabs

Modules are organized and grouped together through tabs, which are named folders under the ```modules/``` folder.

```bash
$ ls modules
005_Summary  
010_Chromatography  
020_Instrument_Performance  
...
```

### Tab Organization

Tabs are sorted alphabetically, so numerical prefixes to folder names allow for custom ordering of tabs, as done with the base set of tabs. When displaying the tab name in the interface/report, numerical prefixes are removed and the `_` character is replaced with a space.

### Removing Tabs

Deleting the tab folder will remove the tab and all of its child modules. Tabs can be "commented out" by appending the folder name with two underscores, like so: `__090_Hidden_Tab/`.

----------

## Modules

Each module is its own `.R` file inside of a tab. The contents of the module are described below, and annotated, example modules can be found in the `examples/` folder. You can also use the base set of modules as a reference to build your own.

### Module Organization

Modules are displayed alphabetically in both the web interface and report. Numerical prefixes to the module file name allow for custom ordering, in the same system for tabs described above. Unlike tabs, module names are specified inside the file and are not derived from the file name.

### Removing Modules

Deleting a module will remove it. If you want to keep it without displaying it, you can "comment out" similar to tabs, by appending the module file name with two underscores like so: ```__hide_this_module.R```


-----------



## Module Types

Modules can render into a variety of display types. Current options are listed below, but more are upcoming.

### `plot`

Render a plot image. The plot function should return a `ggplot` object or a vanilla R plot object recorded with the `recordPlot()` function.

### `table`

Render a static table. The plot function should return a matrix or datatable

### `datatable`

The same as the `table` type, except in the web interface and HTML report this table is displayed as a `DataTable` which allows searching, reordering, etc. More details on DataTables can be found here [https://datatables.net/reference/index](https://datatables.net/reference/index).


### `text`

Render a string. The plot function should return a string. Newlines should be done with two newline characters (`\n\n`) instead of one for proper display.

------------


## Module Structure

Each module file specifies a function `init()` that takes in no arguments, and returns a list that provides both metadata about the module and function definitions that give the module its functionality.

### Metadata Fields

##### `type`

Module type, as described above.

##### `box_title`

The name of the module, as displayed on the web interface and report

##### `help_text`

Description of the module, shown in the web interface and documentation tab

##### `source_file`

Description of the file(s) used for this module, displayed in the documentation tab

### Functions

##### `validate_func(data, input)`

Function to validate whether or not the data required for this module is loaded. All implementations use `shiny`'s `validate` function internally.

##### `plotdata_func(data, input)`

Function to generate filtered and modified data to be used for display. Returns data, usually in tabular form. This is the data that will be given to the user when clicking the "Download Data" button in the interface

##### `plot_func(data, input)`

Function to generate a display object (plot, table, text) from the `plotdata` function.

### Additional Options (web interface)

##### `box_width`

Width of the box in bootstrap column units (1-12, where 12 is the full page width).

##### `box_height`

Height of the box in pixels. By default the box height is the height of the plot object, or 400px if the display type is not a plot.

### Additional Options (plot type)

##### `dynamic_width`

Value, in pixels, of the width of each experiment in the plot. For plots such as the vertical histograms used in the base set of DO-MS plots need to scale horizontally with the number of experiments.

##### `dynamic_width_base`

Value, in pixels, of the base width of a plot using the dynamic width. Useful for plots with elements taking up a fixed amount of horizontal space -- e.g., legends.

##### `plot_height`

Height, in pixels, of the plot. Default is 370px. Will also scale the box height, unless it is also user-defined.

##### `report_plot_width`

Width, in inches, of the plot in the generated report. Defaults to a global report plot width, which is by default 5 inches.

##### `report_plot_height`

Height, in inches, of the plot in the generated report. Defaults to a global report plot height, which is by default 5 inches.


### Additional Options (datatable type)

##### `datatable_options`

A list of parameters to pass to DataTables. For example:

```R
datatable_options=list(
  pageLength=10,
  dom='lfptp',
  lengthMenu=c(5, 10, 15, 20, 50)
)
```

More details can be found in the R `DT` interface, [https://rstudio.github.io/DT/](https://rstudio.github.io/DT/) and on the DataTables reference page [https://datatables.net/reference/option/](https://datatables.net/reference/option/).



