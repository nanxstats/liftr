# liftr

[![Build Status](https://travis-ci.org/road2stat/liftr.png?branch=master)](https://travis-ci.org/road2stat/liftr)

`liftr` extends the [R Markdown](http://rmarkdown.rstudio.com) metadata format, helps you generate `Dockerfile` for rendering documents in Docker containers. Users can also include and run pre-defined Rabix tools/workflows, then use Rabix output in their dockerized documents.

## Installation

To download and install `liftr` from CRAN, type the following commands in R:

```
install.packages("liftr")
```

Or, you can install the cutting-edge development version from GitHub:

```
# install.packages("devtools") if devtools was not installed
library("devtools")
install_github("road2stat/liftr")
```

To load the package in R, simply use

```
library("liftr")
```

and you are all set. See the package vignette `vignette("liftr-intro")` for a quick-start guide.
