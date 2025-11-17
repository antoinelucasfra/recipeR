#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  rv <- reactiveValues(
    recipes = list(),
    ingredients = list()
  )

  # Reactive variable for selected recipe detail
  selected_recipe <- NULL

  refresh_data <- function() {
    rv$recipes <- get_recipes()
    rv$ingredients <- get_ingredients()
  }

  refresh_data()

  # Statistics outputs for home tab
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

  # Toggle Advanced Filters Panel
  observeEvent(input$toggle_filters, {
    shinyjs::toggleClass("filter_panel", "show")
  })

  # Reset All Filters
  observeEvent(input$reset_filters, {
    shinyWidgets::updatePickerInput(session, "cuisine_filter", selected = NULL)
    shinyWidgets::updatePickerInput(session, "source_filter", selected = NULL)
    updateTextInput(session, "search_query", value = "")
    showNotification("Filters reset", type = "message")
  })

  # Select All Filters
  observeEvent(input$select_all_filters, {
    all_cuisines <- c("Chinese Cuisine", "Thai Cuisine", "Japanese Cuisine", "Indian Cuisine", "Vietnamese Cuisine")
    shinyWidgets::updatePickerInput(session, "cuisine_filter", selected = all_cuisines)
    showNotification("All cuisines selected", type = "message")
  })

  # Update source_filter choices dynamically
  observeEvent(rv$recipes, {
    sources <- unique(sapply(rv$recipes, function(r) r$source_url %||% ""))
    sources <- sources[sources != ""]
    shinyWidgets::updatePickerInput(session, "source_filter", choices = sources)
  })

  # Render DT table with filtering
  output$recipes_table_display <- DT::renderDataTable({
    recs <- rv$recipes

    # Apply search filter
    if (!is.null(input$search_query) && input$search_query != "") {
      search_lower <- tolower(input$search_query)
      recs <- Filter(function(r) grepl(search_lower, tolower(r$title)), recs)
    }

    # Apply cuisine filter
    if (!is.null(input$cuisine_filter) && length(input$cuisine_filter) > 0) {
      recs <- Filter(function(r) r$source %in% input$cuisine_filter, recs)
    }

    # Apply source filter
    if (!is.null(input$source_filter) && length(input$source_filter) > 0) {
      recs <- Filter(function(r) (r$source_url %||% "") %in% input$source_filter, recs)
    }

    # Build display dataframe
    if (length(recs) == 0) {
      df <- data.frame(Title = character(), Cuisine = character(), Ingredients = integer(), Steps = integer(), Added = character())
      return(DT::datatable(df))
    }

    df <- do.call(rbind, lapply(recs, function(r) {
      data.frame(
        Title = r$title,
        Cuisine = r$source,
        Ingredients = length(r$ingredients),
        Steps = length(r$instructions),
        Added = format(r$date_added, "%Y-%m-%d"),
        stringsAsFactors = FALSE
      )
    }))

    DT::datatable(
      df,
      rownames = FALSE,
      options = list(
        pageLength = 10,
        autoWidth = TRUE,
        columnDefs = list(
          list(width = "35%", targets = 0),
          list(width = "15%", targets = 1),
          list(width = "10%", targets = 2),
          list(width = "10%", targets = 3),
          list(width = "15%", targets = 4)
        )
      )
    )
  })

  # Browse page stats - calculate from filtered data
  output$browse_total_recipes <- renderText({
    recs <- rv$recipes
    if (!is.null(input$search_query) && input$search_query != "") {
      search_lower <- tolower(input$search_query)
      recs <- Filter(function(r) grepl(search_lower, tolower(r$title)), recs)
    }
    if (!is.null(input$cuisine_filter) && length(input$cuisine_filter) > 0) {
      recs <- Filter(function(r) r$source %in% input$cuisine_filter, recs)
    }
    if (!is.null(input$source_filter) && length(input$source_filter) > 0) {
      recs <- Filter(function(r) (r$source_url %||% "") %in% input$source_filter, recs)
    }
    length(recs)
  })

  output$browse_avg_ingredients <- renderText({
    recs <- rv$recipes
    if (!is.null(input$search_query) && input$search_query != "") {
      search_lower <- tolower(input$search_query)
      recs <- Filter(function(r) grepl(search_lower, tolower(r$title)), recs)
    }
    if (!is.null(input$cuisine_filter) && length(input$cuisine_filter) > 0) {
      recs <- Filter(function(r) r$source %in% input$cuisine_filter, recs)
    }
    if (!is.null(input$source_filter) && length(input$source_filter) > 0) {
      recs <- Filter(function(r) (r$source_url %||% "") %in% input$source_filter, recs)
    }
    if (length(recs) == 0) return("0")
    round(mean(sapply(recs, function(r) length(r$ingredients))), 1)
  })

  output$browse_avg_steps <- renderText({
    recs <- rv$recipes
    if (!is.null(input$search_query) && input$search_query != "") {
      search_lower <- tolower(input$search_query)
      recs <- Filter(function(r) grepl(search_lower, tolower(r$title)), recs)
    }
    if (!is.null(input$cuisine_filter) && length(input$cuisine_filter) > 0) {
      recs <- Filter(function(r) r$source %in% input$cuisine_filter, recs)
    }
    if (!is.null(input$source_filter) && length(input$source_filter) > 0) {
      recs <- Filter(function(r) (r$source_url %||% "") %in% input$source_filter, recs)
    }
    if (length(recs) == 0) return("0")
    round(mean(sapply(recs, function(r) length(r$instructions))), 1)
  })

  output$browse_cuisines_count <- renderText({
    recs <- rv$recipes
    if (!is.null(input$search_query) && input$search_query != "") {
      search_lower <- tolower(input$search_query)
      recs <- Filter(function(r) grepl(search_lower, tolower(r$title)), recs)
    }
    if (!is.null(input$cuisine_filter) && length(input$cuisine_filter) > 0) {
      recs <- Filter(function(r) r$source %in% input$cuisine_filter, recs)
    }
    if (!is.null(input$source_filter) && length(input$source_filter) > 0) {
      recs <- Filter(function(r) (r$source_url %||% "") %in% input$source_filter, recs)
    }
    if (length(recs) == 0) return("0")
    length(unique(sapply(recs, function(r) r$source)))
  })

  # Recipe detail modal - show selected recipe
  observeEvent(input$recipes_table_display_rows_selected, {
    if (is.null(input$recipes_table_display_rows_selected)) return()
    row_idx <- input$recipes_table_display_rows_selected
    recs <- rv$recipes
    
    # Apply same filters as table
    if (!is.null(input$search_query) && input$search_query != "") {
      search_lower <- tolower(input$search_query)
      recs <- Filter(function(r) grepl(search_lower, tolower(r$title)), recs)
    }
    if (!is.null(input$cuisine_filter) && length(input$cuisine_filter) > 0) {
      recs <- Filter(function(r) r$source %in% input$cuisine_filter, recs)
    }
    if (!is.null(input$source_filter) && length(input$source_filter) > 0) {
      recs <- Filter(function(r) (r$source_url %||% "") %in% input$source_filter, recs)
    }
    
    recs_list <- recs[names(recs)]
    if (row_idx > 0 && row_idx <= length(recs_list)) {
      selected_recipe <<- recs_list[[row_idx]]
      # Show modal using shinyjs
      shinyjs::runjs("$('#recipe_detail_modal').modal('show');")
    }
  })

  # Render recipe detail content
  output$recipe_detail_content <- renderUI({
    if (is.null(selected_recipe)) return(tags$p("No recipe selected"))
    
    r <- selected_recipe
    
    # Build ingredients list
    ingredients_html <- lapply(r$ingredients, function(i) {
      tags$div(
        class = "ingredient-item",
        icon("check-circle", style = "color: var(--success); margin-right: 0.5rem;"),
        strong(i$ingredient_name),
        if (!is.null(i$raw_text)) paste0(" (", i$raw_text, ")")
      )
    })
    
    # Build instructions list
    instructions_html <- lapply(seq_along(r$instructions), function(idx) {
      instr <- r$instructions[[idx]]
      tags$div(
        class = "step-item",
        span(class = "step-number", idx),
        instr$instruction_text
      )
    })
    
    list(
      # Recipe metadata
      tags$div(
        class = "recipe-metadata",
        tags$div(
          class = "recipe-metadata-item",
          tags$div(class = "label", "Cuisine"),
          tags$div(class = "value", r$source)
        ),
        tags$div(
          class = "recipe-metadata-item",
          tags$div(class = "label", "Ingredients"),
          tags$div(class = "value", length(r$ingredients))
        ),
        tags$div(
          class = "recipe-metadata-item",
          tags$div(class = "label", "Steps"),
          tags$div(class = "value", length(r$instructions))
        ),
        tags$div(
          class = "recipe-metadata-item",
          tags$div(class = "label", "Added"),
          tags$div(class = "value", format(r$date_added, "%b %d"))
        )
      ),
      
      # Ingredients section
      tags$div(
        class = "detail-section",
        tags$h6(icon("carrot"), "Ingredients"),
        tags$div(ingredients_html)
      ),
      
      # Instructions section
      tags$div(
        class = "detail-section",
        tags$h6(icon("list-check"), "Instructions"),
        tags$div(instructions_html)
      ),
      
      # Source URL if available
      if (!is.null(r$source_url) && r$source_url != "") {
        tags$div(
          class = "detail-section",
          tags$h6(icon("link"), "Source"),
          tags$a(href = r$source_url, target = "_blank", r$source_url, class = "btn btn-sm btn-outline-primary")
        )
      }
    )
  })

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

  # Clear recipe form
  observeEvent(input$clear_recipe, {
    updateTextInput(session, "new_title", value = "")
    updateTextInput(session, "new_source", value = "")
    updateTextInput(session, "new_source_url", value = "")
    updateTextAreaInput(session, "new_ingredients_raw", value = "")
    updateTextAreaInput(session, "new_instructions", value = "")
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
