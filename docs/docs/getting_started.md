---
layout: default
title: Getting Started
nav_order: 3
permalink: docs/getting-started
has_children: true
---

# Getting Started

DO-MS can be run either from the command-line or as interactive application. Follow the links below to get started using the implementation of your choice. For more details on the data display, read the [DO-MS 2.0 article](https://www.biorxiv.org/content/10.1101/2023.02.02.526809v1). 

Before starting DO-MS the first time, the input data type has to be selected. DO-MS can work with both DDA results coming from MaxQuant as well as with DIA results coming from DIA-NN.
The mode can be set in the config.yaml file. Open the file in R-Studio or your editor of choice.
![]({{site.baseurl}}/assets/images/do-ms-dia_mode.png){: width="70%" .center-image}

If You wish to analyze MaxQuant DDA results, change the parameter to `max_quant`, otherwise leave it as `dia-nn`. This setting needs to be changed before SO-MS is started or the R environment is initialized. It is also possible to keep both versionas in two separate folders simultanously.
![]({{site.baseurl}}/assets/images/do-ms-dia_config.png){: width="70%" .center-image}

# Generating DO-MS Reports
Please read our detailed getting started guides:

* [DIA Preprocessing]({{site.baseurl}}/docs/getting-started-preprocessing)
* [DIA Reports using the app]({{site.baseurl}}/docs/getting-started-dia-app)
* [DDA Reports using the app]({{site.baseurl}}/docs/getting-started-application)
* [DDA Reports using the command line]({{site.baseurl}}/docs/getting-started-application)