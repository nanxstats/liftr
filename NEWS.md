# CHANGES IN liftr VERSION 0.4 (2016-01-18)

## NEW FEATURES

* Added four RStudio addins as shortcuts to create, dockerize, and render
  R Markdown documents.

# CHANGES IN liftr VERSION 0.3 (2015-10-10)

## NEW FEATURES

* Support specifying CRAN package version precisely.

## IMPROVEMENTS

* Modified examples in documentation to comply with the lastest CRAN Repository Policy.
* Installing packages with https.

# CHANGES IN liftr VERSION 0.2 (2015-07-30)

## BUG FIXES

* [Correctly rendered](https://github.com/rstudio/rmarkdown/issues/470) the vignette with Pandoc 1.15.0.6.

## NEW FEATURES

* Added new R Markdown header option `pandoc` to control Pandoc installation. Automatically set this to `false` for `rocker/rstudio` and `bioconductor/...` images. This solves [issue #12](https://github.com/road2stat/liftr/issues/12).

# CHANGES IN liftr VERSION 0.1 (2015-07-10)

## NEW FEATURES

* Initial version of liftr. This version implemented two functions `lift()` and `drender()`. They provide basic support for dockerizing R Markdown documents, with support for running Rabix workflows/tools before rendering R Markdown documents in Docker containers.
