#' Remove Docker Containers, Images, and Networks
#'
#' This function removes stopped containers, all networks
#' not used by at least one container, all dangling images,
#' and all build cache.
#'
#' @param volumes Logical. Should we prune volumes? Default is \code{FALSE}.
#'
#' @export prune_all_auto
#'
#' @return prune results
#'
#' @references \url{https://docs.docker.com/engine/admin/pruning/}
#'
#' @examples
#' \dontrun{
#' prune_all_auto()}

prune_all_auto = function(volumes = FALSE) {
  cat('Cleaning up everything...\n')
  if (volumes) system('docker system prune --volumes --force') else
    system('docker system prune --force')
}

#' Remove Dangling Docker Containers
#'
#' This function prunes all dangling Docker containers automatically.
#'
#' @export prune_container_auto
#'
#' @return prune results
#'
#' @references \url{https://docs.docker.com/engine/admin/pruning/}
#'
#' @examples
#' \dontrun{
#' prune_container_auto()}

prune_container_auto = function() {
  cat('Cleaning up dangling containers...\n')
  system('docker container prune --force')
}

#' Remove Specific Docker Containers
#'
#' This function stops and removes the Docker containers used
#' for rendering the R Markdown document based on the output
#' YAML file from the (possibly unsuccessful) rendering process.
#'
#' @param input_yml The YAML file path (output of \code{\link{render_docker}})
#' when \code{prune_info = TRUE} which stores the information of the Docker
#' container to be stopped and removed. If not specified, will prune all
#' dangling containers.
#'
#' @importFrom yaml yaml.load_file
#'
#' @export prune_container
#'
#' @return prune results
#'
#' @examples
#' \dontrun{
#' prune_container()}

prune_container = function(input_yml) {

  if (!file.exists(normalizePath(input_yml)))
    stop('input file does not exist')

  lst = yaml.load_file(normalizePath(input_yml))
  container_name = lst$'container_name'

  # TODO: needs exception handling
  cat('Cleaning up dangling containers...\n')
  system(paste0("docker stop \"", container_name, "\""))
  system(paste0("docker rm -f \"", container_name, "\""))

}

#' @rdname prune_container
#' @export purge_container
purge_container = function() {
  .Deprecated('prune_container')
}

#' Remove Dangling Docker Images
#'
#' This function prunes all dangling Docker images automatically.
#'
#' @export prune_image_auto
#'
#' @return prune results
#'
#' @references \url{https://docs.docker.com/engine/admin/pruning/}
#'
#' @examples
#' \dontrun{
#' prune_image_auto()}

prune_image_auto = function() {

  cat('Cleaning up dangling images...\n')
  system('docker image prune --force')

}

#' Remove Specific Docker Images
#'
#' This function removes the Docker images used
#' for rendering the R Markdown document based on the output
#' YAML file from the (possibly unsuccessful) rendering process.
#'
#' @param input_yml The YAML file path (output of \code{\link{render_docker}})
#' when \code{prune_info = TRUE} which stores the information of the
#' Docker image to be removed. If not specified, will prune all
#' dangling images.
#'
#' @importFrom yaml yaml.load_file
#'
#' @export prune_image
#'
#' @return prune results
#'
#' @examples
#' \dontrun{
#' prune_image()}

prune_image = function(input_yml) {

  if (!file.exists(normalizePath(input_yml)))
    stop('input file does not exist')

  lst = yaml.load_file(normalizePath(input_yml))
  image_name = lst$'image_name'

  # TODO: needs exception handling
  cat('Cleaning up dangling images...\n')
  system(paste0("docker rmi -f \"", image_name, "\""))

}

#' @rdname prune_image
#' @export purge_image
purge_image = function() {
  .Deprecated('prune_image')
}
