#' Purge Docker Container
#'
#' This function stops and removes the Docker container used
#' for rendering the R Markdown document, by running
#' \code{docker stop} and \code{docker rm} commands.
#'
#' @param input The YAML file (default output of \code{\link{render_docker}})
#' storing the information of the container to be stopped and removed.
#'
#' @importFrom yaml yaml.load_file
#'
#' @export purge_container
#'
#' @return purge results
#'
#' @examples
#' \dontrun{
#' purge_container("liftr-minimal.docker.yml")}

purge_container = function(input) {

  if (is.null(input))
    stop('missing input file')
  if (!file.exists(normalizePath(input)))
    stop('input file does not exist')

  lst = yaml.load_file(normalizePath(input))
  container_name = lst$'container_name'

  # TODO: needs exception handling
  system(paste0("docker stop \"", container_name, "\""))
  system(paste0("docker rm -f \"", container_name, "\""))

}

#' Purge Docker Image
#'
#' This function removes the Docker image used
#' for rendering the R Markdown document by
#' running \code{docker rmi} commands.
#'
#' @param input The YAML file (default output of \code{\link{render_docker}})
#' storing the information of the image to be removed.
#'
#' @importFrom yaml yaml.load_file
#'
#' @export purge_image
#'
#' @return status
#'
#' @examples
#' \dontrun{
#' purge_image("liftr-minimal.docker.yml")}

purge_image = function(input) {

  if (is.null(input))
    stop('missing input file')
  if (!file.exists(normalizePath(input)))
    stop('input file does not exist')

  lst = yaml.load_file(normalizePath(input))
  image_name = lst$'image_name'

  # TODO: needs exception handling
  system(paste0("docker rmi -f \"", image_name, "\""))

}
