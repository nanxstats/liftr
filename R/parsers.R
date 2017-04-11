parse_from = function(from)
  if (!is.null(from)) from else 'rocker/r-base:latest'

parse_maintainer = function(maintainer)
  if (!is.null(maintainer)) maintainer else
    stop('Cannot find `maintainer` in header')

parse_email = function(email)
  if (!is.null(email)) email else stop('Cannot find `email` in header')

parse_sysdeps = function(sysdeps) {
  if (!is.null(sysdeps))
    paste(readLines(system.file(
      'templates/system-deps.Rmd', package = 'liftr')),
      paste(sysdeps, collapse = ' '), sep = ' ') else NULL
}

parse_texlive = function(texlive) {
  if (!is.null(texlive)) {
    if (texlive == TRUE) paste(
      readLines(system.file(
        'templates/doc-texlive.Rmd', package = 'liftr')),
      collapse = '\n') else NULL
  } else {
    NULL
  }
}

# this solves https://github.com/road2stat/liftr/issues/12
parse_pandoc = function(liftr_from, pandoc) {
  if (is_from_bioc(liftr_from) | is_from_rstudio(liftr_from)) {
    NULL
  } else {
    if (!is.null(pandoc)) {
      if (pandoc == FALSE) {
        NULL
      } else {
        paste(readLines(system.file(
          'templates/doc-pandoc.Rmd', package = 'liftr')), collapse = '\n')
      }
    } else {
      paste(readLines(system.file(
        'templates/doc-pandoc.Rmd', package = 'liftr')), collapse = '\n')
    }
  }
}

parse_cran = function(cran) {
  if (!is.null(cran)) {
    liftr_cran = quote_str(cran)
    tmp = tempfile()
    invisible(knit(
      input = system.file(
        'templates/pkg-cran.Rmd', package = 'liftr'),
      output = tmp, quiet = TRUE))
    liftr_cran = readLines(tmp)
    liftr_cran
  } else {
    NULL
  }
}

parse_bioc = function(bioc) {
  if (!is.null(bioc)) {
    liftr_bioc = quote_str(bioc)
    tmp = tempfile()
    invisible(knit(
      input = system.file(
        'templates/pkg-bioc.Rmd', package = 'liftr'),
      output = tmp, quiet = TRUE))
    liftr_bioc = readLines(tmp)
    liftr_bioc
  } else {
    NULL
  }
}

parse_remotes = function(remotes) {
  if (!is.null(remotes)) {
    liftr_remotes = quote_str(remotes)
    tmp = tempfile()
    invisible(knit(
      input = system.file(
        'templates/pkg-remotes.Rmd', package = 'liftr'),
      output = tmp, quiet = TRUE))
    liftr_remotes = readLines(tmp)
    liftr_remotes
  } else {
    NULL
  }
}

parse_include = function(input, include) {
  if (!is.null(include)) {
    include_file_path = normalizePath(
      paste0(file_dir(input), '/', include))
    if (!file.exists(include_file_path))
      stop('include file does not exist')
    paste(readLines(include_file_path), collapse = '\n')
  } else {
    NULL
  }
}
