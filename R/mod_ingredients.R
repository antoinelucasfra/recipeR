#' @noRd
mod_ingredients_ui <- function(id) {
  ns <- NS(id)
  tags$div(
    id = "pane-ingredients",
    class = "content-pane",

    tags$div(
      class = "page-header",
      tags$h1(class = "page-title", "Ingredient Inventory"),
      tags$p(
        class = "page-subtitle",
        "Track what you have -- drives recipe match scores"
      )
    ),

    bslib::layout_columns(
      col_widths = c(8, 4),

      tags$div(
        bslib::card(
          class = "mb-3",
          bslib::card_header(tags$h5("Add Ingredient")),
          bslib::card_body(
            bslib::layout_columns(
              col_widths = c(4, 4, 4),
              textInput(ns("ing_name"), "Name", width = "100%"),
              numericInput(
                ns("ing_qty"),
                "Quantity",
                value = 1,
                min = 0,
                width = "100%"
              ),
              textInput(
                ns("ing_unit"),
                "Unit",
                placeholder = "cup, tsp, g...",
                width = "100%"
              )
            ),
            tags$div(
              class = "mt-3",
              actionButton(
                ns("save_ing"),
                tagList(tags$i(class = "fas fa-plus"), " Add"),
                class = "btn btn-primary"
              )
            )
          )
        ),
        DT::dataTableOutput(ns("ingredients_table"))
      ),

      bslib::card(
        bslib::card_header(tags$h5("Inventory Stats")),
        bslib::card_body(uiOutput(ns("inventory_stats")))
      )
    )
  )
}

#' @noRd
mod_ingredients_server <- function(id, rv, refresh_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$inventory_stats <- renderUI({
      ings <- rv$ingredients
      if (length(ings) == 0) {
        return(tags$p(class = "text-muted", "No ingredients yet."))
      }
      n_staple <- sum(sapply(ings, function(i) isTRUE(i$is_staple)))
      tagList(
        tags$div(class = "stat-number", length(ings)),
        tags$p(class = "text-muted", "Total items"),
        tags$hr(),
        tags$p(paste0(n_staple, " staple item(s)"))
      )
    })

    output$ingredients_table <- DT::renderDataTable({
      ings <- rv$ingredients
      if (length(ings) == 0) {
        return(DT::datatable(data.frame()))
      }
      df <- do.call(
        rbind,
        lapply(ings, function(i) {
          data.frame(
            id = i$id,
            name = i$ingredient_name,
            qty = i$quantity_available,
            unit = ifelse(is.null(i$unit), "", i$unit),
            stringsAsFactors = FALSE
          )
        })
      )
      DT::datatable(df, rownames = FALSE, options = list(pageLength = 15))
    })

    observeEvent(input$save_ing, {
      name <- input$ing_name
      if (is.null(name) || !nzchar(name)) {
        showNotification("Provide ingredient name", type = "error")
        return()
      }
      ing <- list(
        ingredient_name = name,
        quantity_available = input$ing_qty,
        unit = input$ing_unit,
        category = NA,
        is_staple = FALSE
      )
      add_ingredient(ing)
      showNotification(
        sprintf("Added/updated ingredient '%s'", name),
        type = "message"
      )
      updateTextInput(session, "ing_name", value = "")
      updateNumericInput(session, "ing_qty", value = NA)
      updateTextInput(session, "ing_unit", value = "")
      refresh_data()
    })

    observeEvent(input$delete_ing_btn, {
      id <- input$delete_ing_btn
      if (!is.null(id) && nzchar(id)) {
        delete_ingredient(id)
        showNotification("Ingredient removed", type = "message")
        refresh_data()
      }
    })

    observeEvent(input$ingredients_table_rows_selected, {
      sel <- input$ingredients_table_rows_selected
      if (is.null(sel) || length(sel) == 0) return()
      ings <- as.list(rv$ingredients)
      if (sel < 1 || sel > length(ings)) return()
      id <- ings[[sel]]$id
      if (is.null(id)) return()
      showModal(modalDialog(
        title = "Remove ingredient?",
        p(paste("Remove", ings[[sel]]$ingredient_name, "from inventory?")),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("confirm_del_ing"), "Remove", class = "btn-danger")
        )
      ))
      observeEvent(
        input$confirm_del_ing,
        {
          delete_ingredient(id)
          showNotification("Ingredient removed", type = "message")
          refresh_data()
          removeModal()
        },
        once = TRUE
      )
    })
  })
}
