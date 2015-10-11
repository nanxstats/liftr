#' Dockerize R Markdown Documents
#'
#' Generate \code{Dockerfile} for R Markdown documents.
#' Rabix is supported if there is certain metadata in the R Markdown
#' document: the function will generate a \code{Rabixfile} containing
#' the parsed running parameters under the output directory.
#'
#' After running \link{lift}, run \link{drender} on the document to
#' render the Dockerized R Markdown document using Docker containers.
#' See \code{vignette('liftr-intro')} for details about the extended
#' YAML front-matter metadata format used by liftr.
#'
#' @param input Input (R Markdown) file.
#' @param output_dir Directory to output \code{Dockerfile}.
#' If not provided, will be the same directory as \code{input}.
#'
#' @return \code{Dockerfile} (and \code{Rabixfile} if possible).
#'
#' @export lift
#'
#' @importFrom knitr knit
#' @importFrom yaml yaml.load
#'
#' @examples
#' # 1. Dockerized R Markdown document
#' dir_docker = paste0(tempdir(), '/lift_docker/')
#' dir.create(dir_docker)
#' file.copy(system.file("docker.Rmd", package = "liftr"), dir_docker)
#' # use lift() to parse Rmd and generate Dockerfile
#' lift(paste0(dir_docker, "docker.Rmd"))
#' # view generated Dockerfile
#' readLines(paste0(dir_docker, "Dockerfile"))
#'
#' # 2. Dockerized R Markdown document with Rabix options
#' dir_rabix = paste0(tempdir(), '/lift_rabix/')
#' dir.create(dir_rabix)
#' file.copy(system.file("rabix.Rmd", package = "liftr"), dir_rabix)
#' lift(input = paste0(dir_rabix, "rabix.Rmd"))
#' # view generated Dockerfile
#' readLines(paste0(dir_rabix, "Dockerfile"))
#' # view generated Rabixfile
#' readLines(paste0(dir_rabix, "Rabixfile"))
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

  doc_yaml = paste(doc_content[(header_pos[1L] + 1L):
                                 (header_pos[2L] - 1L)],
                   collapse = '\n')
  opt_all_list = yaml.load(doc_yaml)

  # liftr options handling
  if (is.null(opt_all_list$liftr))
    stop('Cannot find `liftr` option in file header')

  opt_list = opt_all_list$liftr

  # base image
  if (!is.null(opt_list$from)) {
    liftr_from = opt_list$from
  } else {
    liftr_from = 'rocker/r-base:latest'
  }

  # maintainer name
  if (!is.null(opt_list$maintainer)) {
    liftr_maintainer = opt_list$maintainer
  } else {
    stop('Cannot find `maintainer` option in file header')
  }

  if (!is.null(opt_list$maintainer_email)) {
    liftr_maintainer_email = opt_list$maintainer_email
  } else {
    stop('Cannot find `maintainer_email` option in file header')
  }

  # system dependencies
  if (!is.null(opt_list$syslib)) {
    liftr_syslib =
      paste(readLines(system.file('syslib.Rmd', package = 'liftr')),
            paste(opt_list$syslib, collapse = ' '), sep = ' ')
  } else {
    liftr_syslib = NULL
  }

  # texlive
  if (!is.null(opt_list$latex)) {
    if (opt_list$latex == TRUE) {
      liftr_texlive =
        paste(readLines(system.file('texlive.Rmd', package = 'liftr')),
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
          system.file('pandoc.Rmd', package = 'liftr')), collapse = '\n')
      }
    } else {
      liftr_pandoc = paste(readLines(
        system.file('pandoc.Rmd', package = 'liftr')), collapse = '\n')
    }
  }

  # Factory packages
  liftr_factorypkgs = c('devtools', 'knitr', 'rmarkdown', 'shiny', 'RCurl')
  liftr_factorypkg = quote_str(liftr_factorypkgs)

  # CRAN packages
  if (!is.null(opt_list$cranpkg)) {
    liftr_cranpkgs = quote_str(opt_list$cranpkg)
    tmp = tempfile()
    invisible(knit(input = system.file('cranpkg.Rmd', package = 'liftr'),
                   output = tmp, quiet = TRUE))
    liftr_cranpkg = readLines(tmp)
  } else {
    liftr_cranpkg = NULL
  }

  # Bioconductor packages
  if (!is.null(opt_list$biocpkg)) {
    liftr_biocpkgs = quote_str(opt_list$biocpkg)
    tmp = tempfile()
    invisible(knit(input = system.file('biocpkg.Rmd', package = 'liftr'),
                   output = tmp, quiet = TRUE))
    liftr_biocpkg = readLines(tmp)
  } else {
    liftr_biocpkg = NULL
  }

  # GitHub packages
  if (!is.null(opt_list$ghpkg)) {
    liftr_ghpkgs = quote_str(opt_list$ghpkg)
    tmp = tempfile()
    invisible(knit(input = system.file('ghpkg.Rmd', package = 'liftr'),
                   output = tmp,
                   quiet = TRUE))
    liftr_ghpkg = readLines(tmp)
  } else {
    liftr_ghpkg = NULL
  }

  # write Dockerfile
  if (is.null(output_dir)) output_dir = file_dir(input)

  invisible(knit(system.file('Dockerfile.Rmd',
                             package = 'liftr'),
                 output = paste0(normalizePath(output_dir),
                                 '/Dockerfile'),
                 quiet = TRUE))

  # handling rabix info
  if (!is.null(opt_list$rabix)) {
    if (opt_list$rabix == TRUE) {

      if (is.null(opt_list$rabix_d))
        stop('Cannot find `rabix_d` option in file header')

      liftr_rabix_d = paste0('\"', normalizePath(opt_list$rabix_d,
                                                 mustWork = FALSE), '\"')

      if (is.null(opt_list$rabix_json))
        stop('Cannot find `rabix_json` option in file header')

      liftr_rabix_json = paste0('\"', opt_list$rabix_json, '\"')

      if (!is.null(opt_list$rabix_args)) {

        liftr_rabix_with_args = '-- '
        rabix_args_vec = unlist(opt_list$rabix_args)
        liftr_rabix_args =
          paste(paste0('--', paste(names(rabix_args_vec),
                                   rabix_args_vec)),
                collapse = ' ')
      } else {
        liftr_rabix_with_args = NULL
        liftr_rabix_args = NULL
      }

      invisible(knit(system.file('Rabixfile.Rmd',
                                 package = 'liftr'),
                     output = paste0(normalizePath(output_dir),
                                     '/Rabixfile'),
                     quiet = TRUE))

    }
  }

}
