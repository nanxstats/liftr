# liftr  <a href="https://liftr.me"><img src="https://nanx.me/images/project-liftr.png" align="right" alt="logo" height="180" width="180" /></a>

[![Build Status](https://travis-ci.org/road2stat/liftr.svg?branch=master)](https://travis-ci.org/road2stat/liftr)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/road2stat/liftr?branch=master&svg=true)](https://ci.appveyor.com/project/road2stat/liftr)
[![CRAN Version](https://www.r-pkg.org/badges/version/liftr)](https://cran.r-project.org/package=liftr)
[![Downloads from the RStudio CRAN mirror](https://cranlogs.r-pkg.org/badges/liftr)](https://cranlogs.r-pkg.org/badges/liftr)

liftr aims to solve the problem of _persistent reproducible reporting_. To achieve this goal, it extends the [R Markdown](http://rmarkdown.rstudio.com) metadata format, and uses [Docker](https://www.docker.com) to containerize and render R Markdown documents.

## Installation

To download and install `liftr` from CRAN:

```r
install.packages("liftr")
```

Or try the development version on GitHub:

```r
# install.packages("devtools")
devtools::install_github("road2stat/liftr")
```

See the [package vignette](https://cran.r-project.org/web/packages/liftr/vignettes/liftr-intro.html) (can also be opened with `vignette("liftr-intro")` in R) for a quick-start guide.

## Video Demo

<a href="https://vimeo.com/212438526"><img src="https://i.imgur.com/VYCiOPu.png" width="100%" alt="Dockerize and Render R Markdown Documents with liftr"></a>
