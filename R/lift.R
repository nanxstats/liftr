#' Containerize R Markdown Documents
#'
#' @description
#' Containerize R Markdown documents. This function generates
#' \code{Dockerfile} based on the liftr metadata in the RMD document.
#'
#' @details
#' After running \link{lift}, run \link{render_docker} on the document to
#' render the containerized R Markdown document using Docker containers.
#' See \code{vignette('liftr-intro')} for details about the extended
#' YAML front-matter metadata format used by liftr.
#'
#' @param input Input (R Markdown) file.
#' @param use_config If \code{TRUE}, will parse the liftr metadata from
#' a YAML file, if \code{FALSE}, will parse such information from the
#' metadata section in the R Markdown file. Default is \code{FALSE}.
#' @param config_file Name of the YAML configuration file, under the
#' same directory as the input file. Default is \code{"_liftr.yml"}.
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
#' \dontrun{
#' # render the document with Docker
#' render_docker(input)
#'
#' # view rendered document
#' browseURL(paste0(dir_example, "liftr-minimal.html"))
#'
#' # purge the generated Docker image
#' purge_image(paste0(dir_example, "liftr-minimal.docker.yml"))}

lift = function(
  input = NULL,
  use_config = FALSE, config_file = '_liftr.yml',
  output_dir = NULL) {

  if (is.null(input))
    stop('missing input file')
  if (!file.exists(normalizePath(input)))
    stop('input file does not exist')

  if (!use_config) {
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
    }

  if (use_config) {
    liftrfile_path = paste0(file_dir(input), '/', config_file)
    if (!file.exists(normalizePath(liftrfile_path)))
      stop('The YAML config file does not exist')
    opt_list = yaml.load_file(liftrfile_path)
  }

  # base image
  liftr_from       = parse_from(opt_list$from)
  # maintainer's name
  liftr_maintainer = parse_maintainer(opt_list$maintainer)
  # maintainer's email
  liftr_email      = parse_email(opt_list$email)
  # system dependencies
  liftr_sysdeps    = parse_sysdeps(opt_list$sysdeps)
  # texlive
  liftr_texlive    = parse_texlive(opt_list$texlive)
  # pandoc
  liftr_pandoc     = parse_pandoc(liftr_from, opt_list$pandoc)
  # CRAN packages
  liftr_cran       = parse_cran(opt_list$cran)
  # Bioconductor packages
  liftr_bioc       = parse_bioc(opt_list$bioc)
  # remote packages
  liftr_remotes    = parse_remotes(opt_list$remotes)
  # custom Dockerfile snippet
  liftr_include    = parse_include(input, opt_list$include)

  # factory packages
  liftr_factory = quote_str(c(
    'devtools', 'knitr', 'rmarkdown', 'shiny', 'RCurl'))

  # write output files
  if (is.null(output_dir)) output_dir = file_dir(input)
  output_dockerfile = paste0(normalizePath(output_dir), '/Dockerfile')

  invisible(knit(
    system.file('templates/base.Rmd', package = 'liftr'),
    output = output_dockerfile, quiet = TRUE))

  # remove consecutive blank lines
  out = readLines(output_dockerfile)
  out = sanitize_blank(out)
  writeLines(out, output_dockerfile)

  invisible(out)

    }
