#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    fluidPage(
      shiny::navbarPage(
        title = "recipeR",
        tabPanel("Home",
                 fluidRow(
                   column(12, h2("Welcome to recipeR"), p("Manage recipes and match them to your pantry."))
                 )
        ),
        tabPanel("Browse Recipes",
                 fluidRow(
                   column(4,
                          wellPanel(
                            h4("Filters"),
                            sliderInput("match_threshold", "Minimum match %", min = 0, max = 100, value = 0),
                            textInput("search_text", "Search title/ingredients", "")
                          )
                   ),
                   column(8,
                          h4("Recipes"),
                          uiOutput("recipes_cards"),
                          DT::dataTableOutput("recipes_table")
                   )
                 )
        ),
        tabPanel("Add Recipe",
                 fluidRow(
                   column(6,
                          textInput("new_title", "Title"),
                          selectInput("new_source", "Source", choices = c("manual", "url", "imported"), selected = "manual"),
                          textAreaInput("new_ingredients_raw", "Ingredients (one per line)", rows = 8),
                          textAreaInput("new_instructions", "Instructions (one per line)", rows = 8),
                          actionButton("save_recipe", "Save Recipe", class = "btn-primary")
                   ),
                   column(6,
                          h4("Preview"),
                          verbatimTextOutput("new_recipe_preview")
                   )
                 )
        ),
        tabPanel("My Ingredients",
                 fluidRow(
                   column(6,
                          h4("Add Ingredient"),
                          textInput("ing_name", "Name"),
                          numericInput("ing_qty", "Quantity", value = NA, min = 0),
                          textInput("ing_unit", "Unit"),
                          actionButton("save_ing", "Add / Update")
                   ),
                   column(6,
                          h4("Inventory"),
                          DT::dataTableOutput("ingredients_table")
                   )
                 )
        ),
        tabPanel("Shopping List",
                 fluidRow(column(12, h4("Shopping list will appear here"), verbatimTextOutput("shopping_list")))
        ),
        tabPanel("Settings",
                 fluidRow(
                   column(12,
                          h4("Settings"),
                          p("App settings and data export/import"),
                          hr(),
                          h5("Units"),
                          radioButtons("unit_system", "Preferred unit system:", choices = c("american" = "american", "european" = "european"), selected = "american", inline = TRUE),
                          actionButton("save_prefs", "Save Preferences"),
                          hr(),
                          h5("Ingredient Densities"),
                          p("View and edit ingredient densities (g/ml) for volume-to-mass conversions."),
                          DT::dataTableOutput("densities_table"),
                          br(),
                          h5("Add Custom Density"),
                          textInput("new_density_ingredient", "Ingredient name"),
                          numericInput("new_density_value", "Density (g/ml)", value = 1.0, min = 0.1, step = 0.01),
                          actionButton("add_density_btn", "Add Density"),
                          hr(),
                          h5("Export"),
                          downloadButton("export_json", "Download JSON"),
                          downloadButton("export_csv", "Download CSV"),
                          br(), br(),
                          h5("Import"),
                          fileInput("import_file", "Choose JSON or CSV to import", accept = c('.json', '.csv')),
                          actionButton("import_btn", "Import File"),
                          hr(),
                          h5("Backup / Restore"),
                          actionButton("backup_btn", "Create Backup"),
                          selectInput("restore_choice", "Restore from backup", choices = character()),
                          actionButton("restore_btn", "Restore Selected Backup")
                   )
                 )
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "recipeR"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
