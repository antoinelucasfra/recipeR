#' @noRd
mod_browse_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      id = "pane-browse",
      class = "content-pane",

      tags$div(
        class = "page-header",
        tags$div(
          style = "display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:0.75rem;",
          tags$div(
            tags$h1(class = "page-title", "Browse Recipes"),
            tags$p(
              class = "page-subtitle",
              "Click a card to view details and scale"
            )
          ),
          actionButton(
            ns("compare_selected"),
            tagList(tags$i(class = "fas fa-code-compare"), " Compare"),
            class = "btn btn-secondary btn-sm",
            title = "Select exactly two cards then click",
            `data-bs-toggle` = "tooltip"
          )
        )
      ),

      bslib::card(
        class = "mb-3",
        bslib::card_body(
          class = "py-2",
          tags$div(
            class = "search-bar-wrap",
            tags$i(class = "fas fa-magnifying-glass search-icon"),
            textInput(
              ns("search_query"),
              NULL,
              placeholder = "Search recipes...",
              width = "100%"
            ),
            tags$span(class = "search-hint-badge", "/")
          ),
          tags$div(
            id = "filter-panel-header",
            class = "filter-panel-header mt-2",
            tags$span(
              tags$i(
                class = "fas fa-sliders",
                style = "margin-right:0.4rem;color:var(--accent);"
              ),
              "Filters"
            ),
            tags$div(
              style = "display:flex;align-items:center;gap:0.75rem;",
              actionButton(
                ns("reset_filters"),
                "Reset",
                class = "btn btn-secondary btn-sm"
              ),
              tags$i(class = "fas fa-chevron-down chevron")
            )
          ),
          tags$div(
            id = "filter_panel",
            style = "display:none;padding-top:0.75rem;",
            bslib::layout_columns(
              col_widths = c(6, 6),
              tags$div(
                tags$label("Cuisine", `for` = ns("cuisine_filter")),
                shinyWidgets::pickerInput(
                  ns("cuisine_filter"),
                  NULL,
                  choices = c(),
                  selected = NULL,
                  multiple = TRUE,
                  options = list(
                    `actions-box` = TRUE,
                    `selected-text-format` = "count > 2",
                    `title` = "All cuisines"
                  )
                )
              ),
              tags$div(
                tags$label("Source", `for` = ns("source_filter")),
                shinyWidgets::pickerInput(
                  ns("source_filter"),
                  NULL,
                  choices = c(),
                  selected = NULL,
                  multiple = TRUE,
                  options = list(
                    `actions-box` = TRUE,
                    `selected-text-format` = "count > 2",
                    `title` = "All sources"
                  )
                )
              )
            )
          )
        )
      ),

      tags$div(
        class = "browse-stats-bar",
        tags$div(
          class = "browse-stat",
          tags$span(
            class = "browse-stat-value",
            textOutput(ns("browse_total_recipes"), inline = TRUE)
          ),
          tags$span(class = "browse-stat-label", "recipes")
        ),
        tags$div(
          class = "browse-stat",
          tags$span(
            class = "browse-stat-value",
            textOutput(ns("browse_cuisines_count"), inline = TRUE)
          ),
          tags$span(class = "browse-stat-label", "cuisines")
        ),
        tags$div(
          class = "browse-stat",
          tags$span(
            class = "browse-stat-value",
            textOutput(ns("browse_avg_ingredients"), inline = TRUE)
          ),
          tags$span(class = "browse-stat-label", "avg ingredients")
        ),
        tags$div(
          class = "browse-stat",
          tags$span(
            class = "browse-stat-value",
            textOutput(ns("browse_avg_steps"), inline = TRUE)
          ),
          tags$span(class = "browse-stat-label", "avg steps")
        ),
        tags$div(
          style = "margin-left:auto;",
          selectInput(
            ns("browse_sort"),
            NULL,
            choices = c(
              "Best Match" = "match",
              "Title A\u2192Z" = "title",
              "Newest First" = "date",
              "Cuisine A\u2192Z" = "cuisine"
            ),
            selected = "match",
            width = "160px"
          )
        )
      ),

      uiOutput(ns("recipe_cards_grid"))
    ),

    # Recipe detail offcanvas drawer
    tags$div(
      id = "recipe_detail_drawer",
      class = "offcanvas offcanvas-end",
      tabindex = "-1",
      `aria-labelledby` = "recipe_drawer_label",
      tags$div(
        class = "offcanvas-header",
        tags$h5(
          class = "offcanvas-title",
          id = "recipe_drawer_label",
          uiOutput(ns("drawer_title"), inline = TRUE)
        ),
        tags$button(
          type = "button",
          class = "btn-close",
          `data-bs-dismiss` = "offcanvas",
          `aria-label` = "Close"
        )
      ),
      tags$div(
        class = "offcanvas-body",
        uiOutput(ns("recipe_detail_content"))
      )
    ),

    # Recipe compare modal
    tags$div(
      id = "recipe_compare_modal",
      class = "modal fade",
      tabindex = "-1",
      role = "dialog",
      tags$div(
        class = "modal-dialog modal-xl",
        role = "document",
        tags$div(
          class = "modal-content",
          tags$div(
            class = "modal-header",
            tags$h5(class = "modal-title", "Compare Recipes"),
            tags$button(
              type = "button",
              class = "btn-close",
              `data-bs-dismiss` = "modal",
              `aria-label` = "Close"
            )
          ),
          tags$div(class = "modal-body", uiOutput(ns("recipe_compare_content"))),
          tags$div(
            class = "modal-footer",
            tags$button(
              type = "button",
              class = "btn btn-secondary",
              `data-bs-dismiss` = "modal",
              "Close"
            )
          )
        )
      )
    )
  )
}

#' @noRd
mod_browse_server <- function(id, rv, refresh_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    selected_recipe <- reactiveVal(NULL)
    drawer_scale <- reactiveVal(1)

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
      sort_by <- input$browse_sort %||% "match"
      inv <- rv$ingredients
      if (sort_by == "title") {
        recs <- recs[order(sapply(recs, function(r) tolower(r$title %||% "")))]
      } else if (sort_by == "date") {
        dates <- sapply(recs, function(r) {
          d <- r$date_added
          if (is.null(d)) as.POSIXct("1970-01-01") else as.POSIXct(d)
        })
        recs <- recs[order(dates, decreasing = TRUE)]
      } else if (sort_by == "cuisine") {
        recs <- recs[order(sapply(recs, function(r) tolower(r$source %||% "")))]
      } else {
        if (length(inv) > 0 && length(recs) > 0) {
          scores <- sapply(recs, function(r) calculate_match(r, inv))
          recs <- recs[order(scores, decreasing = TRUE)]
        }
      }
      recs
    })

    output$browse_total_recipes <- renderText(length(filtered_recipes()))

    output$browse_avg_ingredients <- renderText({
      recs <- filtered_recipes()
      if (length(recs) == 0) return("0")
      round(mean(sapply(recs, function(r) length(r$ingredients))), 1)
    })

    output$browse_avg_steps <- renderText({
      recs <- filtered_recipes()
      if (length(recs) == 0) return("0")
      round(mean(sapply(recs, function(r) length(r$instructions))), 1)
    })

    output$browse_cuisines_count <- renderText({
      recs <- filtered_recipes()
      if (length(recs) == 0) return("0")
      length(unique(sapply(recs, function(r) r$source)))
    })

    # Filter panel toggle (dead code — panel is toggled via JS class, but kept for completeness)
    observeEvent(input$toggle_filters, {
      shinyjs::toggle("filter_panel")
    })

    # Populate cuisine/source filters from recipes
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

    observeEvent(input$reset_filters, {
      shinyWidgets::updatePickerInput(session, "cuisine_filter", selected = character(0))
      shinyWidgets::updatePickerInput(session, "source_filter", selected = character(0))
      updateTextInput(session, "search_query", value = "")
      showNotification("Filters reset", type = "message")
    })

    observeEvent(input$select_all_filters, {
      all_cuisines <- sort(unique(sapply(rv$recipes, function(r) {
        if (!is.null(r$source) && nzchar(r$source)) r$source else "Unknown"
      })))
      shinyWidgets::updatePickerInput(session, "cuisine_filter", selected = all_cuisines)
      showNotification("All cuisines selected", type = "message")
    })

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

          if (!is.null(r$image_url) && nzchar(r$image_url)) {
            tags$div(
              class = "card-thumbnail",
              tags$img(src = r$image_url, class = "recipe-thumb")
            )
          },

          tags$div(
            class = "recipe-card-header",
            tags$div(
              class = "recipe-card-title",
              if (isTRUE(r$is_favorite)) {
                tags$i(class = "fas fa-heart", style = "color:#ef4444;margin-right:0.3rem;")
              },
              r$title
            ),
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

          if (
            !is.null(r$rating) &&
              !is.na(r$rating) &&
              nzchar(as.character(r$rating))
          ) {
            tags$span(
              class = "recipe-rating",
              paste(rep("\u2605", as.integer(r$rating)), collapse = "")
            )
          },

          if (!is.null(r$tags) && length(r$tags) > 0) {
            tags$div(
              class = "recipe-tags-row",
              lapply(r$tags, function(t) tags$span(class = "recipe-tag", t))
            )
          },

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
              ns(paste0("view_", rid)),
              tagList(tags$i(class = "fas fa-eye"), " View"),
              class = "btn btn-primary btn-sm"
            ),
            actionButton(
              ns(paste0("edit_", rid)),
              tagList(tags$i(class = "fas fa-pen"), " Edit"),
              class = "btn btn-secondary btn-sm"
            ),
            actionButton(
              ns(paste0("del_", rid)),
              tags$i(class = "fas fa-trash"),
              class = "btn btn-danger btn-sm",
              title = "Delete",
              `data-bs-toggle` = "tooltip"
            ),
            actionButton(
              ns(paste0("dup_", rid)),
              icon("copy"),
              class = "btn btn-secondary btn-sm",
              title = "Duplicate"
            ),
            if (length(r$instructions) > 0) {
              actionButton(
                ns(paste0("cook_", rid)),
                tagList(tags$i(class = "fas fa-fire"), " Cook"),
                class = "btn btn-info btn-sm"
              )
            },
            actionButton(
              ns(paste0("cmp_", rid)),
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

    output$drawer_title <- renderUI({
      r <- selected_recipe()
      if (is.null(r)) return(NULL)
      if (isTRUE(r$is_favorite)) {
        tagList(
          tags$i(class = "fas fa-heart", style = "color:#ef4444;margin-right:0.4rem;"),
          r$title
        )
      } else {
        r$title
      }
    })

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
          tags$i(class = if (isTRUE(si$missing)) "fas fa-xmark" else "fas fa-check"),
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
        if (!is.null(r$image_url) && nzchar(r$image_url)) {
          tags$img(src = r$image_url, class = "drawer-hero-image")
        },

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

        if (!is.null(r$tags) && length(r$tags) > 0) {
          tags$div(
            class = "recipe-tags-row",
            lapply(r$tags, function(t) tags$span(class = "recipe-tag", t))
          )
        },

        tags$div(
          class = "scale-widget",
          tags$div(
            class = "scale-widget-title",
            tags$i(class = "fas fa-scale-balanced"),
            " Scale Recipe"
          ),
          tags$div(
            style = "display:flex;align-items:center;gap:0.75rem;flex-wrap:wrap;",
            numericInput(
              ns(scale_input_id),
              NULL,
              value = mult,
              min = 0.25,
              step = 0.25,
              width = "100px"
            ),
            tags$span(
              class = "text-muted",
              style = "font-size:0.8rem;",
              "\u00d7 servings"
            ),
            selectInput(
              ns(paste0("drawer_rating_", rid)),
              NULL,
              choices = c(
                "No rating" = "",
                "1 star" = "1",
                "2 stars" = "2",
                "3 stars" = "3",
                "4 stars" = "4",
                "5 stars" = "5"
              ),
              selected = as.character(r$rating %||% ""),
              width = "130px"
            ),
            actionButton(
              ns(paste0("fav_", rid)),
              if (isTRUE(r$is_favorite)) {
                tagList(tags$i(class = "fas fa-heart"), " Unfavorite")
              } else {
                tagList(tags$i(class = "far fa-heart"), " Favorite")
              },
              class = "btn btn-outline-danger btn-sm"
            ),
            if (length(r$instructions) > 0) {
              actionButton(
                ns(paste0("cook_", rid)),
                tagList(tags$i(class = "fas fa-fire"), " Cook"),
                class = "btn btn-info btn-sm"
              )
            },
            actionButton(
              ns(paste0("addshop_", rid)),
              tagList(tags$i(class = "fas fa-cart-plus"), " Add missing"),
              class = "btn btn-success btn-sm ms-auto",
              title = "Add missing ingredients to shopping list",
              `data-bs-toggle` = "tooltip"
            )
          )
        ),

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

        tags$div(
          class = "drawer-section",
          tags$div(
            class = "drawer-section-title",
            tags$i(class = "fas fa-carrot"),
            paste0("Ingredients (x", mult, ")")
          ),
          ing_rows
        ),

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

    output$recipe_compare_content <- renderUI({
      pair <- rv$compare_pair
      if (is.null(pair) || length(pair) != 2) {
        return(tags$p("No recipes selected for comparison."))
      }

      make_col <- function(r) {
        ings <- lapply(r$ingredients, function(i) {
          tags$li(
            if (!is.null(i$raw_text) && nzchar(i$raw_text)) i$raw_text else i$ingredient_name
          )
        })
        inst <- lapply(r$instructions, function(s) tags$li(s$instruction_text))
        tags$div(
          class = "col-md-6",
          tags$div(
            class = "panel",
            tags$div(class = "panel-header", tags$h5(r$title)),
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
                style = "font-size:0.78rem;text-transform:uppercase;letter-spacing:0.5px;font-weight:700;color:var(--text-muted);margin:1rem 0 0.5rem;",
                "Ingredients"
              ),
              tags$ul(
                ings,
                style = "max-height:220px;overflow:auto;padding-left:1rem;font-size:0.85rem;"
              ),
              tags$h6(
                style = "font-size:0.78rem;text-transform:uppercase;letter-spacing:0.5px;font-weight:700;color:var(--text-muted);margin:1rem 0 0.5rem;",
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

    # Per-recipe observers — registered once per new recipe ID
    observe({
      ids <- names(rv$recipes)
      registered <- session$userData$registered_recipe_ids
      if (is.null(registered)) {
        registered <- character(0)
        session$userData$registered_recipe_ids <- registered
      }
      new_ids <- setdiff(ids, registered)
      if (length(new_ids) == 0) return()

      lapply(new_ids, function(rid) {
        btn <- paste0("view_", rid)
        editbtn <- paste0("edit_", rid)
        delbtn <- paste0("del_", rid)
        cmpbtn <- paste0("cmp_", rid)
        addshop_btn <- paste0("addshop_", rid)
        scale_input <- paste0("drawer_scale_", rid)
        inp_rating <- paste0("drawer_rating_", rid)
        btn_fav <- paste0("fav_", rid)
        btn_dup <- paste0("dup_", rid)
        btn_cook <- paste0("cook_", rid)

        local({
          id_now <- rid

          observeEvent(
            input[[btn]],
            {
              r <- rv$recipes[[id_now]]
              if (is.null(r)) return()
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

          observeEvent(
            input[[addshop_btn]],
            {
              r <- rv$recipes[[id_now]]
              if (is.null(r)) return()
              missing_to_add <- get_missing_ingredients(r, rv$ingredients)
              if (length(missing_to_add) == 0) {
                showNotification(
                  "No missing ingredients \u2014 you have everything!",
                  type = "message"
                )
                return()
              }
              current <- get_shopping_list()
              existing_texts <- sapply(current, function(x) x$text)
              new_items <- lapply(
                missing_to_add[!(missing_to_add %in% existing_texts)],
                function(x) list(text = x, checked = FALSE)
              )
              combined <- c(current, new_items)
              save_shopping_list(combined)
              rv$shopping <- combined
              showNotification(
                sprintf("Added %d item(s) to shopping list", length(missing_to_add)),
                type = "message"
              )
            },
            ignoreInit = TRUE
          )

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

          observeEvent(
            input[[inp_rating]],
            {
              r <- rv$recipes[[id_now]]
              if (is.null(r)) return()
              rating_val <- input[[inp_rating]]
              r$rating <- if (!is.null(rating_val) && nzchar(rating_val)) {
                as.integer(rating_val)
              } else {
                NULL
              }
              update_recipe(id_now, r)
              refresh_data()
            },
            ignoreInit = TRUE
          )

          observeEvent(
            input[[btn_fav]],
            {
              r <- rv$recipes[[id_now]]
              if (is.null(r)) return()
              r$is_favorite <- !isTRUE(r$is_favorite)
              update_recipe(id_now, r)
              refresh_data()
              selected_recipe(rv$recipes[[id_now]])
            },
            ignoreInit = TRUE
          )

          observeEvent(
            input[[btn_dup]],
            {
              r <- rv$recipes[[id_now]]
              if (is.null(r)) return()
              r_copy <- r
              r_copy$title <- paste0(r$title, " (copy)")
              r_copy$recipe_id <- NULL
              add_recipe(r_copy)
              refresh_data()
              showNotification(
                sprintf("Duplicated as \u2018%s\u2019", r_copy$title),
                type = "message"
              )
            },
            ignoreInit = TRUE
          )

          observeEvent(
            input[[btn_cook]],
            {
              r <- rv$recipes[[id_now]]
              if (is.null(r)) return()
              rv$cooking_recipe <- r
              rv$cooking_step <- 1L
              shinyjs::runjs("window.recipeR_navigate('cooking')")
              shinyjs::runjs(
                paste0(
                  "(function(){",
                  "var el=document.getElementById('recipe_detail_drawer');",
                  "if(el){var oc=bootstrap.Offcanvas.getInstance(el);if(oc)oc.hide();}",
                  "})()"
                )
              )
            },
            ignoreInit = TRUE
          )

          observeEvent(
            input[[editbtn]],
            {
              r <- rv$recipes[[id_now]]
              if (is.null(r)) return()
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
                textInput(ns("edit_title"), "Title", value = r$title),
                textInput(ns("edit_source"), "Cuisine/Source", value = r$source),
                textInput(ns("edit_source_url"), "Source URL", value = r$source_url %||% ""),
                textAreaInput(
                  ns("edit_ingredients"),
                  "Ingredients (one per line)",
                  value = ing_text,
                  rows = 8
                ),
                textAreaInput(
                  ns("edit_instructions"),
                  "Instructions (one per line)",
                  value = inst_text,
                  rows = 8
                ),
                footer = tagList(
                  modalButton("Cancel"),
                  actionButton(ns("save_edit"), "Save", class = "btn-primary")
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
                  showNotification(sprintf("Updated \u2018%s\u2019", new_title), type = "message")
                  refresh_data()
                  removeModal()
                },
                once = TRUE
              )
            },
            ignoreInit = TRUE
          )

          observeEvent(
            input[[delbtn]],
            {
              r <- rv$recipes[[id_now]]
              if (is.null(r)) return()
              showModal(modalDialog(
                title = paste0("Delete: ", r$title),
                p("Are you sure you want to delete this recipe?"),
                footer = tagList(
                  modalButton("Cancel"),
                  actionButton(ns("confirm_delete"), "Delete", class = "btn-danger")
                )
              ))
              observeEvent(
                input$confirm_delete,
                {
                  delete_recipe(id_now)
                  showNotification(
                    sprintf("Deleted \u2018%s\u2019", r$title),
                    type = "message"
                  )
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

      session$userData$registered_recipe_ids <- c(registered, new_ids)
    })
  })
}
