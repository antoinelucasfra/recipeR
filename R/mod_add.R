#' @noRd
mod_add_ui <- function(id) {
  ns <- NS(id)
  tags$div(
    id = "pane-add",
    class = "content-pane",

    tags$div(
      class = "page-header",
      tags$h1(class = "page-title", "Add New Recipe"),
      tags$p(
        class = "page-subtitle",
        "Ingredients are parsed automatically from plain text"
      )
    ),

    bslib::layout_columns(
      col_widths = c(7, 5),

      bslib::card(
        bslib::card_header(tags$h5("Recipe Details")),
        bslib::card_body(
          textInput(
            ns("new_title"),
            "Title",
            placeholder = "e.g., Vegetable Pad Thai",
            width = "100%"
          ),
          bslib::layout_columns(
            col_widths = c(6, 6),
            textInput(
              ns("new_source"),
              "Cuisine / Source",
              placeholder = "e.g., Thai",
              width = "100%"
            ),
            numericInput(
              ns("new_servings"),
              "Servings",
              value = NA,
              min = 1,
              step = 1,
              width = "100%"
            )
          ),
          textInput(ns("new_source_url"), "Source URL (optional)", width = "100%"),
          textInput(ns("new_image_url"), "Image URL (optional)", width = "100%"),
          tags$div(
            tags$label("Tags"),
            tags$small(
              class = "text-muted d-block mb-1",
              "Press Enter or comma after each tag"
            ),
            selectizeInput(
              ns("new_tags"),
              NULL,
              choices = c(),
              selected = c(),
              multiple = TRUE,
              options = list(
                create = TRUE,
                delimiter = ",",
                placeholder = "e.g., Quick, Vegan, Asian\u2026"
              ),
              width = "100%"
            )
          ),
          tags$label("Ingredients", style = "margin-top:0.5rem;"),
          tags$small(
            class = "text-muted d-block mb-1",
            'One per line \u2014 e.g. "1 1/2 cups flour"'
          ),
          textAreaInput(
            ns("new_ingredients_raw"),
            NULL,
            placeholder = "1 1/2 cups flour\n2 large eggs\n3 tbsp sugar",
            rows = 6,
            width = "100%"
          ),
          tags$label("Instructions", style = "margin-top:0.5rem;"),
          tags$small(class = "text-muted d-block mb-1", "One step per line"),
          textAreaInput(
            ns("new_instructions"),
            NULL,
            placeholder = "Mix dry ingredients\nAdd wet ingredients\nBake 30 min at 350\u00b0F",
            rows = 6,
            width = "100%"
          ),
          tags$div(
            class = "mt-3",
            style = "display:flex;gap:0.5rem;",
            actionButton(
              ns("save_recipe"),
              tagList(tags$i(class = "fas fa-floppy-disk"), " Save Recipe"),
              class = "btn btn-primary btn-lg"
            ),
            actionButton(
              ns("clear_recipe"),
              "Clear",
              class = "btn btn-secondary btn-lg"
            )
          )
        )
      ),

      bslib::card(
        bslib::card_header(
          class = "d-flex align-items-center gap-2",
          tags$i(class = "fas fa-eye", style = "color:var(--bs-primary)"),
          tags$h5("Live Preview", style = "margin:0")
        ),
        bslib::card_body(uiOutput(ns("ingredient_preview")))
      )
    )
  )
}

#' @noRd
mod_add_server <- function(id, rv, refresh_data) {
  moduleServer(id, function(input, output, session) {
    parse_ingredients_raw <- function(text) {
      lines <- unlist(strsplit(as.character(text), "[\\r\\n]+"))
      lines <- trimws(lines)
      lines <- lines[nzchar(lines)]
      lapply(seq_along(lines), function(i) {
        parsed <- parse_ingredient_line(lines[i])
        list(
          ingredient_name = parsed$name,
          raw_text = parsed$raw,
          quantity = parsed$quantity,
          unit = parsed$unit,
          is_optional = FALSE
        )
      })
    }

    output$ingredient_preview <- renderUI({
      raw <- input$new_ingredients_raw
      if (is.null(raw) || !nzchar(trimws(raw))) {
        return(tags$p(
          class = "text-muted fst-italic",
          "Ingredients will preview here as you type..."
        ))
      }
      lines <- trimws(unlist(strsplit(as.character(raw), "[\\r\\n]+")))
      lines <- lines[nzchar(lines)]
      if (length(lines) == 0) {
        return(tags$p(
          class = "text-muted fst-italic",
          "Ingredients will preview here as you type..."
        ))
      }
      rows <- lapply(lines, function(line) {
        p <- parse_ingredient_line(line)
        qty_str <- if (!is.null(p$quantity) && !is.na(p$quantity)) as.character(p$quantity) else ""
        unit_str <- if (!is.null(p$unit) && !is.na(p$unit) && nzchar(p$unit)) p$unit else ""
        name_str <- if (!is.null(p$name) && nzchar(p$name)) p$name else ""
        tags$div(
          class = "preview-ingredient-row",
          tags$span(class = "preview-qty", qty_str),
          tags$span(class = "preview-unit", unit_str),
          tags$span(class = "preview-name", name_str)
        )
      })
      tagList(
        tags$p(
          class = "text-muted",
          style = "font-size:0.8rem;margin-bottom:0.5rem;",
          paste0(length(lines), " ingredient(s) detected")
        ),
        tags$div(class = "preview-ingredients-list", rows)
      )
    })

    observeEvent(input$save_recipe, {
      title <- input$new_title
      if (is.null(title) || !nzchar(title)) {
        showNotification("Please provide a recipe title.", type = "error")
        return()
      }
      instr_lines <- trimws(unlist(strsplit(
        as.character(input$new_instructions),
        "[\r\n]+"
      )))
      instr_lines <- instr_lines[nzchar(instr_lines)]
      src_url <- trimws(input$new_source_url)
      img_url <- trimws(input$new_image_url %||% "")
      servings_raw <- suppressWarnings(as.numeric(input$new_servings))

      recipe <- list(
        title = title,
        source = input$new_source,
        source_url = if (nzchar(src_url)) src_url else NULL,
        ingredients = parse_ingredients_raw(input$new_ingredients_raw),
        instructions = lapply(seq_along(instr_lines), function(i) {
          list(step_number = i, instruction_text = instr_lines[i])
        }),
        tags = if (!is.null(input$new_tags)) input$new_tags else character(0),
        servings = if (!is.na(servings_raw)) servings_raw else NULL,
        image_url = if (nzchar(img_url)) img_url else NULL,
        date_added = Sys.time(),
        last_modified = Sys.time()
      )
      added <- add_recipe(recipe)
      showNotification(sprintf("Saved recipe \u2018%s\u2019", added$title), type = "message")
      updateTextInput(session, "new_title", value = "")
      updateTextInput(session, "new_source", value = "")
      updateTextInput(session, "new_source_url", value = "")
      updateTextAreaInput(session, "new_ingredients_raw", value = "")
      updateTextAreaInput(session, "new_instructions", value = "")
      updateSelectizeInput(session, "new_tags", selected = character(0))
      updateTextInput(session, "new_image_url", value = "")
      updateNumericInput(session, "new_servings", value = NA)
      refresh_data()
    })

    observeEvent(input$clear_recipe, {
      updateTextInput(session, "new_title", value = "")
      updateTextInput(session, "new_source", value = "")
      updateTextInput(session, "new_source_url", value = "")
      updateTextAreaInput(session, "new_ingredients_raw", value = "")
      updateTextAreaInput(session, "new_instructions", value = "")
      updateSelectizeInput(session, "new_tags", selected = character(0))
      updateTextInput(session, "new_image_url", value = "")
      updateNumericInput(session, "new_servings", value = NA)
    })
  })
}
