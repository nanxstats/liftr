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
