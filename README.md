# liftr  <a href="https://liftr.me"><img src="https://i.imgur.com/3SCYZu0.png" align="right" alt="logo" height="180" width="180" /></a>

[![Build Status](https://travis-ci.org/road2stat/liftr.svg?branch=master)](https://travis-ci.org/road2stat/liftr)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/road2stat/liftr?branch=master&svg=true)](https://ci.appveyor.com/project/road2stat/liftr)
[![CRAN Version](https://www.r-pkg.org/badges/version/liftr)](https://cran.r-project.org/package=liftr)
[![Downloads from the RStudio CRAN mirror](https://cranlogs.r-pkg.org/badges/liftr)](https://cran.r-project.org/package=liftr)

liftr aims to solve the problem of _persistent reproducible reporting_.
To achieve this goal, it extends the [R Markdown](http://rmarkdown.rstudio.com)
metadata format, and uses Docker to containerize and render R Markdown documents.

## Installation

Install liftr from CRAN:

```r
install.packages("liftr")
```

Or try the development version on GitHub:

```r
# install.packages("devtools")
devtools::install_github("road2stat/liftr")
```

[Browse the vignettes](https://liftr.me/articles/) or the [demo video](https://vimeo.com/212815497) for a quick-start.

## Workflow

<img src="https://i.imgur.com/AKveypK.png" width="100%" alt="Containerize R Markdown Documents with liftr">

## Events

| Time            | Event                   | Location                         |
|:----------------|:------------------------|:---------------------------------|
| May 20, 2017 | [The 10th China-R Conference](http://china-r.org/) (talk) | Tsinghua University, Beijng, China |
| April 18, 2017 | [DockerCon 2017](http://2017.dockercon.com/) (talk) | Austin Convention Center, Austin, TX |
| December 3, 2015 | [CRI Bioinformatics Workshop](http://learn.cri.uchicago.edu/2015-cri-bioinformatics-workshop/) (talk) | The University of Chicago, Chicago, IL |
| July 21, 2015 | [BioC 2015](https://bioconductor.org/help/course-materials/2015/BioC2015/) (workshop) | Fred Hutchinson Cancer Research Center, Seattle, WA |

## License

liftr is free and open source software, licensed under GPL-3.
