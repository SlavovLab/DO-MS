---
layout: default
title: Adding Search Engines
nav_order: 7
permalink: docs/other-search-engines
---

# Integrating Other Search Engines

This app was designed for and tested for MaxQuant >= 1.6.0.16. Much of the code is designed around the specific outputs from MaxQuant, such as the column names of the text output files, and the names of the files themselves (`evidence.txt`, `allPeptides.txt`, etc). In addition, the modules for this app are designed to take advantage of the features of MaxQuant outputs, such as the full-width at half-maximum of elution peaks outputted when selecting the "Calculate peak properties" option.

## Backwards Compatibility

We are aware that older versions of MaxQuant have different column headers for some of the outputs. We provide an editable list of column "aliases" (in `settings.yaml`) where users can map their column names to the ones used in DO-MS. For example, DO-MS references the raw file column with `Raw.file`. If your data has `Rawfile` instead, this can be mapped:

```yaml
aliases:
  'Raw.file':
    - Rawfile
```

**If you come across any discrepancies, please let the authors know by opening a GitHub issue.** We want this software to be as smooth as possible, and would like to build in backwards-compatibility into the app.

## Other search engines

Adapting the core module technology of this application to the output of other search engines can conceptually be carried out in two ways:

### Option 1: Convert output into MaxQuant-like files

If you like the current modules and would like to keep their current display and features, the quickest strategy is to convert your search engine's output into tab-delimited text that shares the same structure (i.e., column names) as MaxQuant's output. This can be done via. our column aliasing system as mentioned above, with a third-party converter, or your own.

Our application mainly uses six tab-delimited files from MaxQuant (for non-DIA searches):

1. `allPeptides`, which describes ions on the MS1 level
2. `msmsScans`, which describes MS2 scans
3. `msms`, which describes PSMs
4. `evidence`, which describes peptide-level data (combined PSMs)
5. `parameters`, which describes MaxQuant search parameters
6. `summary`, which summarizes search results per experiment

These files are defined in `settings.yaml`:

```yaml
input_files:
  evidence:
    name: 'evidence'
    file: 'evidence.txt'
    help: 'MaxQuant evidence.txt file'
    default_enabled: true
  msms:
    name: 'msms'
    file: 'msms.txt'
    help: 'MaxQuant msms.txt file'
    default_enabled: true
...
```

The base set of DO-MS modules reference MaxQuant files. As other search engines/pipelines have analogous files these definitions could be changed to accommodate that. Note that the column names also have to be taken into account.

### Option 2: Rewrite Modules

Very little of the static, server code is dependent on the MaxQuant names. The core dependencies are:

1. In `server.R`, much of the design around selecting, filtering on, and renaming raw files are hard-coded to recognize the "Raw.file" column of MaxQuant output. Simply ensure that your search engine output is outputting the raw file name in each file (most should), and then change the specific "Raw.file" reference in the server code.
2. In `global.R`, the four files as described in Option 1 above are hardcoded into a list that is then displayed on the import page and available to all of the modules. Simply change the definitions here to the files you want to load from your search engine. There is no limit here, and the only restriction is, as described in point 1, the presence of a raw file column in the text file.

All of the modules provided in the application here reference column names from MaxQuant output files and expect data in the form provided by MaxQuant. For other search engines, the column references may need to just be renamed, but for others they may need a major overhaul.

### Option 3: Write Your Own (recommended)

If the base set of DO-MS modules is not useful to your analysis anyways (metabolomics, direct infusion, or other MS-related experiments), then you can simply write your own modules around your own data. See the [building your own modules]({{site.baseurl}}/docs/build-your-own) page for more details.

## Help!

For assistance on performing the above points, please open an issue on our [GitHub issues page](https://github.com/SlavovLab/DO-MS/issues) to directly contact the developers.
