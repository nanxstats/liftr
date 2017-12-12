#' Installation Helper for Docker Engine
#'
#' This function guides you to install Docker (Engine).
#'
#' @export install_docker
#'
#' @return NULL
#'
#' @references \url{https://docs.docker.com/engine/installation/}
#'
#' @examples
#' \dontrun{
#' install_docker()}

install_docker = function() {

  ostype = check_os()

  url_mac = 'https://docs.docker.com/docker-for-mac/install/'
  url_win = 'https://docs.docker.com/docker-for-windows/install/'
  url_lnx = 'https://docs.docker.com/engine/installation/#server'

  if (ostype == 'mac') {
    cat('Please follow the instructions on',
        url_mac, '\nto install Docker for Mac (admin privileges required).')
    browseURL(url_mac)
  }

  if (ostype == 'win') {
    cat('Please follow the instructions on',
        url_win, '\nto install Docker for Windows (admin privileges required).')
    browseURL(url_win)
  }

  if (ostype == 'lnx') {
    cat('Please follow the instructions on',
        url_lnx, '\nto install Docker for your Linux distribution (admin privileges required).')
    browseURL(url_lnx)
  }

  cat('\nPlease use check_docker() after installation to see if Docker was detectable.')

  invisible()

}

#' Check if Docker was Installed
#'
#' This function checks if Docker was properly
#' installed and discoverable by R and liftr.
#' If still not usable, please start Docker daemon
#'
#' @export check_docker_install
#'
#' @return \code{TRUE} if Docker was deteted, \code{FALSE} otherwise.
#'
#' @examples
#' check_docker_install()

check_docker_install = function() {
  x = system('docker -v', intern = TRUE)
  if (grepl('Docker version', x)) TRUE else FALSE
}

#' Check if Docker Daemon is Running
#'
#' This function checks if the Docker daemon is running.
#'
#' @export check_docker_running
#'
#' @return \code{TRUE} if Docker daemon is running, \code{FALSE} otherwise.
#'
#' @examples
#' check_docker_running()

check_docker_running = function() {
  if (!check_docker_install()) FALSE else suppressWarnings(
    x <- system('docker info', intern = TRUE, ignore.stderr = TRUE))
  length(x) != 0
}
