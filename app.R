# Launch the ShinyApp (Do not remove this comment)
# To deploy, run: rsconnect::deployApp()
# Or use the blue button on top of this file

if (requireNamespace("pkgload", quietly = TRUE)) {
  # Local dev: load in-place so recipeR:: namespace is available
  pkgload::load_all(export_all = FALSE, helpers = FALSE, attach_testthat = FALSE)
  options("golem.app.prod" = TRUE)
  recipeR::run_app()
} else {
  # Production (Connect Cloud): source R/ files directly — pkgload not required
  options("golem.app.prod" = TRUE)
  invisible(lapply(sort(list.files("R", pattern = "\\.R$", full.names = TRUE)), source))
  run_app()
}
