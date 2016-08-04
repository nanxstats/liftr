# liftr

[![Build Status](https://travis-ci.org/road2stat/liftr.svg?branch=master)](https://travis-ci.org/road2stat/liftr)
[![CRAN Version](http://www.r-pkg.org/badges/version/liftr)](https://cran.r-project.org/package=liftr)
[![Downloads from the RStudio CRAN mirror](http://cranlogs.r-pkg.org/badges/liftr)](http://cranlogs.r-pkg.org/badges/liftr)

`liftr` extends the [R Markdown](http://rmarkdown.rstudio.com) metadata format, helps you generate `Dockerfile` for rendering documents in Docker containers. Users can also include and run pre-defined [Rabix](https://www.rabix.org) tools/workflows, then use Rabix output in their dockerized documents.

## Installation

To download and install `liftr` from CRAN:

```r
install.packages("liftr")
```

Or, you can try the development version on GitHub:

```r
# install.packages("devtools")
devtools::install_github("road2stat/liftr")
```

To load the package in R, simply use

```r
library("liftr")
```

and you are all set. See the [package vignette](https://cran.r-project.org/web/packages/liftr/vignettes/liftr-intro.html) (can also be opened with `vignette("liftr-intro")` in R) for a quick-start guide.
