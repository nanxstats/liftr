#' RStudio Addin: New R Markdown Document with Docker (and Rabix) Support
#'
#' Call this function as an addin to create new R Markdown document with
#' Docker (and Rabix) support.
#'
#' @export
addin_new_drmd = function() {

  ui = miniPage(

    gadgetTitleBar('New Dockerized R Markdown Document',
                   right = miniTitleBarButton('done', 'OK', primary = TRUE)),

    miniTabstripPanel(
      miniTabPanel('Basic', icon = icon('magic'),
                   miniContentPanel(
                     sliderInput('year', 'Year', 1978, 2010, c(2000, 2010), sep = '')
                   )
      ),
      miniTabPanel('Docker', icon = icon('rocket'),
                   miniContentPanel(
                     plotOutput('cars', height = '100%')
                   )
      ),
      miniTabPanel('Rabix', icon = icon('sitemap'),
                   miniContentPanel(
                     plotOutput('cars', height = '100%')
                   )
      )
    )

  )

  server = function(input, output, session) {

    ## Your reactive logic goes here.

    # Listen for the 'done' event. This event will be fired when a user
    # is finished interacting with your application, and clicks the 'done'
    # button.
    observeEvent(input$done, {

      # Here is where your Shiny application might now go an affect the
      # contents of a document open in RStudio, using the `rstudioapi` package.
      #
      # At the end, your application should call 'stopApp()' here, to ensure that
      # the gadget is closed after 'done' is clicked.
      stopApp()
    })
  }

  viewer = dialogViewer('New Dockerized R Markdown', width = 800, height = 600)
  runGadget(ui, server, viewer = viewer)

}

#' RStudio Addin: Dockerize the R Markdown Document
#'
#' Call this function as an addin to dockerize (lift) the current document.
#'
#' @importFrom rstudioapi getActiveDocumentContext
#'
#' @export
addin_lift = function() {

  context = getActiveDocumentContext()
  path = normalizePath(context$'path')
  lift(path)

}

#' RStudio Addin: Render the Dockerized R Markdown Document
#'
#' Call this function as an addin to render (drender) the current document.
#'
#' @importFrom rstudioapi getActiveDocumentContext
#'
#' @export
addin_drender = function() {

  context = getActiveDocumentContext()
  path = normalizePath(context$'path')
  drender(path)

}

#' RStudio Addin: Dockerize and Render the R Markdown Document
#'
#' Call this function as an addin to dockerize (lift) and render (drender)
#' the current document.
#'
#' @importFrom rstudioapi getActiveDocumentContext
#'
#' @export
addin_lift_drender = function() {

  context = getActiveDocumentContext()
  path = normalizePath(context$'path')
  lift(path)
  drender(path)

}
