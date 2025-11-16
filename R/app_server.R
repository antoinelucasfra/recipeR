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
    shopping = character()
  )

  refresh_data <- function() {
    rv$recipes <- get_recipes()
    rv$ingredients <- get_ingredients()
    rv$shopping <- get_shopping_list()
  }

  refresh_data()

  # Simple ingredient parser: one-per-line -> ingredient_name = line trimmed
  parse_ingredients_raw <- function(text) {
    lines <- unlist(strsplit(as.character(text), "[\r\n]+"))
    lines <- trimws(lines)
    lines <- lines[lines != ""]
    lapply(seq_along(lines), function(i) {
      list(ingredient_name = lines[i], raw_text = lines[i], quantity = NA, unit = NA, is_optional = FALSE)
    })
  }

  # Save new recipe
  observeEvent(input$save_recipe, {
    title <- input$new_title
    if (is.null(title) || title == "") {
      showNotification("Please provide a recipe title.", type = "error")
      return()
    }
    instr_lines <- unlist(strsplit(as.character(input$new_instructions), "[\r\n]+"))
    instr_lines <- trimws(instr_lines)
    instr_lines <- instr_lines[instr_lines != ""]
    recipe <- list(
      title = title,
      source = input$new_source,
      source_url = NULL,
      ingredients = parse_ingredients_raw(input$new_ingredients_raw),
      instructions = lapply(seq_along(instr_lines), function(i) list(step_number = i, instruction_text = instr_lines[i])),
      date_added = Sys.time(),
      last_modified = Sys.time()
    )
    added <- add_recipe(recipe)
    showNotification(sprintf("Saved recipe '%s'", added$title), type = "message")
    updateTextInput(session, "new_title", value = "")
    updateTextAreaInput(session, "new_ingredients_raw", value = "")
    updateTextAreaInput(session, "new_instructions", value = "")
    refresh_data()
  })

  output$new_recipe_preview <- renderPrint({
    list(title = input$new_title, ingredients = parse_ingredients_raw(input$new_ingredients_raw))
  })

  # Ingredients: add/update
  observeEvent(input$save_ing, {
    name <- input$ing_name
    if (is.null(name) || name == "") {
      showNotification("Provide ingredient name", type = "error")
      return()
    }
    ing <- list(ingredient_name = name, quantity_available = input$ing_qty, unit = input$ing_unit, category = NA, is_staple = FALSE)
    add_ingredient(ing)
    showNotification(sprintf("Added/updated ingredient '%s'", name), type = "message")
    updateTextInput(session, "ing_name", value = "")
    updateNumericInput(session, "ing_qty", value = NA)
    updateTextInput(session, "ing_unit", value = "")
    refresh_data()
  })

  # Matching: simple name-based matching
  calc_match <- function(recipe, inventory) {
    if (is.null(recipe$ingredients) || length(recipe$ingredients) == 0) return(0)
    inv_names <- tolower(sapply(inventory, function(x) if (!is.null(x$ingredient_name)) x$ingredient_name else ""))
    req_names <- tolower(sapply(recipe$ingredients, function(i) if (!is.null(i$ingredient_name)) i$ingredient_name else ""))
    matched <- sum(sapply(req_names, function(r) any(grepl(r, inv_names, fixed = TRUE))))
    round(100 * matched / length(req_names))
  }

  # Render recipes table
  output$recipes_table <- DT::renderDataTable({
    recs <- rv$recipes
    if (length(recs) == 0) return(DT::datatable(data.frame()))
    df <- do.call(rbind, lapply(recs, function(r) {
      data.frame(recipe_id = r$recipe_id, title = r$title, stringsAsFactors = FALSE)
    }))
    DT::datatable(df, selection = 'single', rownames = FALSE)
  })

  # Render recipe cards with view button
  output$recipes_cards <- renderUI({
    recs <- rv$recipes
    inv <- rv$ingredients
    if (length(recs) == 0) return(tags$p("No recipes yet"))
    cards <- lapply(recs, function(r) {
      pct <- calc_match(r, inv)
      if (is.null(pct)) pct <- 0
      tags$div(class = "recipe-card well",
               h4(r$title),
               tags$p(sprintf("Match: %s%%", pct)),
               actionButton(inputId = paste0("view_", r$recipe_id), label = "View", class = "btn-sm btn-primary")
      )
    })
    do.call(tagList, cards)
  })

  # Dynamic observers for view buttons: show modal with details
  observe({
    ids <- names(rv$recipes)
    lapply(ids, function(rid) {
      btn <- paste0("view_", rid)
      # create a local binding so each observer captures the right id
      local({
        id_now <- rid
        observeEvent(input[[btn]], {
          r <- rv$recipes[[id_now]]
          if (is.null(r)) return()
          inv <- rv$ingredients
          # compute missing ingredients
          inv_names <- tolower(sapply(inv, function(x) if (!is.null(x$ingredient_name)) x$ingredient_name else ""))
          req_names <- sapply(r$ingredients, function(i) i$ingredient_name)
          missing <- req_names[!sapply(tolower(req_names), function(rr) any(grepl(rr, inv_names, fixed = TRUE)))]

          modal <- modalDialog(
            title = r$title,
            fluidPage(
              fluidRow(column(6, h5("Ingredients"), tags$ul(lapply(r$ingredients, function(i) tags$li(i$raw_text)))),
                       column(6, h5("Instructions"), tags$ol(lapply(r$instructions, function(s) tags$li(s$instruction_text))))) ,
              fluidRow(column(6, numericInput(inputId = paste0("scale_", id_now), label = "Scale servings (multiplier)", value = 1, min = 0.25, step = 0.25)),
                       column(6, actionButton(inputId = paste0("addshop_", id_now), label = "Add missing to shopping list", class = "btn-success")))
            ),
            easyClose = TRUE,
            footer = modalButton("Close")
          )
          showModal(modal)
        }, ignoreInit = TRUE)
        # observer for add-to-shopping button
        addbtn <- paste0("addshop_", rid)
        observeEvent(input[[addbtn]], {
          r <- rv$recipes[[rid]]
          if (is.null(r)) return()
          inv <- rv$ingredients
          inv_names <- tolower(sapply(inv, function(x) if (!is.null(x$ingredient_name)) x$ingredient_name else ""))
          req_names <- sapply(r$ingredients, function(i) i$ingredient_name)
          missing <- req_names[!sapply(tolower(req_names), function(rr) any(grepl(rr, inv_names, fixed = TRUE)))]
          if (length(missing) == 0) {
            showNotification("No missing ingredients to add.", type = "message")
            return()
          }
          # combine into shopping list (append) and persist
          rv$shopping <- unique(c(rv$shopping, missing))
          save_shopping_list(rv$shopping)
          showNotification(sprintf("Added %d items to shopping list", length(missing)), type = "message")
          removeModal()
        }, ignoreInit = TRUE)
      })
    })
  })

  # Ingredients table
  output$ingredients_table <- DT::renderDataTable({
    ings <- rv$ingredients
    if (length(ings) == 0) return(DT::datatable(data.frame()))
    df <- do.call(rbind, lapply(ings, function(i) {
      data.frame(id = i$id, name = i$ingredient_name, qty = i$quantity_available, unit = ifelse(is.null(i$unit), "", i$unit), stringsAsFactors = FALSE)
    }))
    DT::datatable(df, rownames = FALSE)
  })

  output$shopping_list <- renderPrint({
    if (length(rv$shopping) == 0) cat("Shopping list is empty\n") else cat(paste(rv$shopping, collapse = "\n"))
  })

}
