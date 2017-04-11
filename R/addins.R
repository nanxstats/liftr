#' RStudio Addin: Containerize R Markdown Document
#'
#' Call this function as an addin to dockerize (lift) the current document.
#'
#' @importFrom rstudioapi getActiveDocumentContext
addin_lift = function() {

  context = rstudioapi::getActiveDocumentContext()
  path = normalizePath(context$'path')
  lift(path)

}

#' RStudio Addin: Containerize and Render R Markdown Document with Docker
#'
#' Call this function as an addin to containerize and render
#' the current document.
#'
#' @importFrom rstudioapi getActiveDocumentContext
addin_lift_render_docker = function() {

  context = rstudioapi::getActiveDocumentContext()
  path = normalizePath(context$'path')
  lift(path)
  render_docker(path)

}

#' RStudio Addin: Purge Docker Image
#'
#' Call this function as an addin to removes the Docker image used
#' for rendering the current document.
#'
#' @importFrom rstudioapi getActiveDocumentContext
addin_purge_image = function() {

  context = rstudioapi::getActiveDocumentContext()
  path = normalizePath(context$'path')
  path = paste0(file_dir(path), '/', file_name_sans(path), '.docker.yml')
  purge_image(path)

}
