# liftr

[![Build Status](https://travis-ci.org/road2stat/liftr.png?branch=master)](https://travis-ci.org/road2stat/liftr)
[![Coverage Status](https://coveralls.io/repos/road2stat/liftr/badge.svg?branch=master&service=github)](https://coveralls.io/github/road2stat/liftr?branch=master)
[![Downloads from the RStudio CRAN mirror](http://cranlogs.r-pkg.org/badges/liftr)](http://cran.rstudio.com/package=liftr)

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

and you are all set. See [the vignette](https://cran.r-project.org/web/packages/liftr/vignettes/liftr-intro.html) (can also be opened with `vignette("liftr-intro")` in R) for a quick-start guide.
