#' @noRd
mod_home_ui <- function(id) {
  ns <- NS(id)
  tags$div(
    id = "pane-home",
    class = "content-pane active",

    tags$div(
      class = "page-header",
      tags$h1(class = "page-title", "Welcome to recipeR"),
      tags$p(
        class = "page-subtitle",
        "Your personal recipe manager with ingredient matching"
      )
    ),

    bslib::layout_columns(
      col_widths = c(3, 3, 3, 3),
      bslib::value_box(
        title = "Recipes",
        value = textOutput(ns("stat_total_recipes"), inline = TRUE),
        showcase = tags$i(class = "fas fa-book fa-lg"),
        theme = "primary"
      ),
      bslib::value_box(
        title = "Cuisines",
        value = textOutput(ns("stat_cuisines"), inline = TRUE),
        showcase = tags$i(class = "fas fa-globe fa-lg"),
        theme = "info"
      ),
      bslib::value_box(
        title = "Ingredients",
        value = textOutput(ns("stat_ingredients"), inline = TRUE),
        showcase = tags$i(class = "fas fa-carrot fa-lg"),
        theme = "success"
      ),
      bslib::value_box(
        title = "Avg per Recipe",
        value = textOutput(ns("stat_avg_ingredients"), inline = TRUE),
        showcase = tags$i(class = "fas fa-chart-bar fa-lg"),
        theme = "warning"
      )
    ),

    bslib::layout_columns(
      col_widths = c(3, 3, 3, 3),
      bslib::card(
        bslib::card_body(
          tags$div(
            class = "feature-card-icon",
            tags$i(class = "fas fa-magnifying-glass")
          ),
          tags$h5("Browse Recipes"),
          tags$p(
            "Search and filter your collection with live ingredient match scores."
          )
        )
      ),
      bslib::card(
        bslib::card_body(
          tags$div(class = "feature-card-icon", tags$i(class = "fas fa-plus")),
          tags$h5("Add Recipes"),
          tags$p(
            "Create recipes with free-text ingredient parsing and live preview."
          )
        )
      ),
      bslib::card(
        bslib::card_body(
          tags$div(
            class = "feature-card-icon",
            tags$i(class = "fas fa-scale-balanced")
          ),
          tags$h5("Scale & Cook"),
          tags$p(
            "Scale any recipe and cook step-by-step with a built-in timer."
          )
        )
      ),
      bslib::card(
        bslib::card_body(
          tags$div(class = "feature-card-icon", tags$i(class = "fas fa-gear")),
          tags$h5("Settings"),
          tags$p(
            "Manage unit preferences, densities, and import/export your recipes."
          )
        )
      )
    )
  )
}

#' @noRd
mod_home_server <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    output$stat_total_recipes <- renderText({
      length(rv$recipes)
    })

    output$stat_cuisines <- renderText({
      if (length(rv$recipes) == 0) return("0")
      length(unique(sapply(rv$recipes, function(r) r$source)))
    })

    output$stat_ingredients <- renderText({
      length(rv$ingredients)
    })

    output$stat_avg_ingredients <- renderText({
      if (length(rv$recipes) == 0) return("0")
      round(mean(sapply(rv$recipes, function(r) length(r$ingredients))), 1)
    })
  })
}
