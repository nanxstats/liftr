# liftr  <a href="https://nanx.me/liftr/"><img src="https://i.imgur.com/3SCYZu0.png" align="right" alt="logo" height="180" width="180" /></a>

[![Build Status](https://travis-ci.org/nanxstats/liftr.svg?branch=master)](https://travis-ci.org/nanxstats/liftr)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/nanxstats/liftr?branch=master&svg=true)](https://ci.appveyor.com/project/nanxstats/liftr)
[![CRAN Version](https://www.r-pkg.org/badges/version/liftr)](https://cran.r-project.org/package=liftr)
[![Downloads from the RStudio CRAN mirror](https://cranlogs.r-pkg.org/badges/liftr)](https://cran.r-project.org/package=liftr)

liftr aims to solve the problem of _persistent reproducible reporting_.
To achieve this goal, it extends the [R Markdown](https://rmarkdown.rstudio.com)
metadata format, and uses Docker to containerize and render R Markdown documents.

## Paper

To cite this work and the related software, please use

Nüst D, Eddelbuettel D, Bennett D et al. (2020). [The Rockerverse: Packages and Applications for Containerisation with R](https://doi.org/10.32614/RJ-2020-007). _The R Journal_ 12 (1), 437-461.

## Installation

Install liftr from CRAN:

```r
install.packages("liftr")
```

Or try the development version on GitHub:

```r
remotes::install_github("nanxstats/liftr")
```

[Browse the vignettes](https://nanx.me/liftr/articles/) or the [demo video](https://vimeo.com/212815497) for a quick-start.

## Workflow

<img src="https://i.imgur.com/AKveypK.png" width="100%" alt="Containerize R Markdown Documents with liftr">

## Events

| Time            | Event                   | Location                         |
|:----------------|:------------------------|:---------------------------------|
| July 30, 2018 | [JSM 2018](https://ww2.amstat.org/meetings/JSM/2018/onlineprogram/AbstractDetails.cfm?abstractid=329348) ([talk](https://nanx.me/talks/jsm2018-liftr-nanxiao.pdf)) | Vancouver, Canada |
| July 27, 2017 | [BioC 2017](https://bioconductor.org/help/course-materials/2017/BioC2017/) ([poster](https://nanx.me/posters/dockflow-poster-bioc2017.pdf) for [dockflow.org](https://dockflow.org/)) | Dana-Farber Cancer Institute, Boston, MA |
| May 20, 2017 | [The 10th China-R Conference](https://china-r.org) ([talk](https://nanx.me/talks/chinar2017-liftr-nanxiao.pdf)) | Tsinghua University, Beijng, China |
| April 18, 2017 | DockerCon 2017 ([talk](https://nanx.me/talks/dockercon2017-liftr-nanxiao.pdf)) | Austin Convention Center, Austin, TX |
| December 3, 2015 | [CRI Bioinformatics Workshop](https://learn.cri.uchicago.edu/2015-cri-bioinformatics-workshop/) ([talk](https://nanx.me/talks/cri2015-reproducible-research-nanxiao.pdf)) | The University of Chicago, Chicago, IL |
| July 21, 2015 | [BioC 2015](https://bioconductor.org/help/course-materials/2015/BioC2015/) ([workshop](https://www.bioconductor.org/help/course-materials/2015/BioC2015/bioc2015-workshop-nanxiao.pdf)) | Fred Hutchinson Cancer Research Center, Seattle, WA |

## Contribute

To contribute to this project, please take a look at the [Contributing Guidelines](https://github.com/nanxstats/liftr/blob/master/CONTRIBUTING.md) first. Please note that this project is released with a [Contributor Code of Conduct](https://github.com/nanxstats/liftr/blob/master/CONDUCT.md). By participating in this project you agree to abide by its terms.

## License

liftr is free and open source software, licensed under GPL-3.
