#' @noRd
mod_shopping_ui <- function(id) {
  ns <- NS(id)
  tags$div(
    id = "pane-shopping",
    class = "content-pane",

    tags$div(
      class = "page-header",
      tags$h1(class = "page-title", "Shopping List"),
      tags$p(
        class = "page-subtitle",
        "Add manually or via a recipe\u2019s missing ingredients"
      )
    ),

    bslib::layout_columns(
      col_widths = c(6, 6),

      tags$div(
        bslib::card(
          class = "mb-3",
          bslib::card_body(
            class = "py-2",
            tags$div(
              style = "display:flex;gap:0.5rem;",
              textInput(
                ns("new_shop_item"),
                NULL,
                placeholder = "e.g., 2 cups flour",
                width = "100%"
              ),
              actionButton(
                ns("add_shop_item"),
                tagList(tags$i(class = "fas fa-plus"), " Add"),
                class = "btn btn-primary"
              )
            )
          )
        ),
        bslib::card(
          bslib::card_header(
            class = "d-flex justify-content-between align-items-center",
            tags$div(
              tags$i(class = "fas fa-cart-shopping"),
              tags$span(" Items", style = "font-weight:600;")
            ),
            tags$div(
              style = "display:flex;gap:0.5rem;",
              actionButton(
                ns("remove_checked_items"),
                tagList(tags$i(class = "fas fa-check-double"), " Done"),
                class = "btn btn-success btn-sm"
              ),
              actionButton(
                ns("clear_shop_list"),
                tagList(tags$i(class = "fas fa-trash"), " Clear"),
                class = "btn btn-danger btn-sm"
              )
            )
          ),
          bslib::card_body(uiOutput(ns("shopping_list_output")))
        )
      ),

      bslib::card(
        bslib::card_header(tags$h5(
          tags$i(
            class = "fas fa-lightbulb",
            style = "color:var(--bs-warning);margin-right:0.4rem;"
          ),
          "Tips"
        )),
        bslib::card_body(
          class = "text-muted",
          style = "font-size:0.85rem;",
          tags$ul(
            style = "padding-left:1.2rem;",
            tags$li(
              "Check items as you shop \u2014 then click Done to remove all checked."
            ),
            tags$li(
              'Open a recipe and click \u201cAdd missing\u201d to bulk-add missing ingredients.'
            ),
            tags$li("Update quantities in the inventory tab when you restock.")
          )
        )
      )
    )
  )
}

#' @noRd
mod_shopping_server <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$shopping_list_output <- renderUI({
      items <- rv$shopping
      if (length(items) == 0) {
        return(tags$p(class = "text-muted", "Shopping list is empty."))
      }
      rows <- lapply(seq_along(items), function(i) {
        item <- items[[i]]
        tags$div(
          style = "display:flex;align-items:center;padding:0.4rem 0;border-bottom:1px solid #f0f0f0;",
          checkboxInput(
            ns(paste0("check_shop_", i)),
            label = item$text,
            value = isTRUE(item$checked)
          ),
          actionButton(
            ns(paste0("remove_shop_", i)),
            NULL,
            icon = icon("times"),
            class = "btn btn-sm btn-outline-danger ms-2",
            title = "Remove"
          )
        )
      })
      tags$div(rows)
    })

    observe({
      items <- rv$shopping
      lapply(seq_along(items), function(i) {
        local({
          idx <- i
          observeEvent(
            input[[paste0("check_shop_", idx)]],
            {
              current <- get_shopping_list()
              if (idx <= length(current)) {
                current[[idx]]$checked <- input[[paste0("check_shop_", idx)]]
                save_shopping_list(current)
                rv$shopping <- current
              }
            },
            ignoreInit = TRUE,
            once = FALSE
          )
        })
      })
    })

    observe({
      items <- rv$shopping
      lapply(seq_along(items), function(i) {
        btn_id <- paste0("remove_shop_", i)
        local({
          idx <- i
          observeEvent(
            input[[btn_id]],
            {
              current <- get_shopping_list()
              if (idx <= length(current)) {
                updated <- current[-idx]
                save_shopping_list(updated)
                rv$shopping <- updated
              }
            },
            ignoreInit = TRUE,
            once = TRUE
          )
        })
      })
    })

    observeEvent(input$add_shop_item, {
      item <- trimws(input$new_shop_item)
      if (!nzchar(item)) {
        showNotification("Enter an item name", type = "error")
        return()
      }
      current <- get_shopping_list()
      existing_texts <- sapply(current, function(x) x$text)
      if (!(item %in% existing_texts)) {
        updated <- c(current, list(list(text = item, checked = FALSE)))
        save_shopping_list(updated)
        rv$shopping <- updated
      }
      updateTextInput(session, "new_shop_item", value = "")
      showNotification(
        sprintf("Added \u2018%s\u2019 to shopping list", item),
        type = "message"
      )
    })

    observeEvent(input$remove_checked_items, {
      current <- get_shopping_list()
      updated <- Filter(function(x) !isTRUE(x$checked), current)
      save_shopping_list(updated)
      rv$shopping <- updated
      showNotification("Checked items removed", type = "message")
    })

    observeEvent(input$clear_shop_list, {
      save_shopping_list(list())
      rv$shopping <- list()
      showNotification("Shopping list cleared", type = "message")
    })
  })
}
