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
    shopping = character(),
    compare_pair = NULL,
    selected_card_ids = character() # tracks cards selected for compare
  )

  # FIX P1: selected_recipe as reactiveVal so renderUI auto-invalidates
  selected_recipe <- reactiveVal(NULL)

  refresh_data <- function() {
    rv$recipes <- get_recipes()
    rv$ingredients <- get_ingredients()
    rv$shopping <- get_shopping_list()
  }

  refresh_data()

  # ---------------------------------------------------------------------------
  # P3: Single filtered_recipes reactive — eliminates 7 copy-pastes
  # ---------------------------------------------------------------------------
  filtered_recipes <- reactive({
    recs <- rv$recipes
    if (!is.null(input$search_query) && nzchar(input$search_query)) {
      sq <- tolower(input$search_query)
      recs <- Filter(
        function(r) grepl(sq, tolower(r$title), fixed = TRUE),
        recs
      )
    }
    if (!is.null(input$cuisine_filter) && length(input$cuisine_filter) > 0) {
      recs <- Filter(function(r) r$source %in% input$cuisine_filter, recs)
    }
    if (!is.null(input$source_filter) && length(input$source_filter) > 0) {
      recs <- Filter(
        function(r) (r$source_url %||% "") %in% input$source_filter,
        recs
      )
    }
    recs
  })

  # ---------------------------------------------------------------------------
  # Statistics outputs for home tab
  # ---------------------------------------------------------------------------
  output$stat_total_recipes <- renderText({
    length(rv$recipes)
  })

  output$stat_cuisines <- renderText({
    if (length(rv$recipes) == 0) {
      return("0")
    }
    length(unique(sapply(rv$recipes, function(r) r$source)))
  })

  output$stat_ingredients <- renderText({
    length(rv$ingredients)
  })

  output$stat_avg_ingredients <- renderText({
    if (length(rv$recipes) == 0) {
      return("0")
    }
    round(mean(sapply(rv$recipes, function(r) length(r$ingredients))), 1)
  })

  # ---------------------------------------------------------------------------
  # P1 FIX: Filter panel show/hide — use shinyjs::toggle instead of toggleClass
  # ---------------------------------------------------------------------------
  observeEvent(input$toggle_filters, {
    shinyjs::toggle("filter_panel")
  })

  # ---------------------------------------------------------------------------
  # P3: Cuisine filter choices populated dynamically from rv$recipes
  # ---------------------------------------------------------------------------
  observeEvent(
    rv$recipes,
    {
      cuisines <- sort(unique(sapply(rv$recipes, function(r) {
        if (!is.null(r$source) && nzchar(r$source)) r$source else "Unknown"
      })))
      shinyWidgets::updatePickerInput(session, "cuisine_filter", choices = cuisines)

      sources <- unique(sapply(rv$recipes, function(r) r$source_url %||% ""))
      sources <- sort(sources[nzchar(sources)])
      shinyWidgets::updatePickerInput(session, "source_filter", choices = sources)
    },
    ignoreInit = TRUE
  )

  # Reset All Filters
  observeEvent(input$reset_filters, {
    shinyWidgets::updatePickerInput(session, "cuisine_filter", selected = character(0))
    shinyWidgets::updatePickerInput(session, "source_filter", selected = character(0))
    updateTextInput(session, "search_query", value = "")
    showNotification("Filters reset", type = "message")
  })

  # Select All Filters — derives from current dynamic choices
  observeEvent(input$select_all_filters, {
    all_cuisines <- sort(unique(sapply(rv$recipes, function(r) {
      if (!is.null(r$source) && nzchar(r$source)) r$source else "Unknown"
    })))
    shinyWidgets::updatePickerInput(
      session,
      "cuisine_filter",
      selected = all_cuisines
    )
    showNotification("All cuisines selected", type = "message")
  })

  # ---------------------------------------------------------------------------
  # Browse: recipe cards grid + stats — all use filtered_recipes()
  # ---------------------------------------------------------------------------
  output$recipe_cards_grid <- renderUI({
    recs <- filtered_recipes()
    inv <- rv$ingredients
    sel_ids <- rv$selected_card_ids

    if (length(recs) == 0) {
      return(tags$div(
        class = "recipe-cards-grid",
        tags$div(
          class = "empty-state",
          tags$i(class = "fas fa-book-open"),
          tags$h5("No recipes found"),
          tags$p("Try adjusting your search or filters.")
        )
      ))
    }

    cards <- lapply(recs, function(r) {
      rid <- r$recipe_id %||% r$id %||% ""
      pct <- if (length(inv) > 0) calculate_match(r, inv) else NA_integer_
      is_selected <- rid %in% sel_ids

      bar_class <- if (is.na(pct)) {
        "none"
      } else if (pct >= 80) {
        "high"
      } else if (pct >= 40) {
        "medium"
      } else {
        "low"
      }
      bar_pct <- if (is.na(pct)) 0L else as.integer(pct)
      match_label <- if (is.na(pct)) "\u2014" else paste0(pct, "%")

      tags$div(
        class = "recipe-card",
        style = if (is_selected) {
          "border-color:var(--accent);box-shadow:0 0 0 2px var(--accent-glow);"
        } else {
          ""
        },

        tags$div(
          class = "recipe-card-header",
          tags$div(class = "recipe-card-title", r$title),
          if (!is.null(r$source) && nzchar(r$source)) {
            tags$span(class = "cuisine-badge", r$source)
          }
        ),

        tags$div(
          class = "recipe-card-meta",
          tags$span(
            class = "recipe-meta-item",
            tags$i(class = "fas fa-carrot"),
            paste0(" ", length(r$ingredients), " ing.")
          ),
          tags$span(
            class = "recipe-meta-item",
            tags$i(class = "fas fa-list-ol"),
            paste0(" ", length(r$instructions), " steps")
          )
        ),

        tags$div(
          class = "match-bar-wrap",
          tags$div(
            class = "match-bar-track",
            tags$div(
              class = paste("match-bar-fill", bar_class),
              style = paste0("width:", bar_pct, "%;")
            )
          ),
          tags$span(class = "match-bar-label", match_label)
        ),

        tags$div(
          class = "recipe-card-actions",
          actionButton(
            paste0("view_", rid),
            tagList(tags$i(class = "fas fa-eye"), " View"),
            class = "btn btn-primary btn-sm"
          ),
          actionButton(
            paste0("edit_", rid),
            tagList(tags$i(class = "fas fa-pen"), " Edit"),
            class = "btn btn-secondary btn-sm"
          ),
          actionButton(
            paste0("del_", rid),
            tags$i(class = "fas fa-trash"),
            class = "btn btn-danger btn-sm",
            title = "Delete",
            `data-bs-toggle` = "tooltip"
          ),
          actionButton(
            paste0("cmp_", rid),
            if (is_selected) {
              tagList(tags$i(class = "fas fa-check"), " Selected")
            } else {
              tagList(tags$i(class = "fas fa-code-compare"), " Compare")
            },
            class = paste(
              "btn btn-sm ms-auto",
              if (is_selected) "btn-primary" else "btn-secondary"
            )
          )
        )
      )
    })

    tags$div(class = "recipe-cards-grid", cards)
  })

  output$browse_total_recipes <- renderText(length(filtered_recipes()))

  output$browse_avg_ingredients <- renderText({
    recs <- filtered_recipes()
    if (length(recs) == 0) {
      return("0")
    }
    round(mean(sapply(recs, function(r) length(r$ingredients))), 1)
  })

  output$browse_avg_steps <- renderText({
    recs <- filtered_recipes()
    if (length(recs) == 0) {
      return("0")
    }
    round(mean(sapply(recs, function(r) length(r$instructions))), 1)
  })

  output$browse_cuisines_count <- renderText({
    recs <- filtered_recipes()
    if (length(recs) == 0) {
      return("0")
    }
    length(unique(sapply(recs, function(r) r$source)))
  })

  # Compare button — uses rv$selected_card_ids populated by cmp_ buttons
  observeEvent(input$compare_selected, {
    sel_ids <- rv$selected_card_ids
    if (length(sel_ids) != 2) {
      showNotification(
        "Select exactly two recipes using the Compare buttons on each card.",
        type = "error"
      )
      return()
    }
    r1 <- rv$recipes[[sel_ids[1]]]
    r2 <- rv$recipes[[sel_ids[2]]]
    if (is.null(r1) || is.null(r2)) {
      showNotification("One or both selected recipes not found.", type = "error")
      return()
    }
    rv$compare_pair <- list(r1, r2)
    shinyjs::runjs(
      paste0(
        "(function(){",
        "var el=document.getElementById('recipe_compare_modal');",
        "if(el){var m=bootstrap.Modal.getInstance(el)||new bootstrap.Modal(el);",
        "m.show();}",
        "})()"
      )
    )
  })

  # ---------------------------------------------------------------------------
  # Recipe detail drawer — reactive to selected_recipe(), includes scaling
  # ---------------------------------------------------------------------------
  # drawer_scale holds current scale multiplier for the open recipe
  drawer_scale <- reactiveVal(1)

  output$recipe_detail_content <- renderUI({
    r <- selected_recipe()
    if (is.null(r)) {
      return(tags$p(class = "text-muted", "No recipe selected."))
    }

    rid <- r$recipe_id %||% r$id %||% ""
    mult <- drawer_scale()
    prefs <- get_prefs()
    sys <- if (!is.null(prefs$unit_system)) prefs$unit_system else "american"
    inv <- rv$ingredients

    # Determine missing ingredients
    inv_names <- tolower(sapply(inv, function(x) {
      if (!is.null(x$ingredient_name)) x$ingredient_name else ""
    }))
    req_names <- sapply(r$ingredients, function(i) i$ingredient_name)
    is_missing <- !sapply(tolower(req_names), function(rr) {
      any(
        grepl(rr, inv_names, fixed = TRUE) |
          grepl(inv_names, rr, fixed = TRUE)
      )
    })

    # Scale + convert ingredients
    scaled_ings <- lapply(seq_along(r$ingredients), function(idx) {
      i <- r$ingredients[[idx]]
      orig_qty <- if (!is.null(i$quantity) && !is.na(i$quantity)) i$quantity else NA_real_
      orig_unit <- if (!is.null(i$unit) && !is.na(i$unit)) i$unit else NA_character_
      if (!is.na(orig_qty)) {
        new_qty <- as.numeric(orig_qty) * mult
        conv <- tryCatch(
          convert_with_density(
            new_qty,
            orig_unit,
            target_system = sys,
            ingredient_name = i$ingredient_name
          ),
          error = function(e) {
            list(quantity = new_qty, unit = orig_unit, display = NA_character_)
          }
        )
        display <- if (!is.null(conv$display) && !is.na(conv$display)) {
          conv$display
        } else {
          paste(
            format(conv$quantity, digits = 3),
            conv$unit %||% "",
            i$ingredient_name
          )
        }
      } else {
        display <- if (!is.null(i$raw_text) && nzchar(i$raw_text)) {
          i$raw_text
        } else {
          i$ingredient_name
        }
      }
      list(display = display, missing = is_missing[[idx]])
    })

    ing_rows <- lapply(scaled_ings, function(si) {
      tags$div(
        class = paste("ingredient-row", if (isTRUE(si$missing)) "missing" else ""),
        tags$i(
          class = if (isTRUE(si$missing)) "fas fa-xmark" else "fas fa-check"
        ),
        si$display
      )
    })

    step_rows <- lapply(seq_along(r$instructions), function(idx) {
      tags$div(
        class = "step-row",
        tags$span(class = "step-num", idx),
        tags$span(r$instructions[[idx]]$instruction_text)
      )
    })

    scale_input_id <- paste0("drawer_scale_", rid)

    list(
      # Meta grid
      tags$div(
        class = "drawer-meta-grid",
        tags$div(
          class = "drawer-meta-item",
          tags$div(class = "dm-label", "Cuisine"),
          tags$div(class = "dm-value", r$source %||% "\u2014")
        ),
        tags$div(
          class = "drawer-meta-item",
          tags$div(class = "dm-label", "Ingredients"),
          tags$div(class = "dm-value", length(r$ingredients))
        ),
        tags$div(
          class = "drawer-meta-item",
          tags$div(class = "dm-label", "Steps"),
          tags$div(class = "dm-value", length(r$instructions))
        ),
        tags$div(
          class = "drawer-meta-item",
          tags$div(class = "dm-label", "Added"),
          tags$div(
            class = "dm-value",
            style = "font-size:0.85rem;",
            format(r$date_added, "%b %d")
          )
        )
      ),

      # Scale widget
      tags$div(
        class = "scale-widget",
        tags$div(
          class = "scale-widget-title",
          tags$i(class = "fas fa-scale-balanced"),
          " Scale Recipe"
        ),
        tags$div(
          style = "display:flex;align-items:center;gap:0.75rem;",
          numericInput(
            scale_input_id,
            NULL,
            value = mult,
            min = 0.25,
            step = 0.25,
            width = "100px"
          ),
          tags$span(class = "text-muted", style = "font-size:0.8rem;", "\u00d7 servings"),
          actionButton(
            paste0("addshop_", rid),
            tagList(tags$i(class = "fas fa-cart-plus"), " Add missing"),
            class = "btn btn-success btn-sm ms-auto",
            title = "Add missing ingredients to shopping list",
            `data-bs-toggle` = "tooltip"
          )
        )
      ),

      # Source link
      if (!is.null(r$source_url) && nzchar(r$source_url)) {
        tags$div(
          class = "drawer-section",
          tags$a(
            href = r$source_url,
            target = "_blank",
            class = "btn btn-outline-primary btn-sm",
            tagList(tags$i(class = "fas fa-link"), " Original Source")
          )
        )
      },

      # Ingredients
      tags$div(
        class = "drawer-section",
        tags$div(
          class = "drawer-section-title",
          tags$i(class = "fas fa-carrot"),
          paste0("Ingredients (x", mult, ")")
        ),
        ing_rows
      ),

      # Instructions
      tags$div(
        class = "drawer-section",
        tags$div(
          class = "drawer-section-title",
          tags$i(class = "fas fa-list-ol"),
          "Instructions"
        ),
        step_rows
      )
    )
  })

  # Render compare modal content
  output$recipe_compare_content <- renderUI({
    pair <- rv$compare_pair
    if (is.null(pair) || length(pair) != 2) {
      return(tags$p("No recipes selected for comparison."))
    }

    make_col <- function(r) {
      ings <- lapply(r$ingredients, function(i) {
        tags$li(if (!is.null(i$raw_text) && nzchar(i$raw_text)) i$raw_text else i$ingredient_name)
      })
      inst <- lapply(r$instructions, function(s) tags$li(s$instruction_text))
      tags$div(
        class = "col-md-6",
        tags$div(
          class = "panel",
          tags$div(
            class = "panel-header",
            tags$h5(r$title)
          ),
          tags$div(
            class = "panel-body",
            tags$div(
              class = "drawer-meta-grid",
              tags$div(
                class = "drawer-meta-item",
                tags$div(class = "dm-label", "Cuisine"),
                tags$div(class = "dm-value", r$source %||% "\u2014")
              ),
              tags$div(
                class = "drawer-meta-item",
                tags$div(class = "dm-label", "Ingredients"),
                tags$div(class = "dm-value", length(r$ingredients))
              ),
              tags$div(
                class = "drawer-meta-item",
                tags$div(class = "dm-label", "Steps"),
                tags$div(class = "dm-value", length(r$instructions))
              )
            ),
            tags$h6(
              style = "font-size:0.78rem;text-transform:uppercase;letter-spacing:0.5px;
                       font-weight:700;color:var(--text-muted);margin:1rem 0 0.5rem;",
              "Ingredients"
            ),
            tags$ul(
              ings,
              style = "max-height:220px;overflow:auto;padding-left:1rem;font-size:0.85rem;"
            ),
            tags$h6(
              style = "font-size:0.78rem;text-transform:uppercase;letter-spacing:0.5px;
                       font-weight:700;color:var(--text-muted);margin:1rem 0 0.5rem;",
              "Instructions"
            ),
            tags$ol(
              inst,
              style = "max-height:220px;overflow:auto;padding-left:1rem;font-size:0.85rem;"
            )
          )
        )
      )
    }

    fluidRow(make_col(pair[[1]]), make_col(pair[[2]]))
  })

  # ---------------------------------------------------------------------------
  # Ingredient parser helper
  # ---------------------------------------------------------------------------
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

  # ---------------------------------------------------------------------------
  # P1 FIX: source_url correctly read on save
  # ---------------------------------------------------------------------------
  observeEvent(input$save_recipe, {
    title <- input$new_title
    if (is.null(title) || !nzchar(title)) {
      showNotification("Please provide a recipe title.", type = "error")
      return()
    }
    instr_lines <- trimws(unlist(strsplit(as.character(input$new_instructions), "[\r\n]+")))
    instr_lines <- instr_lines[nzchar(instr_lines)]
    src_url <- trimws(input$new_source_url)

    recipe <- list(
      title = title,
      source = input$new_source,
      source_url = if (nzchar(src_url)) src_url else NULL,
      ingredients = parse_ingredients_raw(input$new_ingredients_raw),
      instructions = lapply(seq_along(instr_lines), function(i) {
        list(step_number = i, instruction_text = instr_lines[i])
      }),
      date_added = Sys.time(),
      last_modified = Sys.time()
    )
    added <- add_recipe(recipe)
    showNotification(sprintf("Saved recipe '%s'", added$title), type = "message")
    updateTextInput(session, "new_title", value = "")
    updateTextInput(session, "new_source", value = "")
    updateTextInput(session, "new_source_url", value = "")
    updateTextAreaInput(session, "new_ingredients_raw", value = "")
    updateTextAreaInput(session, "new_instructions", value = "")
    refresh_data()
  })

  observeEvent(input$clear_recipe, {
    updateTextInput(session, "new_title", value = "")
    updateTextInput(session, "new_source", value = "")
    updateTextInput(session, "new_source_url", value = "")
    updateTextAreaInput(session, "new_ingredients_raw", value = "")
    updateTextAreaInput(session, "new_instructions", value = "")
  })

  # ---------------------------------------------------------------------------
  # Ingredients: add/update
  # ---------------------------------------------------------------------------
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
    showNotification(sprintf("Added/updated ingredient '%s'", name), type = "message")
    updateTextInput(session, "ing_name", value = "")
    updateNumericInput(session, "ing_qty", value = NA)
    updateTextInput(session, "ing_unit", value = "")
    refresh_data()
  })

  # Delete ingredient from table
  observeEvent(input$delete_ing_btn, {
    id <- input$delete_ing_btn
    if (!is.null(id) && nzchar(id)) {
      delete_ingredient(id)
      showNotification("Ingredient removed", type = "message")
      refresh_data()
    }
  })

  # ---------------------------------------------------------------------------
  # Per-recipe observers — registered once per recipe ID to avoid accumulation
  # ---------------------------------------------------------------------------
  observe({
    ids <- names(rv$recipes)
    registered <- session$userData$registered_recipe_ids
    if (is.null(registered)) {
      registered <- character(0)
      session$userData$registered_recipe_ids <- registered
    }
    new_ids <- setdiff(ids, registered)
    if (length(new_ids) == 0) {
      return()
    }

    lapply(new_ids, function(rid) {
      btn <- paste0("view_", rid)
      editbtn <- paste0("edit_", rid)
      delbtn <- paste0("del_", rid)
      cmpbtn <- paste0("cmp_", rid)
      addshop_btn <- paste0("addshop_", rid)
      scale_input <- paste0("drawer_scale_", rid)

      local({
        id_now <- rid

        # --- View: open offcanvas drawer ---
        observeEvent(
          input[[btn]],
          {
            r <- rv$recipes[[id_now]]
            if (is.null(r)) {
              return()
            }
            drawer_scale(1)
            selected_recipe(r)
            shinyjs::runjs(
              paste0(
                "(function(){",
                "var el=document.getElementById('recipe_detail_drawer');",
                "if(el){",
                "var oc=bootstrap.Offcanvas.getInstance(el)||new bootstrap.Offcanvas(el);",
                "oc.show();",
                "}",
                "})()"
              )
            )
          },
          ignoreInit = TRUE
        )

        # --- Scale change from drawer ---
        observeEvent(
          input[[scale_input]],
          {
            mult <- as.numeric(input[[scale_input]])
            if (!is.null(mult) && !is.na(mult) && mult > 0) {
              drawer_scale(mult)
            }
          },
          ignoreInit = TRUE
        )

        # --- Add missing to shopping list (from drawer) ---
        observeEvent(
          input[[addshop_btn]],
          {
            r <- rv$recipes[[id_now]]
            if (is.null(r)) {
              return()
            }
            missing_to_add <- get_missing_ingredients(r, rv$ingredients)
            if (length(missing_to_add) == 0) {
              showNotification(
                "No missing ingredients \u2014 you have everything!",
                type = "message"
              )
              return()
            }
            current <- get_shopping_list()
            combined <- unique(c(current, missing_to_add))
            save_shopping_list(combined)
            rv$shopping <- combined
            showNotification(
              sprintf("Added %d item(s) to shopping list", length(missing_to_add)),
              type = "message"
            )
          },
          ignoreInit = TRUE
        )

        # --- Compare toggle ---
        observeEvent(
          input[[cmpbtn]],
          {
            current <- rv$selected_card_ids
            if (id_now %in% current) {
              rv$selected_card_ids <- setdiff(current, id_now)
            } else {
              if (length(current) >= 2) {
                showNotification(
                  "Two recipes already selected. Deselect one first.",
                  type = "warning"
                )
              } else {
                rv$selected_card_ids <- c(current, id_now)
              }
            }
          },
          ignoreInit = TRUE
        )

        # --- Edit modal ---
        observeEvent(
          input[[editbtn]],
          {
            r <- rv$recipes[[id_now]]
            if (is.null(r)) {
              return()
            }
            ing_text <- paste(
              sapply(r$ingredients, function(i) {
                if (!is.null(i$raw_text)) i$raw_text else i$ingredient_name
              }),
              collapse = "\n"
            )
            inst_text <- paste(
              sapply(r$instructions, function(s) s$instruction_text),
              collapse = "\n"
            )

            showModal(modalDialog(
              title = paste0("Edit: ", r$title),
              textInput("edit_title", "Title", value = r$title),
              textInput("edit_source", "Cuisine/Source", value = r$source),
              textInput("edit_source_url", "Source URL", value = r$source_url %||% ""),
              textAreaInput(
                "edit_ingredients",
                "Ingredients (one per line)",
                value = ing_text,
                rows = 8
              ),
              textAreaInput(
                "edit_instructions",
                "Instructions (one per line)",
                value = inst_text,
                rows = 8
              ),
              footer = tagList(
                modalButton("Cancel"),
                actionButton("save_edit", "Save", class = "btn-primary")
              )
            ))

            observeEvent(
              input$save_edit,
              {
                new_title <- input$edit_title
                new_src_url <- trimws(input$edit_source_url)
                new_ings <- parse_ingredients_raw(input$edit_ingredients)
                inst_lines <- trimws(unlist(strsplit(
                  as.character(input$edit_instructions),
                  "[\\r\\n]+"
                )))
                inst_lines <- inst_lines[nzchar(inst_lines)]
                updated <- r
                updated$title <- new_title
                updated$source <- input$edit_source
                updated$source_url <- if (nzchar(new_src_url)) new_src_url else NULL
                updated$ingredients <- new_ings
                updated$instructions <- lapply(seq_along(inst_lines), function(i) {
                  list(step_number = i, instruction_text = inst_lines[i])
                })
                update_recipe(id_now, updated)
                showNotification(sprintf("Updated '%s'", new_title), type = "message")
                refresh_data()
                removeModal()
              },
              once = TRUE
            )
          },
          ignoreInit = TRUE
        )

        # --- Delete modal ---
        observeEvent(
          input[[delbtn]],
          {
            r <- rv$recipes[[id_now]]
            if (is.null(r)) {
              return()
            }
            showModal(modalDialog(
              title = paste0("Delete: ", r$title),
              p("Are you sure you want to delete this recipe?"),
              footer = tagList(
                modalButton("Cancel"),
                actionButton("confirm_delete", "Delete", class = "btn-danger")
              )
            ))
            observeEvent(
              input$confirm_delete,
              {
                delete_recipe(id_now)
                showNotification(sprintf("Deleted '%s'", r$title), type = "message")
                refresh_data()
                removeModal()
              },
              once = TRUE
            )
          },
          ignoreInit = TRUE
        )
      })
    })

    # Record newly registered IDs
    session$userData$registered_recipe_ids <- c(registered, new_ids)
  })

  # ---------------------------------------------------------------------------
  # Ingredients table
  # ---------------------------------------------------------------------------
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

  # Delete ingredient row from DT proxy
  observeEvent(input$ingredients_table_rows_selected, {
    sel <- input$ingredients_table_rows_selected
    if (is.null(sel) || length(sel) == 0) {
      return()
    }
    ings <- as.list(rv$ingredients)
    if (sel < 1 || sel > length(ings)) {
      return()
    }
    id <- ings[[sel]]$id
    if (is.null(id)) {
      return()
    }
    showModal(modalDialog(
      title = "Remove ingredient?",
      p(paste("Remove", ings[[sel]]$ingredient_name, "from inventory?")),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_del_ing", "Remove", class = "btn-danger")
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

  # ---------------------------------------------------------------------------
  # Shopping list tab
  # ---------------------------------------------------------------------------
  output$shopping_list_output <- renderUI({
    items <- rv$shopping
    if (length(items) == 0) {
      return(tags$p(class = "text-muted", "Shopping list is empty."))
    }
    tags$ul(
      lapply(seq_along(items), function(i) {
        tags$li(
          style = "padding: 0.4rem 0; border-bottom: 1px solid #f0f0f0;",
          tags$span(items[i]),
          actionButton(
            inputId = paste0("remove_shop_", i),
            label = NULL,
            icon = icon("times"),
            class = "btn btn-sm btn-outline-danger ms-2",
            title = "Remove"
          )
        )
      })
    )
  })

  # Remove individual shopping item
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

  # Add item manually to shopping list
  observeEvent(input$add_shop_item, {
    item <- trimws(input$new_shop_item)
    if (!nzchar(item)) {
      showNotification("Enter an item name", type = "error")
      return()
    }
    current <- get_shopping_list()
    updated <- unique(c(current, item))
    save_shopping_list(updated)
    rv$shopping <- updated
    updateTextInput(session, "new_shop_item", value = "")
    showNotification(sprintf("Added '%s' to shopping list", item), type = "message")
  })

  # Clear shopping list
  observeEvent(input$clear_shop_list, {
    save_shopping_list(character(0))
    rv$shopping <- character(0)
    showNotification("Shopping list cleared", type = "message")
  })

  # ---------------------------------------------------------------------------
  # Export handlers
  # ---------------------------------------------------------------------------
  output$export_json <- downloadHandler(
    filename = function() paste0("recipes_export_", format(Sys.time(), "%Y%m%d%H%M%S"), ".json"),
    content = function(file) export_recipes_json(file)
  )

  output$export_csv <- downloadHandler(
    filename = function() paste0("recipes_export_", format(Sys.time(), "%Y%m%d%H%M%S"), ".csv"),
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

  # ---------------------------------------------------------------------------
  # Preferences
  # ---------------------------------------------------------------------------
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

  # ---------------------------------------------------------------------------
  # Densities: table + add + P3: delete custom density
  # ---------------------------------------------------------------------------
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
      showNotification("Please enter a valid density value (must be > 0)", type = "error")
      return()
    }
    add_custom_density(ing_name, ing_value)
    showNotification(
      sprintf("Added custom density: %s = %.2f g/ml", ing_name, ing_value),
      type = "message"
    )
    updateTextInput(session, "new_density_ingredient", value = "")
    updateNumericInput(session, "new_density_value", value = 1.0)
    # Force re-render of densities table
    output$densities_table <- DT::renderDataTable({
      DT::datatable(
        list_all_densities(),
        rownames = FALSE,
        selection = "single",
        options = list(pageLength = 10)
      )
    })
  })

  # P3 FIX: delete selected custom density row
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
    showNotification(sprintf("Deleted density for '%s'", row$ingredient), type = "message")
    output$densities_table <- DT::renderDataTable({
      DT::datatable(
        list_all_densities(),
        rownames = FALSE,
        selection = "single",
        options = list(pageLength = 10)
      )
    })
  })
}
