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
    lines <- unlist(strsplit(as.character(text), "[\\r\\n]+"))
    lines <- trimws(lines)
    lines <- lines[lines != ""]
    lapply(seq_along(lines), function(i) {
      parsed <- parse_ingredient_line(lines[i])
      list(ingredient_name = parsed$name, raw_text = parsed$raw, quantity = parsed$quantity, unit = parsed$unit, is_optional = FALSE)
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
           actionButton(inputId = paste0("view_", r$recipe_id), label = "View", class = "btn-sm btn-primary"),
           actionButton(inputId = paste0("edit_", r$recipe_id), label = "Edit", class = "btn-sm btn-info"),
           actionButton(inputId = paste0("del_", r$recipe_id), label = "Delete", class = "btn-sm btn-danger")
      )
    })
    do.call(tagList, cards)
  })

  # Dynamic observers for view buttons: show modal with details
  observe({
    ids <- names(rv$recipes)
    lapply(ids, function(rid) {
      btn <- paste0("view_", rid)
      editbtn <- paste0("edit_", rid)
      delbtn <- paste0("del_", rid)
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
                       column(6, actionButton(inputId = paste0("addshop_", id_now), label = "Add missing to shopping list", class = "btn-success"),
                              actionButton(inputId = paste0("save_scaled_", id_now), label = "Save scaled as new recipe", class = "btn-primary")))
            ),
            easyClose = TRUE,
            footer = modalButton("Close")
          )
          showModal(modal)
          # react to scale changes by re-showing modal with scaled ingredient displays
          scale_input_id <- paste0("scale_", id_now)
          observeEvent(input[[scale_input_id]], {
            mult <- as.numeric(input[[scale_input_id]])
            if (is.null(mult) || is.na(mult)) mult <- 1
            scaled_ings <- lapply(r$ingredients, function(i) {
              si <- scale_ingredient(i, mult)
              if (!is.null(si$quantity_display) && !is.na(si$quantity_display)) paste0(si$quantity_display, " ", ifelse(is.null(si$unit) || is.na(si$unit), "", si$unit), " ", si$name) else si$raw
            })
            modal2 <- modalDialog(
              title = r$title,
              fluidPage(
                fluidRow(column(6, h5("Ingredients"), tags$ul(lapply(scaled_ings, function(x) tags$li(x)))),
                         column(6, h5("Instructions"), tags$ol(lapply(r$instructions, function(s) tags$li(s$instruction_text))))) ,
                fluidRow(column(6, numericInput(inputId = scale_input_id, label = "Scale servings (multiplier)", value = mult, min = 0.25, step = 0.25)),
                         column(6, actionButton(inputId = paste0("addshop_", id_now), label = "Add missing to shopping list", class = "btn-success")))
              ),
              easyClose = TRUE,
              footer = modalButton("Close")
            )
            removeModal()
            showModal(modal2)
          }, ignoreInit = TRUE)
        }, ignoreInit = TRUE)
        # Edit observer: open edit modal
        observeEvent(input[[editbtn]], {
          r <- rv$recipes[[id_now]]
          if (is.null(r)) return()
          ing_text <- paste(sapply(r$ingredients, function(i) if (!is.null(i$raw_text)) i$raw_text else i$ingredient_name), collapse = "\n")
          inst_text <- paste(sapply(r$instructions, function(s) s$instruction_text), collapse = "\n")
          edit_modal <- modalDialog(
            title = paste0("Edit: ", r$title),
            textInput("edit_title", "Title", value = r$title),
            textAreaInput("edit_ingredients", "Ingredients (one per line)", value = ing_text, rows = 8),
            textAreaInput("edit_instructions", "Instructions (one per line)", value = inst_text, rows = 8),
            footer = tagList(modalButton("Cancel"), actionButton("save_edit", "Save", class = "btn-primary"))
          )
          showModal(edit_modal)
          # handle save_edit for this modal
          observeEvent(input$save_edit, {
            # build updated recipe
            new_title <- input$edit_title
            new_ings <- parse_ingredients_raw(input$edit_ingredients)
            inst_lines <- unlist(strsplit(as.character(input$edit_instructions), "[\\r\\n]+"))
            inst_lines <- trimws(inst_lines)
            inst_lines <- inst_lines[inst_lines != ""]
            updated <- r
            updated$title <- new_title
            updated$ingredients <- new_ings
            updated$instructions <- lapply(seq_along(inst_lines), function(i) list(step_number = i, instruction_text = inst_lines[i]))
            update_recipe(id_now, updated)
            showNotification(sprintf("Updated '%s'", new_title), type = "message")
            refresh_data()
            removeModal()
          }, once = TRUE)
        }, ignoreInit = TRUE)

        # Delete observer: confirm then delete
        observeEvent(input[[delbtn]], {
          r <- rv$recipes[[id_now]]
          if (is.null(r)) return()
          confirm <- modalDialog(title = paste0("Delete: ", r$title), p("Are you sure you want to delete this recipe?"), footer = tagList(modalButton("Cancel"), actionButton("confirm_delete", "Delete", class = "btn-danger")))
          showModal(confirm)
          observeEvent(input$confirm_delete, {
            delete_recipe(id_now)
            showNotification(sprintf("Deleted '%s'", r$title), type = "message")
            refresh_data()
            removeModal()
          }, once = TRUE)
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

  # Export handlers
  output$export_json <- downloadHandler(
    filename = function() paste0("recipes_export_", format(Sys.time(), "%Y%m%d%H%M%S"), ".json"),
    content = function(file) {
      export_recipes_json(file)
    }
  )

  output$export_csv <- downloadHandler(
    filename = function() paste0("recipes_export_", format(Sys.time(), "%Y%m%d%H%M%S"), ".csv"),
    content = function(file) {
      export_recipes_csv(file)
    }
  )

  # Import file
  observeEvent(input$import_btn, {
    f <- input$import_file
    if (is.null(f)) {
      showNotification("No file selected", type = "error")
      return()
    }
    path <- f$datapath
    ext <- tools::file_ext(f$name)
    tryCatch({
      if (tolower(ext) == "json") {
        import_recipes_json(path)
      } else if (tolower(ext) %in% c("csv")) {
        import_recipes_csv(path)
      } else {
        stop("Unsupported file type")
      }
      showNotification("Import completed", type = "message")
      refresh_data()
    }, error = function(e) {
      showNotification(paste("Import failed:", e$message), type = "error")
    })
  })

  # Backup and restore
  observeEvent(input$backup_btn, {
    tryCatch({
      dest <- backup_db()
      showNotification(paste("Backup created:", dest), type = "message")
      # update restore choices
      choices <- list_backups()
      updateSelectInput(session, "restore_choice", choices = choices)
    }, error = function(e) showNotification(paste("Backup failed:", e$message), type = "error"))
  })

  observeEvent(input$restore_btn, {
    choice <- input$restore_choice
    if (is.null(choice) || choice == "") {
      showNotification("No backup selected", type = "error")
      return()
    }
    tryCatch({
      restore_backup(choice)
      showNotification("Restore completed. Reloading data.", type = "message")
      refresh_data()
    }, error = function(e) showNotification(paste("Restore failed:", e$message), type = "error"))
  })

  # On start, populate backup choices
  observe({
    choices <- list_backups()
    updateSelectInput(session, "restore_choice", choices = choices)
  })

  # Preferences: load and save
  observe({
    prefs <- get_prefs()
    if (!is.null(prefs$unit_system)) {
      updateRadioButtons(session, "unit_system", selected = prefs$unit_system)
    }
  })

  observeEvent(input$save_prefs, {
    prefs <- list(unit_system = input$unit_system)
    save_prefs(prefs)
    showNotification("Preferences saved", type = "message")
  })

  # Handler: save scaled recipe as a new recipe
  observe({
    ids <- names(rv$recipes)
    lapply(ids, function(rid) {
      savebtn <- paste0("save_scaled_", rid)
      local({
        id_now <- rid
        observeEvent(input[[savebtn]], {
          r <- rv$recipes[[id_now]]
          if (is.null(r)) return()
          scale_input_id <- paste0("scale_", id_now)
          mult <- as.numeric(input[[scale_input_id]])
          if (is.null(mult) || is.na(mult)) mult <- 1
          prefs <- get_prefs()
          sys <- if (!is.null(prefs$unit_system)) prefs$unit_system else "american"
          # build scaled ingredients
          scaled_ings <- lapply(r$ingredients, function(i) {
            # keep original values and add scaled values
            orig_qty <- if (!is.null(i$quantity)) i$quantity else NA_real_
            orig_unit <- if (!is.null(i$unit)) i$unit else NA_character_
            if (!is.na(orig_qty)) {
              new_qty <- as.numeric(orig_qty) * mult
              # attempt density-based conversion using ingredient name
              conv <- convert_with_density(new_qty, orig_unit, target_system = sys, ingredient_name = i$ingredient_name)
              scaled_qty <- conv$quantity
              scaled_unit <- conv$unit
              scaled_display <- conv$display
            } else {
              scaled_qty <- NA_real_
              scaled_unit <- orig_unit
              scaled_display <- i$raw_text
            }
            list(
              ingredient_name = i$ingredient_name,
              orig_quantity = orig_qty,
              orig_unit = orig_unit,
              scaled_quantity = scaled_qty,
              scaled_unit = scaled_unit,
              raw_text = if (!is.null(scaled_display) && !is.na(scaled_display)) scaled_display else i$raw_text
            )
          })
          # scaled instructions same as original
          scaled_recipe <- list(title = paste0(r$title, " (scaled x", mult, ")"), source = "manual", source_url = NULL, ingredients = scaled_ings, instructions = r$instructions, date_added = Sys.time(), last_modified = Sys.time())
          add_recipe(scaled_recipe)
          showNotification(sprintf("Saved scaled recipe '%s'", scaled_recipe$title), type = "message")
          refresh_data()
        }, ignoreInit = TRUE)
      })
    })
  })

  # Densities: render table with all built-in and custom densities
  output$densities_table <- DT::renderDataTable({
    all_densities <- list_all_densities()
    DT::datatable(all_densities, rownames = FALSE, options = list(pageLength = 10))
  })

  # Densities: add custom density handler
  observeEvent(input$add_density_btn, {
    ing_name <- trimws(input$new_density_ingredient)
    ing_value <- as.numeric(input$new_density_value)

    # Validate inputs
    if (is.null(ing_name) || ing_name == "") {
      showNotification("Please enter an ingredient name", type = "error")
      return()
    }
    if (is.null(ing_value) || is.na(ing_value) || ing_value <= 0) {
      showNotification("Please enter a valid density value (must be > 0)", type = "error")
      return()
    }

    # Add custom density
    add_custom_density(ing_name, ing_value)
    showNotification(sprintf("Added custom density: %s = %.2f g/ml", ing_name, ing_value), type = "message")

    # Clear input fields
    updateTextInput(session, "new_density_ingredient", value = "")
    updateNumericInput(session, "new_density_value", value = 1.0)
  })

}
