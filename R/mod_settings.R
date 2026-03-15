#' @noRd
mod_settings_ui <- function(id) {
  ns <- NS(id)
  tags$div(
    id = "pane-settings",
    class = "content-pane",

    tags$div(
      class = "page-header",
      tags$h1(class = "page-title", "Settings"),
      tags$p(class = "page-subtitle", "Preferences, densities, import / export")
    ),

    bslib::layout_columns(
      col_widths = c(8, 4),

      bslib::accordion(
        id = "settings_accordion",
        open = TRUE,

        bslib::accordion_panel(
          value = "units",
          title = tagList(
            tags$i(class = "fas fa-ruler", style = "margin-right:0.4rem;"),
            "Unit Preferences"
          ),
          radioButtons(
            ns("unit_system"),
            NULL,
            choices = c(
              "American" = "american",
              "European / Metric" = "european"
            ),
            selected = "american",
            inline = TRUE
          ),
          actionButton(
            ns("save_prefs"),
            tagList(tags$i(class = "fas fa-floppy-disk"), " Save"),
            class = "btn btn-primary mt-2"
          )
        ),

        bslib::accordion_panel(
          value = "densities",
          title = tagList(
            tags$i(class = "fas fa-flask", style = "margin-right:0.4rem;"),
            "Ingredient Densities"
          ),
          tags$p(
            class = "text-muted",
            style = "font-size:0.825rem;margin-bottom:1rem;",
            "Densities (g/ml) enable volume-to-mass conversions."
          ),
          DT::dataTableOutput(ns("densities_table")),
          tags$hr(),
          tags$h6(class = "settings-section-label", "Add Custom Density"),
          bslib::layout_columns(
            col_widths = c(6, 6),
            textInput(ns("new_density_ingredient"), "Ingredient", width = "100%"),
            numericInput(
              ns("new_density_value"),
              "Density (g/ml)",
              value = 1.0,
              min = 0.1,
              step = 0.01,
              width = "100%"
            )
          ),
          tags$div(
            class = "mt-3",
            style = "display:flex;gap:0.5rem;",
            actionButton(
              ns("add_density_btn"),
              tagList(tags$i(class = "fas fa-plus"), " Add"),
              class = "btn btn-success"
            ),
            actionButton(
              ns("delete_density_btn"),
              tagList(tags$i(class = "fas fa-trash"), " Delete Selected"),
              class = "btn btn-danger"
            )
          )
        ),

        bslib::accordion_panel(
          value = "importexport",
          title = tagList(
            tags$i(class = "fas fa-right-left", style = "margin-right:0.4rem;"),
            "Import & Export"
          ),
          tags$h6(class = "settings-section-label", "Export Recipes"),
          tags$div(
            style = "display:flex;gap:0.5rem;flex-wrap:wrap;",
            downloadButton(
              ns("export_json"),
              tagList(tags$i(class = "fas fa-file-code"), " JSON"),
              class = "btn btn-secondary"
            ),
            downloadButton(
              ns("export_csv"),
              tagList(tags$i(class = "fas fa-file-csv"), " CSV"),
              class = "btn btn-secondary"
            )
          ),
          tags$hr(),
          tags$h6(class = "settings-section-label", "Import Recipes"),
          fileInput(
            ns("import_file"),
            NULL,
            accept = c(".json", ".csv"),
            placeholder = "Choose JSON or CSV..."
          ),
          actionButton(
            ns("import_btn"),
            tagList(tags$i(class = "fas fa-upload"), " Import"),
            class = "btn btn-success"
          ),
          tags$hr(),
          tags$h6(class = "settings-section-label", "Backup & Restore"),
          tags$div(
            style = "display:flex;gap:0.5rem;flex-wrap:wrap;",
            actionButton(
              ns("backup_btn"),
              tagList(tags$i(class = "fas fa-box-archive"), " Create Backup"),
              class = "btn btn-secondary"
            ),
            actionButton(
              ns("restore_btn"),
              tagList(
                tags$i(class = "fas fa-clock-rotate-left"),
                " View Backups"
              ),
              class = "btn btn-secondary"
            )
          )
        )
      ),

      bslib::card(
        bslib::card_header(tags$h5(
          tags$i(
            class = "fas fa-circle-info",
            style = "color:var(--bs-info);margin-right:0.4rem;"
          ),
          "App Info"
        )),
        bslib::card_body(
          class = "text-muted",
          style = "font-size:0.85rem;",
          tags$p(tags$strong("Version:"), " 0.0.0.9000"),
          tags$p(tags$strong("Storage:"), " ~/.recipeR/"),
          tags$p(tags$strong("Framework:"), " golem + Shiny"),
          tags$p(tags$strong("Theme:"), " bslib 0.9"),
          tags$hr(),
          tags$p(
            tags$strong("Keyboard shortcuts:"),
            tags$br(),
            tags$kbd("/"),
            " -- Jump to search",
            tags$br(),
            tags$kbd("Esc"),
            " -- Exit cooking mode"
          )
        )
      )
    )
  )
}

#' @noRd
mod_settings_server <- function(id, rv, refresh_data, parent_session) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observe({
      prefs <- get_prefs()
      if (!is.null(prefs$unit_system)) {
        updateRadioButtons(session, "unit_system", selected = prefs$unit_system)
      }
    })

    observeEvent(input$save_prefs, {
      save_prefs(list(unit_system = input$unit_system))
      showNotification("Preferences saved", type = "message")
    })

    output$densities_table <- DT::renderDataTable({
      all_densities <- list_all_densities()
      DT::datatable(
        all_densities,
        rownames = FALSE,
        selection = "single",
        options = list(pageLength = 10)
      )
    })

    observeEvent(input$add_density_btn, {
      ing_name <- trimws(input$new_density_ingredient)
      ing_value <- as.numeric(input$new_density_value)
      if (!nzchar(ing_name)) {
        showNotification("Please enter an ingredient name", type = "error")
        return()
      }
      if (is.null(ing_value) || is.na(ing_value) || ing_value <= 0) {
        showNotification(
          "Please enter a valid density value (must be > 0)",
          type = "error"
        )
        return()
      }
      add_custom_density(ing_name, ing_value)
      showNotification(
        sprintf("Added custom density: %s = %.2f g/ml", ing_name, ing_value),
        type = "message"
      )
      updateTextInput(session, "new_density_ingredient", value = "")
      updateNumericInput(session, "new_density_value", value = 1.0)
      output$densities_table <- DT::renderDataTable({
        DT::datatable(
          list_all_densities(),
          rownames = FALSE,
          selection = "single",
          options = list(pageLength = 10)
        )
      })
    })

    observeEvent(input$delete_density_btn, {
      sel <- input$densities_table_rows_selected
      if (is.null(sel) || length(sel) == 0) {
        showNotification("Select a density row to delete", type = "error")
        return()
      }
      df <- list_all_densities()
      row <- df[sel, ]
      if (row$source != "custom") {
        showNotification("Only custom densities can be deleted", type = "warning")
        return()
      }
      delete_custom_density(row$ingredient)
      showNotification(
        sprintf("Deleted density for '%s'", row$ingredient),
        type = "message"
      )
      output$densities_table <- DT::renderDataTable({
        DT::datatable(
          list_all_densities(),
          rownames = FALSE,
          selection = "single",
          options = list(pageLength = 10)
        )
      })
    })

    output$export_json <- downloadHandler(
      filename = function() {
        paste0("recipes_export_", format(Sys.time(), "%Y%m%d%H%M%S"), ".json")
      },
      content = function(file) export_recipes_json(file)
    )

    output$export_csv <- downloadHandler(
      filename = function() {
        paste0("recipes_export_", format(Sys.time(), "%Y%m%d%H%M%S"), ".csv")
      },
      content = function(file) export_recipes_csv(file)
    )

    observeEvent(input$import_btn, {
      f <- input$import_file
      if (is.null(f)) {
        showNotification("No file selected", type = "error")
        return()
      }
      ext <- tools::file_ext(f$name)
      tryCatch(
        {
          if (tolower(ext) == "json") {
            import_recipes_json(f$datapath)
          } else if (tolower(ext) == "csv") {
            import_recipes_csv(f$datapath)
          } else {
            stop("Unsupported file type")
          }
          showNotification("Import completed", type = "message")
          refresh_data()
        },
        error = function(e) {
          showNotification(paste("Import failed:", e$message), type = "error")
        }
      )
    })

    observeEvent(input$backup_btn, {
      backup_db()
      showNotification("Backup created", type = "message")
    })

    observeEvent(input$restore_btn, {
      backups <- list_backups()
      if (length(backups) == 0) {
        showNotification("No backups available", type = "warning")
        return()
      }
      showModal(modalDialog(
        title = "Restore Backup",
        selectInput(
          ns("restore_select"),
          "Choose backup to restore:",
          choices = backups
        ),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("confirm_restore"), "Restore", class = "btn-warning")
        )
      ))
      observeEvent(
        input$confirm_restore,
        {
          path <- input$restore_select
          tryCatch(
            {
              restore_backup(path)
              showNotification("Backup restored successfully", type = "message")
              refresh_data()
            },
            error = function(e) {
              showNotification(paste("Restore failed:", e$message), type = "error")
            }
          )
          removeModal()
        },
        once = TRUE
      )
    })
  })
}
