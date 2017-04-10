#' Containerize R Markdown Documents
#'
#' @description
#' Containerize R Markdown documents. This function generates
#' \code{Dockerfile} based on the liftr metadata in the RMD document.
#'
#' @details
#' After running \link{lift}, run \link{render_docker} on the document to
#' render the Dockerized R Markdown document using Docker containers.
#' See \code{vignette('liftr-intro')} for details about the extended
#' YAML front-matter metadata format used by liftr.
#'
#' @param input Input (R Markdown) file.
#' @param output_dir Directory to output \code{Dockerfile}.
#' If not provided, will be the same directory as \code{input}.
#'
#' @return \code{Dockerfile}.
#'
#' @export lift
#'
#' @importFrom knitr knit
#' @importFrom yaml yaml.load
#'
#' @examples
#' # copy example file
#' dir_example = paste0(tempdir(), '/liftr-minimal/')
#' dir.create(dir_example)
#' file.copy(system.file("examples/liftr-minimal.Rmd", package = "liftr"), dir_example)
#'
#' # containerization
#' input = paste0(dir_example, "liftr-minimal.Rmd")
#' lift(input)
#'
#' # view generated Dockerfile
#' readLines(paste0(dir_example, "Dockerfile"))
#'
#' \dontrun{
#' # render the document with Docker
#' render_docker(input)
#'
#' # view rendered document
#' browseURL(paste0(dir_example, "liftr-minimal.html"))
#'
#' # purge the generated Docker image
#' purge_image(paste0(dir_example, "liftr-minimal.docker.yml"))}

lift = function(input = NULL, output_dir = NULL) {

  if (is.null(input))
    stop('missing input file')
  if (!file.exists(normalizePath(input)))
    stop('input file does not exist')

  # locate YAML metadata block
  doc_content = readLines(normalizePath(input))
  header_pos = which(doc_content == '---')

  # handling YAML blocks ending with three dots
  if (length(header_pos) == 1L) {
    header_dot_pos = which(doc_content == '...')
    if (length(header_dot_pos) == 0L) {
      stop('Cannot correctly locate YAML metadata block.
           Please use three hyphens (---) as start line & end line,
           or three hyphens (---) as start line with three dots (...)
           as end line.')
    } else {
      header_pos[2L] = header_dot_pos[1L]
    }
  }

  doc_yaml = paste(
    doc_content[(header_pos[1L] + 1L):(header_pos[2L] - 1L)],
    collapse = '\n')
  opt_all_list = yaml.load(doc_yaml)

  # liftr options handling
  if (is.null(opt_all_list$liftr))
    stop('Cannot find `liftr` option in file header')

  opt_list = opt_all_list$liftr

  # base image
  liftr_from = if (!is.null(opt_list$from))
    opt_list$from else 'rocker/r-base:latest'

  # maintainer name
  if (!is.null(opt_list$maintainer)) {
    liftr_maintainer = opt_list$maintainer
  } else {
    stop('Cannot find `maintainer` option in file header')
  }

  if (!is.null(opt_list$maintainer_email)) {
    liftr_maintainer_email = opt_list$maintainer_email
  } else {
    stop('Cannot find field `maintainer_email` in header')
  }

  # system dependencies
  if (!is.null(opt_list$syslib)) {
    liftr_syslib = paste(
      readLines(system.file('templates/system-deps.Rmd', package = 'liftr')),
      paste(opt_list$syslib, collapse = ' '), sep = ' ')
  } else {
    liftr_syslib = NULL
  }

  # texlive
  if (!is.null(opt_list$latex)) {
    if (opt_list$latex == TRUE) {
      liftr_texlive = paste(
        readLines(system.file('templates/doc-texlive.Rmd', package = 'liftr')),
        collapse = '\n')
    } else {
      liftr_texlive = NULL
    }
  } else {
    liftr_texlive = NULL
  }

  # pandoc
  # this solves https://github.com/road2stat/liftr/issues/12
  if (is_from_bioc(liftr_from) | is_from_rstudio(liftr_from)) {
    liftr_pandoc = NULL
  } else {
    if (!is.null(opt_list$pandoc)) {
      if (opt_list$pandoc == FALSE) {
        liftr_pandoc = NULL
      } else {
        liftr_pandoc = paste(readLines(
          system.file('templates/doc-pandoc.Rmd', package = 'liftr')), collapse = '\n')
      }
    } else {
      liftr_pandoc = paste(readLines(
        system.file('templates/doc-pandoc.Rmd', package = 'liftr')), collapse = '\n')
    }
  }

  # Factory packages
  liftr_factorypkgs = c('devtools', 'knitr', 'rmarkdown', 'shiny', 'RCurl')
  liftr_factorypkg = quote_str(liftr_factorypkgs)

  # CRAN packages
  if (!is.null(opt_list$cranpkg)) {
    liftr_cranpkgs = quote_str(opt_list$cranpkg)
    tmp = tempfile()
    invisible(knit(
      input = system.file('templates/pkg-cran.Rmd', package = 'liftr'),
      output = tmp, quiet = TRUE))
    liftr_cranpkg = readLines(tmp)
  } else {
    liftr_cranpkg = NULL
  }

  # Bioconductor packages
  if (!is.null(opt_list$biocpkg)) {
    liftr_biocpkgs = quote_str(opt_list$biocpkg)
    tmp = tempfile()
    invisible(knit(
      input = system.file('templates/pkg-bioc.Rmd', package = 'liftr'),
      output = tmp, quiet = TRUE))
    liftr_biocpkg = readLines(tmp)
  } else {
    liftr_biocpkg = NULL
  }

  # GitHub packages
  if (!is.null(opt_list$ghpkg)) {
    liftr_ghpkgs = quote_str(opt_list$ghpkg)
    tmp = tempfile()
    invisible(knit(
      input = system.file('templates/pkg-github.Rmd', package = 'liftr'),
      output = tmp, quiet = TRUE))
    liftr_ghpkg = readLines(tmp)
  } else {
    liftr_ghpkg = NULL
  }

  # write output files
  if (is.null(output_dir)) output_dir = file_dir(input)

  invisible(knit(
    system.file('templates/base.Rmd', package = 'liftr'),
    output = paste0(normalizePath(output_dir), '/Dockerfile'),
    quiet = TRUE))

  }
