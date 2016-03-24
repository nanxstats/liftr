setClassUnion("characterORNULL", c("character", "NULL"))
setClassUnion("logicalORNULL", c("logical", "NULL"))

#' Creat a Onepunch object
#'
#' Onepunch object used for rendering
#'
#' @param input input Input (R Markdown or Shiny R markdown) file or shiny app folder.
#' @param output_dir output_dir Directory to output \code{Dockerfile}.
#' @param container container name
#' @param image image name
#' @param tag Docker image name to build, sent as docker argument \code{-t}.
#' If not specified, it will use the same name as the input file.
#' @param prebuild prebuild a command line string to call before docker build
#' @param build_args build_args A character string specifying additional
#' \code{docker build} arguments. For example,
#' \code{--pull=true -m="1024m" --memory-swap="-1"}.
#' @param liftr_template Rmarkdown template used to generate Dockerfile.
#' @param dockerfile Dockerfile path.
#' @param cache default TRUE, if FALSE, build with --no-cache=true
#' @param rm efault FALSE, if TRUE build with --rm
#' @param clean clean all container or not
#' @param type "shinyapp" or "shinydoc" or "rmd"
#' @param browseURL logical, default FALSE, to open browser automatically or not for shiny
#' @param shiny_run how to launch shiny from command line
#' @param url returned URL for browsing.
#'
#' @return Onepunch object
#'
#' @exportClass Onepunch
#' @export Onepunch
#' @examples
#' o = Onepunch("~/liftr_docker/ShinyDoc.Rmd")
#' \dontrun{
#' o$punch()
#' o$clean()
#' }
Onepunch = setRefClass("Onepunch",
                    fields = list(input = "characterORNULL",
                                  output_dir = "characterORNULL",
                                  container = "characterORNULL",
                                  image = "characterORNULL",
                                  tag = "characterORNULL",
                                  prebuild = "characterORNULL",
                                  build_args = "characterORNULL",
                                  lift_template = "characterORNULL",
                                  dockerfile = "characterORNULL",
                                  cache = "logicalORNULL",
                                  rm = "logicalORNULL",
                                  clean = "logicalORNULL",
                                  type = "characterORNULL",
                                  browseURL = "logicalORNULL",
                                  shiny_run = "characterORNULL",
                                  url = "characterORNULL"
                                  ),
                    methods = list(
                      initialize = function(input = getwd(),
                                            output_dir = NULL,
                                            lift_template = system.file('template/Dockerfile.Rmd', package = 'liftr'),
                                            container = NULL,
                                            image = NULL,
                                            tag = NULL,
                                            prebuild = NULL,
                                            dockerfile = NULL,
                                            cache = TRUE,
                                            rm = FALSE,
                                            clean = FALSE,
                                            type = NULL,
                                            browseURL = FALSE,
                                            shiny_run = NULL,
                                            url = NULL,
                                            ...
                                            ){

                         input <<- input
                         if(is.null(output_dir))
                           output_dir <<- dirname(input)
                         lift_template <<- lift_template
                         container <<- container
                         image <<- image
                         tag <<- tag
                         prebuild <<- prebuild
                         dockerfile <<- dockerfile
                         cache <<- cache
                         rm <<- rm
                         clean <<- clean
                         type <<- get_type(input)
                         browseURL <<- browseURL
                         shiny_run <<- shiny_run
                         url <<- url

                      },
                      delete = function(id = NULL){
                        if(is.null(id)){
                          id <- container
                        }
                        system(paste("docker stop", id))
                        system(paste("docker rm", id))
                      },
                      clean_container = function(){
                        system("docker stop $(docker ps -a -q)")
                        system("docker rm $(docker ps -a -q)")
                      },
                      clean_image = function(){
                        system("docker rmi $(docker images | grep '^<none>' | awk '{print $3}')")
                      },
                      clean_all = function(){
                        clean_container()
                        clean_image()
                      },
                      lift = function(...){
                        res = liftr::lift(input, dockerfile = lift_template, output_dir = output_dir, ...)
                        dockerfile <<- res$dockerfile
                        res
                      },
                      drender = function(...){
                        res = liftr::drender(input, clean = clean, rm = rm, cache = cache, prebuild = prebuild,
                                      browseURL = browseURL, ...)
                        image <<- res$image_name
                        container <<- res$container_name
                        shiny_run <<- res$shiny_run
                        url <<- res$url
                        res
                      },
                      onepunch = function(...){
                        lift()
                        drender()
                      },
                      deploy = function(script = NULL,
                                        ...){
                        'deploy inside container'
                        if(is.null(container)){
                          onepunch()
                        }
                        .base = paste("docker run  ", image)
                        if(!is.null(script))
                          .base = paste0(.base,
                                         " /usr/bin/Rscript -e \"", script, ";")
                        dots_arg = list(...)

                        dots_arg$appDir = paste0("/srv/shiny-server/",file_name(input))
                        tmp = tempfile()
                        dput(dots_arg, file = tmp)

                        render_args = squote(paste0(readLines(tmp), collapse = '\n'))


                        render_cmd = paste0("library(rsconnect);do.call(deployApp, ", render_args, ")")

                        docker_run_cmd = paste0(.base, render_cmd, "\"")
                        message(docker_run_cmd)
                        system(docker_run_cmd)
                      },
                      show = function(){
                        .showFields(.self)
                      }

                    ))

