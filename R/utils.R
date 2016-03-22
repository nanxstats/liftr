# convert string vectors to single quote-marked string sep by comma
quote_str = function (x) paste0("\'", paste(x, collapse = "','"), "\'")

# get directory of the file
file_dir = function (x) dirname(normalizePath(x))

# get file name with extension
file_name = function (x) basename(normalizePath(x))

# get file name without extension
sans_ext = tools::file_path_sans_ext
file_name_sans = function (x) basename(sans_ext(normalizePath(x)))

# generate uuid for Docker container names
# derived from http://stackoverflow.com/questions/10492817/
uuid = function () {
  id = paste(sample(c(letters[1:6], 0:9), 30, replace = TRUE),
             collapse = '')
  paste(substr(id, 1, 8), '_', substr(id, 9, 12), '_', '4',
        substr(id, 13, 15), '_', sample(c('8', '9', 'a', 'b'), 1),
        substr(id, 16, 18), '_', substr(id, 19, 30), sep = '',
        collapse = '')
}

#' check if from Bioconductor base images
#' @importFrom stringr str_trim
#' @noRd
is_from_bioc = function (x) substr(str_trim(x), 1L, 13L) == 'bioconductor/'

#' check if from the rocker/rstudio base image
#' @importFrom stringr str_trim
#' @noRd
is_from_rstudio = function (x) substr(str_trim(x), 1L, 14L) == 'rocker/rstudio'


deType <- function(x){

  ## string
  str_type <- c('STRING', 'STR', '<string>', '<str>', 'str', "character",
                "string", "String")
  ## int
  int_type <- c('INTEGER', 'INT', '<integer>', '<int>', 'int',
                "integer", "Integer")
  ## float
  float_type <- c('FLOAT', '<float>', 'float', 'Float', 'numeric')
  ## File
  file_type <- c('FILE', '<file>', 'File', 'file')

  ## enum
  enum_type <- c('ENUM', '<enum>', 'enum', "Enum")

  ## boolean
  boolean_type <- c('BOOLEAN', '<boolean>', 'boolean', "Boolean", "logical", "logic", "Logical")

  .array <- FALSE
  if(is.character(x)){
    res <- ""
    if(grepl("\\.\\.\\.", x)){
      .array <- TRUE
      x <- gsub("[^[:alnum:]]", "", x)
    }

    if(x %in% str_type){
      res <- "string"
    }else if(x %in% int_type){
      res <- "int"
    }else if(x %in% float_type){
      res <- "float"
    }else if(x %in% file_type){
      res <- "File"
    }else if(x %in% enum_type){
      res <- "enum"
    }else if(x %in% boolean_type){
      res <- "boolean"
    }else{
      res <- x
    }
    if(.array){
      res <- ItemArray(res)
    }
  }else{
    res <- x
  }
  res
}

## copied from roxygen2
rdarg <- function(topic, dots = FALSE){


  internal_f <- function(p, f) {
    stopifnot(is.character(p), length(p) == 1)
    stopifnot(is.character(f), length(f) == 1)

    get(f, envir = asNamespace(p))
  }

  get_rd <- function(topic, package = NULL) {
    help_call <- substitute(help(t, p), list(t = topic, p = package))
    top <- eval(help_call)
    if (length(top) == 0) return(NULL)

    internal_f("utils", ".getHelpFile")(top)
  }

  # get_rd should parse Rd into a rd_file so I don't need to maintain
  # two parallel apis

  get_tags <- function(rd, tag) {
    rd_tag <- function(x) attr(x, "Rd_tag")

    Filter(function(x) rd_tag(x) == tag, rd)
  }

  rd2rd <- function(x) {
    chr <- internal_f("tools", "as.character.Rd")(x)
    paste(unlist(chr), collapse = "")
  }

  # rd_arguments(get_rd("mean"))
  rd_arguments <- function(rd) {
    arguments <- get_tags(rd, "\\arguments")[[1]]
    items <- get_tags(arguments, "\\item")

    values <- lapply(items, function(x) rd2rd(x[[2]]))
    params <- vapply(items, function(x) rd2rd(x[[1]]), character(1))

    setNames(values, params)
  }

  res = rd_arguments(get_rd(topic))
  if(!dots){
    res = res[names(res) != "\\dots"]
  }

  res = sapply(res,
         function(x){
           x = gsub("\n" , "", x)
           x = gsub("\\\\", "", x)
         })

  nms = names(formals(topic))
  nms = setdiff(nms, "...")

  res = split_arg(res)
  res[names(res) %in% nms]
}

split_arg = function(x){
  .arg = c()
  for(nm in names(x)){

    if(grepl(",", nm)){
      nms = strsplit(nm, split = ",")[[1]]
      nms = gsub("^\\s+|\\s+$", "", nms)
      res = rep(x[nm], length(nms))
      names(res) = nms
    }else{
      res = x[nm]
    }
   .arg = c(.arg, res)
  }
  .arg
}



