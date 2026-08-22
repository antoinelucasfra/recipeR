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
            tags$span("Unit system preference", class = "visually-hidden"),
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
              showNotification(
                paste("Restore failed:", e$message),
                type = "error"
              )
            }
          )
          removeModal()
        },
        once = TRUE
      )
    })
  })
}
