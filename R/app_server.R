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

  # Theme toggle (sidebar widget, outside any module)
  observeEvent(input$color_mode, {
    if (input$color_mode == "light") {
      session$setCurrentTheme(app_theme_light())
    } else {
      session$setCurrentTheme(app_theme_dark())
    }
    prefs <- get_prefs()
    prefs$color_mode <- input$color_mode
    save_prefs(prefs)
  })

  mod_home_server("home", rv)
  mod_browse_server("browse", rv, refresh_data)
  mod_add_server("add", rv, refresh_data)
  mod_ingredients_server("ingredients", rv, refresh_data)
  mod_cooking_server("cooking", rv)
  mod_shopping_server("shopping", rv)
  mod_settings_server("settings", rv, refresh_data, session)
}
