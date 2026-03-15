#' Run the Shiny Application
#'
#' @param ... arguments to pass to golem_opts.
#' See `?golem::get_golem_options` for more details.
#' @inheritParams shiny::shinyApp
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(
  onStart = NULL,
  options = list(),
  enableBookmarking = NULL,
  uiPattern = "/",
  ...
) {
  # Register www/ static assets (works both installed and via pkgload::load_all)
  www_path <- system.file("app/www", package = "recipeR")
  if (!nzchar(www_path)) {
    www_path <- file.path(getwd(), "inst", "app", "www")
  }
  if (dir.exists(www_path)) {
    shiny::addResourcePath("www", www_path)
  }

  with_golem_options(
    app = shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = onStart,
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    golem_opts = list(...)
  )
}
