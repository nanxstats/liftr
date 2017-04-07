#' Purge Docker Container
#'
#' This function stops and removes the Docker container used
#' for rendering the R Markdown document, by running
#' \code{docker stop} and \code{docker rm} commands.
#'
#' @param container_name Name of the container to be stopped and removed.
#'
#' @export purge_container
#'
#' @return status
#'
#' @examples
#' \dontrun{
#' purge_container("liftr_container_uuid")}

purge_container = function(container_name) {
  # TODO: needs exception handling
  system(paste0("docker stop \"", container_name, "\""))
  system(paste0("docker rm -f \"", container_name, "\""))
}

#' Remove Docker Image
#'
#' This function removes the Docker image used
#' for rendering the R Markdown document by
#' running \code{docker rmi} commands.
#'
#' @param image_name Name of the image to be removed.
#'
#' @export remove_image
#'
#' @return status
#'
#' @examples
#' \dontrun{
#' remove_image("report")}

remove_image = function(image_name) {
  # TODO: needs exception handling
  system(paste0("docker rmi -f \"", image_name, "\""))
}

#' Cleanup Everything
#'
#' This function will try to stop and remove the Docker container
#' and image used for rendering the R Markdown document.
#'
#' @param container_name Name of the container to be stopped and removed.
#' @param image_name Name of the image to be removed.
#'
#' @export remove_all
#'
#' @return status
#'
#' @examples
#' \dontrun{
#' remove_all("liftr_container_uuid", "report")}

remove_all = function(container_name, image_name) {
  liftr::stop_container(container_name)
  liftr::remove_container(container_name)
  liftr::remove_image(image_name)
}
