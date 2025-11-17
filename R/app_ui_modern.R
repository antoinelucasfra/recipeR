# Modern, visually appealing UI with Bootstrap 5 and custom CSS

ui_modern <- function() {
  shinyUI(
    fluidPage(
      # Custom modern CSS styling
      tags$head(
        shinyjs::useShinyjs(),
        tags$meta(charset = "utf-8"),
        tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
        tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"),
        tags$style(HTML("
          * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
          }

          :root {
            --primary: #6366f1;
            --primary-dark: #4f46e5;
            --secondary: #ec4899;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --info: #3b82f6;
            --light: #f8fafc;
            --dark: #1e293b;
            --muted: #64748b;
            --border-radius: 12px;
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
            --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
          }

          body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
            color: var(--dark);
            min-height: 100vh;
          }

          .navbar {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            box-shadow: var(--shadow-lg);
            border: none;
            padding: 1rem 2rem;
          }

          .navbar-brand {
            font-size: 1.5rem;
            font-weight: 700;
            letter-spacing: -0.5px;
            color: white !important;
          }

          .nav-link {
            color: rgba(255, 255, 255, 0.85) !important;
            margin: 0 0.5rem;
            border-radius: 6px;
            transition: all 0.3s ease;
            font-weight: 500;
          }

          .nav-link:hover,
          .nav-link.active {
            color: white !important;
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-2px);
          }

          .container-main {
            padding: 2rem 1rem;
            max-width: 1400px;
            margin: 0 auto;
          }

          .section-header {
            margin-bottom: 2rem;
            padding-bottom: 1.5rem;
            border-bottom: 2px solid rgba(99, 102, 241, 0.1);
          }

          .section-title {
            font-size: 2rem;
            font-weight: 700;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 0.5rem;
          }

          .section-subtitle {
            color: var(--muted);
            font-size: 0.95rem;
          }

          .card {
            border: none;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-md);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            overflow: hidden;
            margin-bottom: 1.5rem;
          }

          .card:hover {
            box-shadow: var(--shadow-xl);
            transform: translateY(-4px);
          }

          .card-header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: white;
            border: none;
            font-weight: 600;
            padding: 1.25rem;
          }

          .card-body {
            padding: 1.5rem;
          }

          .recipe-card {
            background: white;
            border-radius: var(--border-radius);
            padding: 1.5rem;
            box-shadow: var(--shadow-md);
            border-left: 4px solid var(--primary);
            transition: all 0.3s ease;
            margin-bottom: 1rem;
            cursor: pointer;
          }

          .recipe-card:hover {
            box-shadow: var(--shadow-xl);
            transform: translateX(4px);
            border-left-color: var(--secondary);
          }

          .recipe-card-title {
            font-size: 1.25rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            color: var(--primary);
          }

          .recipe-card-meta {
            display: flex;
            gap: 1rem;
            margin-bottom: 1rem;
            flex-wrap: wrap;
          }

          .recipe-meta-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.85rem;
            color: var(--muted);
            background: rgba(99, 102, 241, 0.05);
            padding: 0.4rem 0.8rem;
            border-radius: 6px;
          }

          .match-badge {
            display: inline-block;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            font-weight: 700;
            font-size: 0.9rem;
          }

          .match-high {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
          }

          .match-medium {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            color: white;
          }

          .match-low {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
            color: white;
          }

          .btn {
            border: none;
            border-radius: 6px;
            font-weight: 600;
            padding: 0.6rem 1.2rem;
            transition: all 0.3s ease;
            font-size: 0.95rem;
          }

          .btn-primary {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: white;
          }

          .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 12px rgba(99, 102, 241, 0.3);
            color: white;
          }

          .btn-secondary {
            background: linear-gradient(135deg, var(--secondary) 0%, #be185d 100%);
            color: white;
          }

          .btn-secondary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 12px rgba(236, 72, 153, 0.3);
            color: white;
          }

          .btn-success {
            background: linear-gradient(135deg, var(--success) 0%, #059669 100%);
            color: white;
          }

          .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 12px rgba(16, 185, 129, 0.3);
            color: white;
          }

          .btn-sm {
            padding: 0.4rem 0.8rem;
            font-size: 0.85rem;
          }

          .input-group,
          .form-control,
          .form-select {
            border-radius: 6px;
            border: 1px solid #e2e8f0;
            font-size: 0.95rem;
          }

          .form-control:focus,
          .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.2rem rgba(99, 102, 241, 0.1);
          }

          .input-group .form-control {
            border-right: none;
          }

          .input-group-text {
            background: #f1f5f9;
            border: 1px solid #e2e8f0;
            border-left: none;
            color: var(--muted);
          }

          .badge {
            padding: 0.4rem 0.8rem;
            border-radius: 4px;
            font-weight: 600;
            font-size: 0.8rem;
          }

          .table {
            font-size: 0.95rem;
          }

          .table thead {
            background: #f8fafc;
            border-bottom: 2px solid #e2e8f0;
          }

          .table thead th {
            color: var(--primary);
            font-weight: 700;
            border: none;
            padding: 1rem;
          }

          .table tbody tr {
            transition: all 0.3s ease;
          }

          .table tbody tr:hover {
            background: #f8fafc;
          }

          .table tbody td {
            border-color: #e2e8f0;
            padding: 1rem;
            vertical-align: middle;
          }

          .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
          }

          .stat-card {
            background: white;
            padding: 1.5rem;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-md);
            border-top: 4px solid var(--primary);
            transition: all 0.3s ease;
          }

          .stat-card:hover {
            box-shadow: var(--shadow-lg);
            transform: translateY(-2px);
          }

          .stat-value {
            font-size: 2rem;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 0.5rem;
          }

          .stat-label {
            color: var(--muted);
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }

          .icon-primary {
            color: var(--primary);
            margin-right: 0.5rem;
          }

          .icon-secondary {
            color: var(--secondary);
            margin-right: 0.5rem;
          }

          .icon-success {
            color: var(--success);
            margin-right: 0.5rem;
          }

          .modal-content {
            border: none;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-xl);
          }

          .modal-header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: white;
            border: none;
            padding: 1.5rem;
          }

          .modal-header .btn-close {
            filter: brightness(0) invert(1);
          }

          .alert {
            border: none;
            border-radius: var(--border-radius);
            border-left: 4px solid;
          }

          .alert-success {
            background: #ecfdf5;
            color: #065f46;
            border-left-color: var(--success);
          }

          .alert-warning {
            background: #fffbeb;
            color: #92400e;
            border-left-color: var(--warning);
          }

          .alert-danger {
            background: #fef2f2;
            color: #991b1b;
            border-left-color: var(--danger);
          }

          .alert-info {
            background: #eff6ff;
            color: #0c2d6b;
            border-left-color: var(--info);
          }

          .tab-content {
            padding-top: 1.5rem;
          }

          .nav-tabs {
            border: none;
            gap: 0.5rem;
          }

          .nav-tabs .nav-link {
            color: var(--muted);
            border: none;
            border-bottom: 3px solid transparent;
            border-radius: 6px 6px 0 0;
            transition: all 0.3s ease;
            font-weight: 600;
          }

          .nav-tabs .nav-link:hover {
            color: var(--primary);
            background: #f1f5f9;
            border-bottom-color: var(--primary);
          }

          .nav-tabs .nav-link.active {
            color: white;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            border-bottom-color: var(--primary);
          }

          .dataTables_wrapper {
            padding: 1rem;
          }

          .dataTables_length,
          .dataTables_info {
            color: var(--muted);
            font-size: 0.9rem;
          }

          .paginate_button.current {
            background: var(--primary) !important;
            color: white !important;
          }

          /* Enhanced table styling */
          .dataTables_wrapper .dataTable tbody tr {
            transition: all 0.2s ease;
            border-bottom: 1px solid #f0f0f0;
          }

          .dataTables_wrapper .dataTable tbody tr:hover {
            background: linear-gradient(90deg, rgba(99,102,241,0.03), rgba(236,72,153,0.03));
            cursor: pointer;
            box-shadow: inset 0 0 10px rgba(99,102,241,0.05);
          }

          .dataTables_wrapper .dataTable tbody td {
            padding: 12px 15px;
            vertical-align: middle;
          }

          /* Recipe detail modal styling */
          .recipe-detail-modal .modal-body {
            padding: 2rem;
          }

          .recipe-detail-modal .detail-section {
            margin-bottom: 2rem;
          }

          .recipe-detail-modal .detail-section h6 {
            color: var(--primary);
            font-weight: 700;
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid rgba(99,102,241,0.2);
          }

          .recipe-detail-modal .ingredient-item {
            padding: 0.5rem 0;
            border-left: 3px solid var(--primary);
            padding-left: 1rem;
            font-size: 0.95rem;
          }

          .recipe-detail-modal .step-item {
            padding: 0.75rem;
            margin-bottom: 0.75rem;
            background: #f8fafc;
            border-radius: 8px;
            border-left: 4px solid var(--secondary);
          }

          .recipe-detail-modal .step-number {
            display: inline-block;
            background: var(--primary);
            color: white;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            text-align: center;
            line-height: 28px;
            font-weight: 700;
            margin-right: 0.75rem;
            font-size: 0.9rem;
          }

          .recipe-metadata {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 1rem;
            margin-bottom: 1.5rem;
          }

          .recipe-metadata-item {
            background: #f8fafc;
            padding: 1rem;
            border-radius: 8px;
            text-align: center;
            border-top: 3px solid var(--primary);
          }

          .recipe-metadata-item .label {
            color: var(--muted);
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 0.5rem;
          }

          .recipe-metadata-item .value {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary);
          }

          @media (max-width: 768px) {
            .container-main {
              padding: 1rem;
            }

            .section-title {
              font-size: 1.5rem;
            }

            .stats-grid {
              grid-template-columns: 1fr;
            }

            .recipe-card-meta {
              flex-direction: column;
              gap: 0.5rem;
            }
          }
        ")),
        # Extra UX polish: toast/notification styling, spinner, and small accessibility helpers
        tags$style(HTML(
".shiny-notification {\n  border-radius: 10px;\n  padding: 0.8rem 1rem;\n  box-shadow: 0 6px 18px rgba(2,6,23,0.12);\n  background: linear-gradient(180deg, rgba(255,255,255,0.98), rgba(250,250,250,0.98));\n  border-left: 6px solid var(--primary);\n  color: var(--dark);\n  font-weight: 600;\n  min-width: 260px;\n}\n\n.shiny-notification.info { border-left-color: var(--info); }\n.shiny-notification.success { border-left-color: var(--success); }\n.shiny-notification.error { border-left-color: var(--danger); }\n\n/* Fullscreen spinner overlay for long ops */\n.spinner-overlay {\n  position: fixed;\n  inset: 0;\n  display: none;\n  align-items: center;\n  justify-content: center;\n  background: rgba(15, 23, 42, 0.4);\n  z-index: 2000;\n}\n\n.spinner-card {\n  background: white;\n  padding: 1.25rem 1.5rem;\n  border-radius: 10px;\n  box-shadow: var(--shadow-xl);\n  display: flex;\n  gap: 1rem;\n  align-items: center;\n}\n\n.skeleton {\n  background: linear-gradient(90deg, #f1f5f9 25%, #e2e8f0 37%, #f1f5f9 63%);\n  animation: shimmer 1.4s ease-in-out infinite;\n  border-radius: 8px;\n}\n\n@keyframes shimmer {\n  0% { background-position: -200px 0 }\n  100% { background-position: 200px 0 }\n}\n\n/* Focus visible for keyboard navigation */\n:focus {\n  outline: 3px solid rgba(99,102,241,0.18);\n  outline-offset: 2px;\n  box-shadow: 0 6px 18px rgba(99,102,241,0.08);\n}\n")),
        # JS initializer: tooltips, autofocus search on tab, keyboard shortcut '/'
        tags$script(HTML(
"document.addEventListener('DOMContentLoaded', function() {\n  // initialize Bootstrap tooltips for any element with data-bs-toggle\n  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle=\"tooltip\"]'))\n  tooltipTriggerList.map(function (el) { return new bootstrap.Tooltip(el) })\n\n  // Focus search when Browse Recipes tab is shown\n  var mainNav = document.getElementById('main_nav');\n  if (mainNav) {\n    mainNav.addEventListener('shown.bs.tab', function(e) {\n      var target = e.target;\n      var text = target && target.textContent ? target.textContent.trim() : '';\n      if (text.indexOf('Browse Recipes') !== -1) {\n        var el = document.getElementById('search_query');\n        if (el) setTimeout(function(){ el.focus(); }, 120);\n      }\n    })\n  }\n\n  // Quick search: press '/' to focus search input\n  document.addEventListener('keydown', function(e) {\n    if (e.key === '/' && document.activeElement.tagName !== 'INPUT' && document.activeElement.tagName !== 'TEXTAREA') {\n      e.preventDefault();\n      var el = document.getElementById('search_query');\n      if (el) el.focus();\n    }\n  });\n});"))
      ),

      # Global spinner overlay (toggleable from server via JS/show/hide)
      tags$div(id = "global_spinner", class = "spinner-overlay",
        tags$div(class = "spinner-card",
          tags$i(class = "fas fa-spinner fa-pulse fa-2x", style = "color: var(--primary);"),
          tags$div(tags$strong("Working"), tags$div(style = "font-size:0.9rem;color:var(--muted);", "Please wait..."))
        )
      ),

      # Recipe Detail Modal
      tags$div(
        id = "recipe_detail_modal",
        class = "modal fade recipe-detail-modal",
        tabindex = "-1",
        role = "dialog",
        tags$div(
          class = "modal-dialog modal-lg",
          role = "document",
          tags$div(
            class = "modal-content",
            tags$div(
              class = "modal-header",
              tags$h5(class = "modal-title", id = "recipe_title", "Recipe Details"),
              tags$button(
                type = "button",
                class = "btn-close",
                `data-bs-dismiss` = "modal",
                `aria-label` = "Close"
              )
            ),
            tags$div(
              class = "modal-body",
              uiOutput("recipe_detail_content")
            ),
            tags$div(
              class = "modal-footer",
              tags$button(
                type = "button",
                class = "btn btn-secondary",
                `data-bs-dismiss` = "modal",
                "Close"
              ),
              tags$button(
                id = "edit_recipe_btn",
                type = "button",
                class = "btn btn-primary",
                icon("edit"), "Edit Recipe"
              )
            )
          )
        )
      ),

      # Navigation bar
      navbarPage(
        title = tags$div(
          tags$i(class = "fas fa-utensils", style = "margin-right: 0.5rem;"),
          "recipeR"
        ),
        id = "main_nav",
        theme = "cerulean",
        windowTitle = "recipeR - Modern Recipe Manager",

        # Home Tab
        tabPanel(
          "Home",
          div(
            class = "container-main",
            div(
              class = "section-header",
              h1(class = "section-title", "Welcome to recipeR"),
              p(class = "section-subtitle", "Your personal AI-powered recipe manager with intelligent ingredient matching")
            ),

            # Stats Grid
            div(
              class = "stats-grid",
              div(
                class = "stat-card",
                div(class = "stat-value", textOutput("stat_total_recipes")),
                div(class = "stat-label", "Total Recipes")
              ),
              div(
                class = "stat-card",
                div(class = "stat-value", textOutput("stat_cuisines")),
                div(class = "stat-label", "Cuisines")
              ),
              div(
                class = "stat-card",
                div(class = "stat-value", textOutput("stat_ingredients")),
                div(class = "stat-label", "Ingredients")
              ),
              div(
                class = "stat-card",
                div(class = "stat-value", textOutput("stat_avg_ingredients")),
                div(class = "stat-label", "Avg Ingredients/Recipe")
              )
            ),

            # Features Grid
            div(
              class = "row",
              div(
                class = "col-md-6 col-lg-4",
                div(
                  class = "card",
                  div(
                    class = "card-body",
                    h5(icon("search", class = "icon-primary"), "Browse Recipes"),
                    p("Search and filter through a curated collection of recipes with advanced filtering options")
                  )
                )
              ),
              div(
                class = "col-md-6 col-lg-4",
                div(
                  class = "card",
                  div(
                    class = "card-body",
                    h5(icon("plus-circle", class = "icon-secondary"), "Add Recipes"),
                    p("Add new recipes from external sources to build your personal recipe collection")
                  )
                )
              ),
              div(
                class = "col-md-6 col-lg-4",
                div(
                  class = "card",
                  div(
                    class = "card-body",
                    h5(icon("gear", class = "icon-success"), "Manage Settings"),
                    p("Configure preferences, manage ingredient densities, and import/export your recipes")
                  )
                )
              )
            )
          )
        ),

        # Browse Recipes Tab
        tabPanel(
          "Browse Recipes",
          div(
            class = "container-main",
            div(
              class = "section-header",
              h1(class = "section-title", "Browse Recipes"),
              p(class = "section-subtitle", "Search and filter through your recipe collection")
            ),

            # Search
            div(
              class = "row mb-3",
              div(
                class = "col-md-12",
                div(
                  class = "input-group",
                  textInput("search_query", NULL, placeholder = "Search recipes by title...", width = "100%"),
                  tags$span(class = "input-group-text", icon("search"))
                )
              )
            ),

            # Advanced Filters (collapsible)
            div(
              class = "card mb-4",
              div(
                class = "card-header",
                div(
                  style = "display: flex; justify-content: space-between; align-items: center;",
                  h5(style = "margin: 0;", icon("filter"), "Advanced Filters"),
                  actionButton("toggle_filters", "Show/Hide", class = "btn btn-sm btn-secondary")
                )
              ),
              div(
                id = "filter_panel",
                class = "card-body",
                style = "display: none;",
                div(
                  class = "row mb-3",
                  div(
                    class = "col-md-6",
                    h6("By Cuisine"),
                    shinyWidgets::pickerInput(
                      "cuisine_filter",
                      NULL,
                      choices = c("Chinese Cuisine", "Thai Cuisine", "Japanese Cuisine", "Indian Cuisine", "Vietnamese Cuisine"),
                      selected = NULL,
                      multiple = TRUE,
                      options = list(
                        `actions-box` = TRUE,
                        `selected-text-format` = "count > 2"
                      )
                    )
                  ),
                  div(
                    class = "col-md-6",
                    h6("By Source URL"),
                    shinyWidgets::pickerInput(
                      "source_filter",
                      NULL,
                      choices = c(),
                      selected = NULL,
                      multiple = TRUE,
                      options = list(
                        `actions-box` = TRUE,
                        `selected-text-format` = "count > 2"
                      )
                    )
                  )
                ),
                div(
                  class = "row",
                  div(
                    class = "col-md-12",
                    actionButton("reset_filters", "Reset All Filters", class = "btn btn-warning btn-sm"),
                    actionButton("select_all_filters", "Select All", class = "btn btn-info btn-sm ms-2")
                  )
                )
              )
            ),

            # Browse Stats (filtered)
            div(
              class = "stats-grid",
              div(
                class = "stat-card",
                div(class = "stat-value", textOutput("browse_total_recipes")),
                div(class = "stat-label", "Recipes Found")
              ),
              div(
                class = "stat-card",
                div(class = "stat-value", textOutput("browse_avg_ingredients")),
                div(class = "stat-label", "Avg Ingredients")
              ),
              div(
                class = "stat-card",
                div(class = "stat-value", textOutput("browse_avg_steps")),
                div(class = "stat-label", "Avg Steps")
              ),
              div(
                class = "stat-card",
                div(class = "stat-value", textOutput("browse_cuisines_count")),
                div(class = "stat-label", "Cuisines")
              )
            ),

            # Recipes table display with enhanced styling
            div(
              class = "card mt-4",
              div(
                class = "card-header",
                h5(style = "margin: 0;", icon("table"), "Recipe Catalog")
              ),
              div(
                class = "card-body",
                div(
                  style = "overflow-x: auto;",
                  DT::dataTableOutput("recipes_table_display")
                ),
                div(
                  class = "mt-3",
                  p(class = "text-muted small", 
                    "Click on a recipe row to view details. Tip: Use the search and filters above to narrow down your search.")
                )
              )
            )
          )
        ),

        # Add Recipe Tab
        tabPanel(
          "Add Recipe",
          div(
            class = "container-main",
            div(
              class = "section-header",
              h1(class = "section-title", "Add New Recipe"),
              p(class = "section-subtitle", "Create a new recipe to add to your collection")
            ),

            div(
              class = "row",
              div(
                class = "col-lg-8 mx-auto",
                div(
                  class = "card",
                  div(
                    class = "card-body",
                    textInput("new_title", "Recipe Title", placeholder = "e.g., Vegetable Pad Thai", width = "100%"),
                    textInput("new_source", "Cuisine/Source", placeholder = "e.g., Thai Cuisine", width = "100%"),
                    textInput("new_source_url", "Source URL (optional)", width = "100%"),
                    h5("Ingredients (one per line)"),
                    textAreaInput("new_ingredients_raw", NULL, placeholder = "1 1/2 cups flour\n2 eggs\n3 tbsp sugar", rows = 6, width = "100%"),
                    h5("Instructions (one per line)"),
                    textAreaInput("new_instructions", NULL, placeholder = "Mix dry ingredients\nAdd wet ingredients\nBake at 350°F for 30 minutes", rows = 6, width = "100%"),
                    div(
                      class = "mt-4",
                      actionButton("save_recipe", "Save Recipe", class = "btn btn-primary btn-lg", title = "Save recipe (Ctrl+S)", `data-bs-toggle` = "tooltip" , `aria-label` = "Save Recipe"),
                      actionButton("clear_recipe", "Clear", class = "btn btn-secondary btn-lg ms-2", title = "Clear the form", `data-bs-toggle` = "tooltip", `aria-label` = "Clear Recipe Form")
                    )
                  )
                )
              )
            )
          )
        ),

        # My Ingredients Tab
        tabPanel(
          "My Ingredients",
          div(
            class = "container-main",
            div(
              class = "section-header",
              h1(class = "section-title", "Ingredient Inventory"),
              p(class = "section-subtitle", "Track your available ingredients")
            ),

            div(
              class = "row mb-3",
              div(
                class = "col-lg-8 mx-auto",
                div(
                  class = "card",
                  div(
                    class = "card-body",
                    div(
                      class = "row",
                      div(
                        class = "col-md-4",
                        textInput("ing_name", "Ingredient Name", width = "100%")
                      ),
                      div(
                        class = "col-md-4",
                        numericInput("ing_qty", "Quantity", value = 1, min = 0, width = "100%")
                      ),
                      div(
                        class = "col-md-4",
                        textInput("ing_unit", "Unit", placeholder = "cup, tsp, oz, g, etc.", width = "100%")
                      )
                    ),
                    div(
                      class = "mt-3",
                      actionButton("save_ing", "Add Ingredient", class = "btn btn-primary", title = "Add or update ingredient", `data-bs-toggle` = "tooltip", `aria-label` = "Add Ingredient")
                    )
                  )
                )
              )
            ),

            div(
              class = "row",
              div(
                class = "col-lg-10 mx-auto",
                DT::dataTableOutput("ingredients_table")
              )
            )
          )
        ),

        # Settings Tab
        tabPanel(
          "Settings",
          div(
            class = "container-main",
            div(
              class = "section-header",
              h1(class = "section-title", "Settings & Admin"),
              p(class = "section-subtitle", "Manage preferences and data")
            ),

            div(
              class = "row",
              div(
                class = "col-lg-8 mx-auto",

                # Units Section
                div(
                  class = "card",
                  div(
                    class = "card-header",
                    tags$i(class = "fas fa-ruler icon-primary"), "Unit Preferences"
                  ),
                  div(
                    class = "card-body",
                    radioButtons("unit_system", "Preferred Unit System", choices = c("american" = "american", "european" = "european"), selected = "american", inline = TRUE),
                    actionButton("save_prefs", "Save Preferences", class = "btn btn-primary mt-3", title = "Save preferences", `data-bs-toggle` = "tooltip", `aria-label` = "Save Preferences")
                  )
                ),

                # Densities Section
                div(
                  class = "card mt-4",
                  div(
                    class = "card-header",
                    tags$i(class = "fas fa-flask icon-primary"), "Ingredient Densities"
                  ),
                  div(
                    class = "card-body",
                    p("View and edit ingredient densities (g/ml) for volume-to-mass conversions."),
                    DT::dataTableOutput("densities_table"),
                    div(
                      class = "mt-4",
                      h5("Add Custom Density"),
                      div(
                        class = "row",
                        div(
                          class = "col-md-6",
                          textInput("new_density_ingredient", "Ingredient name", width = "100%")
                        ),
                        div(
                          class = "col-md-6",
                          numericInput("new_density_value", "Density (g/ml)", value = 1.0, min = 0.1, step = 0.01, width = "100%")
                        )
                      ),
                      actionButton("add_density_btn", "Add Density", class = "btn btn-success mt-3", title = "Add a custom density", `data-bs-toggle` = "tooltip", `aria-label` = "Add Density")
                    )
                  )
                ),

                # Import/Export Section
                div(
                  class = "card mt-4",
                  div(
                    class = "card-header",
                    tags$i(class = "fas fa-exchange-alt icon-primary"), "Import & Export"
                  ),
                  div(
                    class = "card-body",
                    h5("Export Recipes"),
                    div(
                      class = "row",
                      div(
                        class = "col-md-6",
                        downloadButton("export_json", "Download JSON", class = "btn btn-primary w-100")
                      ),
                      div(
                        class = "col-md-6",
                        downloadButton("export_csv", "Download CSV", class = "btn btn-primary w-100")
                      )
                    ),
                    h5("Import Recipes", class = "mt-4"),
                    fileInput("import_file", "Choose JSON or CSV to import", accept = c('.json', '.csv')),
                    actionButton("import_btn", "Import File", class = "btn btn-success", title = "Import recipes from JSON or CSV", `data-bs-toggle` = "tooltip", `aria-label` = "Import File")
                  )
                )
              )
            )
          )
        )
      )
    )
  )
}
