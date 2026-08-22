#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  rv <- reactiveValues(
    recipes = list(),
    ingredients = list(),
    shopping = list(),
    compare_pair = NULL,
    selected_card_ids = character(),
    cooking_recipe = NULL,
    cooking_step = 1L
  )

  refresh_data <- function() {
    rv$recipes <- get_recipes()
    rv$ingredients <- get_ingredients()
    rv$shopping <- get_shopping_list()
  }

  refresh_data()

  # Theme toggle (sidebar widget, outside any module) — shinyglass light/dark/auto
  shinyglass::observe_glass_theme_toggle(input, session, inputId = "color_mode")
  observeEvent(
    c(input$color_mode_light, input$color_mode_dark, input$color_mode_auto),
    {
      mode <- if (isTRUE(input$color_mode_light)) {
        "light"
      } else if (isTRUE(input$color_mode_dark)) {
        "dark"
      } else {
        "auto"
      }
      prefs <- get_prefs()
      prefs$color_mode <- mode
      save_prefs(prefs)
    }
  )

  mod_home_server("home", rv)
  mod_browse_server("browse", rv, refresh_data)
  mod_add_server("add", rv, refresh_data)
  mod_ingredients_server("ingredients", rv, refresh_data)
  mod_cooking_server("cooking", rv)
  mod_shopping_server("shopping", rv)
  mod_settings_server("settings", rv, refresh_data, session)
}
