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
#' @param input Input (R Markdown) file or shiny app folder.
#' @param output_dir Directory to output \code{Dockerfile}.
#' If not provided, will be the same directory as \code{input}.
#' @param ... Extra arguments passed to liftShinyApp function.
#'
#' @return \code{Dockerfile} (and \code{Rabixfile} if possible).
#'
#' @export lift
#'
#' @importFrom knitr knit
#' @importFrom yaml yaml.load as.yaml
#'
#' @examples
#' # 1. Dockerized R Markdown document
#' dir_docker = paste0(tempdir(), '/lift_docker/')
#' dir.create(dir_docker)
#' file.copy(system.file("examples/docker.Rmd", package = "liftr"), dir_docker)
#' # use lift() to parse Rmd and generate Dockerfile
#' lift(paste0(dir_docker, "docker.Rmd"))
#' # view generated Dockerfile
#' readLines(paste0(dir_docker, "Dockerfile"))
#'
#' # 2. Dockerized R Markdown document with Rabix options
#' dir_rabix = paste0(tempdir(), '/lift_rabix/')
#' dir.create(dir_rabix)
#' file.copy(system.file("template/rabix.Rmd", package = "liftr"), dir_rabix)
#' lift(input = paste0(dir_rabix, "rabix.Rmd"))
#' # view generated Dockerfile
#' readLines(paste0(dir_rabix, "Dockerfile"))
#' # view generated Rabixfile
#' readLines(paste0(dir_rabix, "Rabixfile"))
lift = function(input = NULL, output_dir = NULL, ...) {

  if (is.null(input))
    stop('missing input file')
  if(!is.na(file.info(input)$isdir) && file.info(input)$isdir){
    message("input is folder, treat it as shiny app folder")
    ## treat as shiny app folder
    message("parsing dependecies and genrate liftr file ...")
    lift_shinyapp(input, output_dir = output_dir, ...)
    return()
  }else{
    ## treat as file
    if (!file.exists(input)){
      stop('input file or shiny app folder does not exist')
    }
  }



  opt_all_list = parse_rmd(input)

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
      paste(readLines(system.file('template/syslib.Rmd', package = 'liftr')),
            paste(opt_list$syslib, collapse = ' '), sep = ' ')
  } else {
    liftr_syslib = NULL
  }

  # texlive
  if (!is.null(opt_list$latex)) {
    if (opt_list$latex == TRUE) {
      liftr_texlive =
        paste(readLines(system.file('template/texlive.Rmd', package = 'liftr')),
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
          system.file('template/pandoc.Rmd', package = 'liftr')), collapse = '\n')
      }
    } else {
      liftr_pandoc = paste(readLines(
        system.file('template/pandoc.Rmd', package = 'liftr')), collapse = '\n')
    }
  }

  # Factory packages
  liftr_factorypkgs = c('devtools', 'knitr', 'rmarkdown', 'shiny', 'RCurl')
  liftr_factorypkg = quote_str(liftr_factorypkgs)

  # CRAN packages
  if (!is.null(opt_list$cranpkg)) {
    liftr_cranpkgs = quote_str(opt_list$cranpkg)
    tmp = tempfile()
    invisible(knit(input = system.file('template/cranpkg.Rmd', package = 'liftr'),
                   output = tmp, quiet = TRUE))
    liftr_cranpkg = readLines(tmp)
  } else {
    liftr_cranpkg = NULL
  }

  # Bioconductor packages
  if (!is.null(opt_list$biocpkg)) {
    liftr_biocpkgs = quote_str(opt_list$biocpkg)
    tmp = tempfile()
    invisible(knit(input = system.file('template/biocpkg.Rmd', package = 'liftr'),
                   output = tmp, quiet = TRUE))
    liftr_biocpkg = readLines(tmp)
  } else {
    liftr_biocpkg = NULL
  }

  # GitHub packages
  if (!is.null(opt_list$ghpkg)) {
    liftr_ghpkgs = quote_str(opt_list$ghpkg)
    tmp = tempfile()
    invisible(knit(input = system.file('template/ghpkg.Rmd', package = 'liftr'),
                   output = tmp,
                   quiet = TRUE))
    liftr_ghpkg = readLines(tmp)
  } else {
    liftr_ghpkg = NULL
  }

  # extra: plain docker file line, like ADD, COPY, CMD etc
  if (!is.null(opt_list$extra)) {
    liftr_extra = opt_list$extra
  } else {
    liftr_extra = NULL
  }

  # write Dockerfile
  if (is.null(output_dir)) output_dir = file_dir(input)

  invisible(knit(system.file('template/Dockerfile.Rmd',
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

      invisible(knit(system.file('template/Rabixfile.Rmd',
                                 package = 'liftr'),
                     output = paste0(normalizePath(output_dir),
                                     '/Rabixfile'),
                     quiet = TRUE))

    }
  }

}

#' parse Rmarkdown header
#'
#' parse Rmarkdown header and return a list
#'
#' The header section is use three hyphens --- as start line & end line,
#' or three hyphens --- as start line with three dots ...
#' as end line
#'
#' @export parse_rmd
#' @aliases parse_rmd
#' @examples
#' fl = system.file("examples/docker.Rmd", package = "liftr")
#' parse_rmd(fl)
parse_rmd = function(input){
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
  yaml.load(doc_yaml)
}


trans_name <- function(x){
  names(x)[names(x) == "Bioconductor"] <- "biocpkg"
  names(x)[names(x) == "CRAN"] <- "cranpkg"
  x
}


create_lift_file = function(appDir = getwd(), appFiles = NULL, output_file = "docker.Rmd",
                            maintainer = NULL, email = NULL){
  stopifnot(dir.exists(appDir))
  .out <- file.path(normalizePath(appDir), output_file)
  ## add dummy maintain name
  if(is.null(maintainer)){
    maintainer = Sys.info()[names(Sys.info()) == "user"]
    message("maintainer name is not provided, user your system user name as maintainer name: ", maintainer)
  }
  if(is.null(email)){
    email = paste0(maintainer, "@dummy.com")
    message("email is not provided, create fake email address for placeholder: ", email)
  }
  .h <- list(maintainer = maintainer,
             maintainer_email = email)
  ## add dummy email name
  ## search for liftr.rmd
  if(!file.exists(.out)){
    ad = appDependencies(appDir = appDir, appFiles = appFiles)
    lst = by(ad, ad$source, function(x){
      as.list(x$package)
    })
    lst = trans_name(lst)
    res = list(liftr = c(.h,lst))
    message("Ouput file: ", .out)
    con = file(.out)
    txt = "---"
    txt = c(txt, as.yaml(res))
    txt = c(txt, "---")
    writeLines(txt, con = .out)
    close(con)
  }else{
    message(.out, " exists.")
  }
  .out
}

#' Dockerize an Shiny App
#'
#' Parse dependecies from a shiny app folder and lift it into a Dockerfile
#'
#' @param appDir Directory containing application. Defaults to current working directory.
#' @param appFiles The files and directories to bundle and deploy (only if upload = TRUE). Can be NULL, in which case all the files in the directory containing the application are bundled. Takes precedence over appFileManifest if both are supplied.
#' @param output_file A temporariy R markdown file with liftr header passed from shina app folder.
#' @param output_dir output_dir Directory to output \code{Dockerfile}. If not provided, will be the same directory as \code{input}.
#' @export lift_shinyapp
#' @aliases lift_shinyapp
#' @examples
#' \dontrun{
#' lift_shinayapp("test_app_folder")
#' }
lift_shinyapp <- function(appDir = getwd(), appFiles = NULL, output_file = "docker.Rmd", output_dir = NULL,
                          maintainer = NULL, email = NULL){
  .out <- create_lift_file(appDir = appDir, appFiles = appFiles, output_file = output_file,
                           maintainer = maintainer, email = email)
  lift(.out, output_dir)
}



#' lift a docopt string
#'
#' lift a docopt string used for command line
#'
#' parse Rmarkdown header from rabix field
#'
#' @param input input Rmarkdown file or a function name (character)
#' @export lift_docopt
#' @aliases lift_docopt
#' @return a string used for docopt
#' @examples
#' fl = system.file("examples/runif.Rmd", package = "liftr")
#' opts = lift_docopt(fl)
#' \dontrun{
#' require(docopt)
#' docopt(opts)
#' docopt(lift_docopt("mean.default"))
#' }
lift_docopt = function(input){

  if(file.exists(input)){
    res = lift_docopt_from_header(input)
  }else{
    message("file doesn't exist, try to try this as a function")
    res = lift_docopt_from_function(input)
  }
  res
}


lift_docopt_from_header = function(input){
  opt_all_list = parse_rmd(input)
  ol <- opt_all_list$rabix
  .in <- ol$inputs
  txt <- paste("usage:", ol$baseCommand, "[options]")
  txt <- c(txt, "options:")

  ol <- lapply(.in, function(x){
    .nm <- x$prefix
    .t <- x$type
    .type <- paste0('<', deType(.t), '>')
    .o <- paste(.nm, .type, sep = "=")
    .des <- x$description
    .default <- x$default
    if(!is.null(.default)){
      .des <- paste0(.des, " [default: ", .default, "]")
    }
    list(name = .o, description = .des)
  })
  for(i in 1:length(ol)){
    txt <- c(txt, paste(" ", ol[[i]]$name, ol[[i]]$description))
  }
  paste(txt, collapse = "\n")
}

lift_docopt_from_function = function(input){

  ol = opt_all_list = rdarg(input)

  txt <- paste0("usage: ", input, ".R",  " [options]")


  nms <- names(ol)
  lst <- NULL

  for(nm in nms){
    .nm = paste0("--", nm)
    .t = guess_type(nm, input)
    .type = paste0('<', deType(.t), '>')
    .o = paste(.nm, .type, sep = "=")
    .des = ol[[nm]]
    .def  = guess_default(nm, input)
    if(!is.null(.def)){
      .des <- paste0(.des, " [default: ", .def, "]")
    }
    lst = c(lst, list(list(name = .o, description = .des)))
  }

  for(i in 1:length(lst)){
    txt <- c(txt, paste(" ", lst[[i]]$name, lst[[i]]$description))
  }
  ## Fixme:
  paste(txt, collapse = "\n")
}


lift_cmd = function(input, output_dir = NULL, shebang = "#!/usr/local/bin/Rscript",
                    docker_root = "/"){

  if(file.exists(input)){
    opt_all_list = parse_rmd(input)
    if (is.null(output_dir))
      output_dir = dirname(normalizePath(input))

    tmp = file.path(output_dir, opt_all_list$rabix$baseCommand)
    message("command line file: ", tmp)
    con = file(tmp)
    txt = lift_docopt(input)
    txt = c(shebang, "'", paste0(txt, " ' -> doc"))
    paste("library(docopt)\n opts <- docopt(doc) \n
        rmarkdown::render('",
          docker_root, basename(input), "', BiocStyle::html_document(toc = TRUE),
        output_dir = '.', params = lst)
    " )-> .final
    txt <- c(txt, .final)
    writeLines(txt, con = con)
    close(con)
  }else{
    message("consider you passed a function name (character)")
    if (is.null(output_dir))
      output_dir = getwd()
    .baseCommand <- paste0(input, ".R")
    tmp = file.path(output_dir, .baseCommand)
    message("command line file: ", tmp)
    con = file(tmp)
    txt = lift_docopt(input)
    txt = c(shebang, "'", paste0(txt, " ' -> doc"))
    txt = c(txt, "library(docopt)\n opts <- docopt(doc)")
    .final = gen_list(input)
    txt <- c(txt, .final)
    writeLines(txt, con = con)
    close(con)
  }
  Sys.chmod(tmp)
  tmp
}

con_fun = function(type){
  res = switch(deType(type),
          int = "as.integer",
          float = "as.numeric",
          boolean = "as.logical",
          NULL)
  res
}


gen_list = function(fun){
  lst = rdarg(fun)
  lst = lst[names(lst) != "..."]
  nms = names(lst)
  txt = NULL
  for(nm in nms){
    .t = con_fun(guess_type(nm, fun))
    if(!is.null(.t)){
      txt = c(txt, paste0(nm, " = ", .t, "(", "opts$", nm, ")"))
    }else{
      txt = c(txt, paste0(nm, " = ", "opts$", nm))
    }

  }
  txt = paste("list(", paste(txt, collapse = ","), ")")
  paste("do.call(", fun, ",", txt, ")")

}


guess_type = function(nm, fun){
  dl = formals(fun)
  if(!is.null(dl[[nm]])){
    .c <- class(dl[[nm]])
    if(.c == "name"){
      return("string")
    }else{
      return(deType(.c))
    }

  }else{
    return("string")
  }
}

guess_default = function(nm, fun){
  dl = formals(fun)
  if(!is.null(dl[[nm]])){
    .c <- class(dl[[nm]])
    if(.c == "name"){
      return(NULL)
    }else{
      return(dl[[nm]])
    }

  }else{
    return(NULL)
  }
}

lift_cmd("runif", file.path(getwd()))


