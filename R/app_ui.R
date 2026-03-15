# recipeR UI — bslib 0.9 + Bootstrap 5 dark / light theme
# Layout: page_sidebar() + custom JS tab navigation
# Components: card(), value_box(), layout_columns(), accordion()

# ---------------------------------------------------------------------------
# Themes
# ---------------------------------------------------------------------------

#' @noRd
app_theme_dark <- function() {
  bslib::bs_theme(
    version = 5,
    bg = "#0f1117",
    fg = "#e2e8f0",
    primary = "#6366f1",
    secondary = "#4b5563",
    success = "#10b981",
    warning = "#f59e0b",
    danger = "#ef4444",
    info = "#38bdf8",
    "font-size-base" = "0.875rem",
    "card-bg" = "#1a1d27",
    "card-border-color" = "#2e3347",
    "card-cap-bg" = "#22263a",
    "card-cap-color" = "#c8d3e0",
    "input-bg" = "#22263a",
    "input-border-color" = "#3a3f57",
    "input-color" = "#e2e8f0",
    "input-placeholder-color" = "#64748b",
    "input-focus-border-color" = "#6366f1",
    "border-color" = "#2e3347",
    "link-color" = "#818cf8",
    "modal-content-bg" = "#1a1d27",
    "modal-header-border-color" = "#2e3347",
    "modal-footer-border-color" = "#2e3347",
    "offcanvas-bg" = "#1a1d27",
    "offcanvas-border-color" = "#2e3347",
    "dropdown-bg" = "#1a1d27",
    "dropdown-border-color" = "#2e3347",
    "table-color" = "#e2e8f0",
    "table-bg" = "transparent",
    "table-striped-bg" = "rgba(99,102,241,0.05)",
    base_font = bslib::font_google("Inter")
  )
}

#' @noRd
app_theme_light <- function() {
  bslib::bs_theme(
    version = 5,
    bg = "#f8fafc",
    fg = "#1e293b",
    primary = "#4f46e5",
    secondary = "#94a3b8",
    success = "#059669",
    warning = "#d97706",
    danger = "#dc2626",
    info = "#0284c7",
    "font-size-base" = "0.875rem",
    "card-bg" = "#ffffff",
    "card-border-color" = "#e2e8f0",
    "card-cap-bg" = "#f8fafc",
    "card-cap-color" = "#475569",
    "input-bg" = "#ffffff",
    "input-border-color" = "#cbd5e1",
    "input-color" = "#1e293b",
    "input-placeholder-color" = "#94a3b8",
    "input-focus-border-color" = "#4f46e5",
    "border-color" = "#e2e8f0",
    "link-color" = "#4f46e5",
    "modal-content-bg" = "#ffffff",
    "offcanvas-bg" = "#f8fafc",
    "table-color" = "#1e293b",
    "table-bg" = "transparent",
    base_font = bslib::font_google("Inter")
  )
}

# ---------------------------------------------------------------------------
# Head elements
# ---------------------------------------------------------------------------

#' @noRd
app_head_tags <- function() {
  tags$head(
    shinyjs::useShinyjs(),
    tags$meta(charset = "utf-8"),
    tags$meta(
      name = "viewport",
      content = "width=device-width, initial-scale=1"
    ),
    tags$link(
      rel = "stylesheet",
      href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
    ),
    tags$link(rel = "stylesheet", href = "www/custom.css"),
    tags$script(HTML(
      "
      (function() {
        function activatePane(id) {
          document.querySelectorAll('.content-pane').forEach(function(el) {
            el.classList.remove('active');
          });
          document.querySelectorAll('.sidebar-nav-item').forEach(function(el) {
            el.classList.remove('active');
          });
          var pane = document.getElementById('pane-' + id);
          if (pane) pane.classList.add('active');
          var nav = document.querySelector('[data-pane=\"' + id + '\"]');
          if (nav) nav.classList.add('active');
          Shiny.setInputValue('active_tab', id);
        }

        document.addEventListener('DOMContentLoaded', function() {
          document.querySelectorAll('.sidebar-nav-item').forEach(function(el) {
            el.addEventListener('click', function() {
              activatePane(el.getAttribute('data-pane'));
            });
          });

          // '/' focuses search input from anywhere
          document.addEventListener('keydown', function(e) {
            var tag = document.activeElement.tagName;
            if (e.key === '/' && tag !== 'INPUT' && tag !== 'TEXTAREA') {
              e.preventDefault();
              activatePane('browse');
              setTimeout(function() {
                var el = document.getElementById('search_query');
                if (el) el.focus();
              }, 80);
            }
            // Escape exits cooking mode
            if (e.key === 'Escape') {
              var cook = document.getElementById('pane-cooking');
              if (cook && cook.classList.contains('active')) activatePane('browse');
            }
          });

          var fhdr = document.getElementById('filter-panel-header');
          if (fhdr) {
            fhdr.addEventListener('click', function() {
              fhdr.classList.toggle('open');
            });
          }

          var tips = [].slice.call(document.querySelectorAll('[data-bs-toggle=\"tooltip\"]'));
          tips.forEach(function(el) { new bootstrap.Tooltip(el); });
        });

        window.recipeR_navigate = activatePane;
      })();
      "
    ))
  )
}

# ---------------------------------------------------------------------------
# Sidebar
# ---------------------------------------------------------------------------

#' @noRd
app_sidebar <- function(initial_mode = "dark") {
  bslib::sidebar(
    id = "app-sidebar",
    width = 220,
    open = "desktop",
    bg = NULL,
    padding = "0",

    tags$div(
      class = "sidebar-logo",
      tags$div(class = "sidebar-logo-icon", tags$i(class = "fas fa-utensils")),
      tags$span(class = "sidebar-logo-text", "recipeR")
    ),

    tags$div(
      class = "sidebar-nav",
      tags$button(
        class = "sidebar-nav-item active",
        `data-pane` = "home",
        tags$i(class = "fas fa-house"),
        " Home"
      ),
      tags$button(
        class = "sidebar-nav-item",
        `data-pane` = "browse",
        tags$i(class = "fas fa-book-open"),
        " Browse"
      ),
      tags$button(
        class = "sidebar-nav-item",
        `data-pane` = "add",
        tags$i(class = "fas fa-plus"),
        " Add Recipe"
      ),
      tags$button(
        class = "sidebar-nav-item",
        `data-pane` = "ingredients",
        tags$i(class = "fas fa-carrot"),
        " My Ingredients"
      ),
      tags$button(
        class = "sidebar-nav-item",
        `data-pane` = "shopping",
        tags$i(class = "fas fa-cart-shopping"),
        " Shopping"
      ),
      tags$button(
        class = "sidebar-nav-item",
        `data-pane` = "settings",
        tags$i(class = "fas fa-gear"),
        " Settings"
      )
    ),

    tags$div(
      class = "sidebar-footer",
      bslib::input_dark_mode(id = "color_mode", mode = initial_mode),
      tags$span(class = "sidebar-hint", "/ to search")
    )
  )
}

# ---------------------------------------------------------------------------
# HOME pane
# ---------------------------------------------------------------------------

#' @noRd
pane_home <- function() {
  tags$div(
    id = "pane-home",
    class = "content-pane active",

    tags$div(
      class = "page-header",
      tags$h1(class = "page-title", "Welcome to recipeR"),
      tags$p(
        class = "page-subtitle",
        "Your personal recipe manager with ingredient matching"
      )
    ),

    bslib::layout_columns(
      col_widths = c(3, 3, 3, 3),
      bslib::value_box(
        title = "Recipes",
        value = textOutput("stat_total_recipes", inline = TRUE),
        showcase = tags$i(class = "fas fa-book fa-lg"),
        theme = "primary"
      ),
      bslib::value_box(
        title = "Cuisines",
        value = textOutput("stat_cuisines", inline = TRUE),
        showcase = tags$i(class = "fas fa-globe fa-lg"),
        theme = "info"
      ),
      bslib::value_box(
        title = "Ingredients",
        value = textOutput("stat_ingredients", inline = TRUE),
        showcase = tags$i(class = "fas fa-carrot fa-lg"),
        theme = "success"
      ),
      bslib::value_box(
        title = "Avg per Recipe",
        value = textOutput("stat_avg_ingredients", inline = TRUE),
        showcase = tags$i(class = "fas fa-chart-bar fa-lg"),
        theme = "warning"
      )
    ),

    bslib::layout_columns(
      col_widths = c(3, 3, 3, 3),
      bslib::card(
        bslib::card_body(
          tags$div(
            class = "feature-card-icon",
            tags$i(class = "fas fa-magnifying-glass")
          ),
          tags$h5("Browse Recipes"),
          tags$p(
            "Search and filter your collection with live ingredient match scores."
          )
        )
      ),
      bslib::card(
        bslib::card_body(
          tags$div(class = "feature-card-icon", tags$i(class = "fas fa-plus")),
          tags$h5("Add Recipes"),
          tags$p(
            "Create recipes with free-text ingredient parsing and live preview."
          )
        )
      ),
      bslib::card(
        bslib::card_body(
          tags$div(
            class = "feature-card-icon",
            tags$i(class = "fas fa-scale-balanced")
          ),
          tags$h5("Scale & Cook"),
          tags$p(
            "Scale any recipe and cook step-by-step with a built-in timer."
          )
        )
      ),
      bslib::card(
        bslib::card_body(
          tags$div(class = "feature-card-icon", tags$i(class = "fas fa-gear")),
          tags$h5("Settings"),
          tags$p(
            "Manage unit preferences, densities, and import/export your recipes."
          )
        )
      )
    )
  )
}

# ---------------------------------------------------------------------------
# BROWSE pane
# ---------------------------------------------------------------------------

#' @noRd
pane_browse <- function() {
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
          "compare_selected",
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
            "search_query",
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
              "reset_filters",
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
              tags$label("Cuisine", `for` = "cuisine_filter"),
              shinyWidgets::pickerInput(
                "cuisine_filter",
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
              tags$label("Source", `for` = "source_filter"),
              shinyWidgets::pickerInput(
                "source_filter",
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
          textOutput("browse_total_recipes", inline = TRUE)
        ),
        tags$span(class = "browse-stat-label", "recipes")
      ),
      tags$div(
        class = "browse-stat",
        tags$span(
          class = "browse-stat-value",
          textOutput("browse_cuisines_count", inline = TRUE)
        ),
        tags$span(class = "browse-stat-label", "cuisines")
      ),
      tags$div(
        class = "browse-stat",
        tags$span(
          class = "browse-stat-value",
          textOutput("browse_avg_ingredients", inline = TRUE)
        ),
        tags$span(class = "browse-stat-label", "avg ingredients")
      ),
      tags$div(
        class = "browse-stat",
        tags$span(
          class = "browse-stat-value",
          textOutput("browse_avg_steps", inline = TRUE)
        ),
        tags$span(class = "browse-stat-label", "avg steps")
      ),
      tags$div(
        style = "margin-left:auto;",
        selectInput(
          "browse_sort",
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

    uiOutput("recipe_cards_grid")
  )
}

# ---------------------------------------------------------------------------
# ADD RECIPE pane
# ---------------------------------------------------------------------------

#' @noRd
pane_add <- function() {
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
            "new_title",
            "Title",
            placeholder = "e.g., Vegetable Pad Thai",
            width = "100%"
          ),
          bslib::layout_columns(
            col_widths = c(6, 6),
            textInput(
              "new_source",
              "Cuisine / Source",
              placeholder = "e.g., Thai",
              width = "100%"
            ),
            numericInput(
              "new_servings",
              "Servings",
              value = NA,
              min = 1,
              step = 1,
              width = "100%"
            )
          ),
          textInput("new_source_url", "Source URL (optional)", width = "100%"),
          textInput("new_image_url", "Image URL (optional)", width = "100%"),
          tags$div(
            tags$label("Tags"),
            tags$small(
              class = "text-muted d-block mb-1",
              "Press Enter or comma after each tag"
            ),
            selectizeInput(
              "new_tags",
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
            "new_ingredients_raw",
            NULL,
            placeholder = "1 1/2 cups flour\n2 large eggs\n3 tbsp sugar",
            rows = 6,
            width = "100%"
          ),
          tags$label("Instructions", style = "margin-top:0.5rem;"),
          tags$small(class = "text-muted d-block mb-1", "One step per line"),
          textAreaInput(
            "new_instructions",
            NULL,
            placeholder = "Mix dry ingredients\nAdd wet ingredients\nBake 30 min at 350\u00b0F",
            rows = 6,
            width = "100%"
          ),
          tags$div(
            class = "mt-3",
            style = "display:flex;gap:0.5rem;",
            actionButton(
              "save_recipe",
              tagList(tags$i(class = "fas fa-floppy-disk"), " Save Recipe"),
              class = "btn btn-primary btn-lg"
            ),
            actionButton(
              "clear_recipe",
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
        bslib::card_body(uiOutput("ingredient_preview"))
      )
    )
  )
}

# ---------------------------------------------------------------------------
# MY INGREDIENTS pane
# ---------------------------------------------------------------------------

#' @noRd
pane_ingredients <- function() {
  tags$div(
    id = "pane-ingredients",
    class = "content-pane",

    tags$div(
      class = "page-header",
      tags$h1(class = "page-title", "Ingredient Inventory"),
      tags$p(
        class = "page-subtitle",
        "Track what you have \u2014 drives recipe match scores"
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
              textInput("ing_name", "Name", width = "100%"),
              numericInput(
                "ing_qty",
                "Quantity",
                value = 1,
                min = 0,
                width = "100%"
              ),
              textInput(
                "ing_unit",
                "Unit",
                placeholder = "cup, tsp, g\u2026",
                width = "100%"
              )
            ),
            tags$div(
              class = "mt-3",
              actionButton(
                "save_ing",
                tagList(tags$i(class = "fas fa-plus"), " Add"),
                class = "btn btn-primary"
              )
            )
          )
        ),
        DT::dataTableOutput("ingredients_table")
      ),

      bslib::card(
        bslib::card_header(tags$h5("Inventory Stats")),
        bslib::card_body(uiOutput("inventory_stats"))
      )
    )
  )
}

# ---------------------------------------------------------------------------
# SHOPPING LIST pane
# ---------------------------------------------------------------------------

#' @noRd
pane_shopping <- function() {
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
                "new_shop_item",
                NULL,
                placeholder = "e.g., 2 cups flour",
                width = "100%"
              ),
              actionButton(
                "add_shop_item",
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
                "remove_checked_items",
                tagList(tags$i(class = "fas fa-check-double"), " Done"),
                class = "btn btn-success btn-sm"
              ),
              actionButton(
                "clear_shop_list",
                tagList(tags$i(class = "fas fa-trash"), " Clear"),
                class = "btn btn-danger btn-sm"
              )
            )
          ),
          bslib::card_body(uiOutput("shopping_list_output"))
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

# ---------------------------------------------------------------------------
# SETTINGS pane
# ---------------------------------------------------------------------------

#' @noRd
pane_settings <- function() {
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
            "unit_system",
            NULL,
            choices = c(
              "American" = "american",
              "European / Metric" = "european"
            ),
            selected = "american",
            inline = TRUE
          ),
          actionButton(
            "save_prefs",
            tagList(tags$i(class = "fas fa-floppy-disk"), " Save"),
            class = "btn btn-primary mt-2"
          )
        ),

        bslib::accordion_panel(
          value = "densities",
          title = tagList(
            tags$i(class = "fas fa-flask", style = "margin-right:0.4rem;"),
            "Ingredient Densities"
          ),
          tags$p(
            class = "text-muted",
            style = "font-size:0.825rem;margin-bottom:1rem;",
            "Densities (g/ml) enable volume-to-mass conversions."
          ),
          DT::dataTableOutput("densities_table"),
          tags$hr(),
          tags$h6(class = "settings-section-label", "Add Custom Density"),
          bslib::layout_columns(
            col_widths = c(6, 6),
            textInput("new_density_ingredient", "Ingredient", width = "100%"),
            numericInput(
              "new_density_value",
              "Density (g/ml)",
              value = 1.0,
              min = 0.1,
              step = 0.01,
              width = "100%"
            )
          ),
          tags$div(
            class = "mt-3",
            style = "display:flex;gap:0.5rem;",
            actionButton(
              "add_density_btn",
              tagList(tags$i(class = "fas fa-plus"), " Add"),
              class = "btn btn-success"
            ),
            actionButton(
              "delete_density_btn",
              tagList(tags$i(class = "fas fa-trash"), " Delete Selected"),
              class = "btn btn-danger"
            )
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
              "export_json",
              tagList(tags$i(class = "fas fa-file-code"), " JSON"),
              class = "btn btn-secondary"
            ),
            downloadButton(
              "export_csv",
              tagList(tags$i(class = "fas fa-file-csv"), " CSV"),
              class = "btn btn-secondary"
            )
          ),
          tags$hr(),
          tags$h6(class = "settings-section-label", "Import Recipes"),
          fileInput(
            "import_file",
            NULL,
            accept = c(".json", ".csv"),
            placeholder = "Choose JSON or CSV\u2026"
          ),
          actionButton(
            "import_btn",
            tagList(tags$i(class = "fas fa-upload"), " Import"),
            class = "btn btn-success"
          ),
          tags$hr(),
          tags$h6(class = "settings-section-label", "Backup & Restore"),
          tags$div(
            style = "display:flex;gap:0.5rem;flex-wrap:wrap;",
            actionButton(
              "backup_btn",
              tagList(tags$i(class = "fas fa-box-archive"), " Create Backup"),
              class = "btn btn-secondary"
            ),
            actionButton(
              "restore_btn",
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
            " \u2014 Jump to search",
            tags$br(),
            tags$kbd("Esc"),
            " \u2014 Exit cooking mode"
          )
        )
      )
    )
  )
}

# ---------------------------------------------------------------------------
# COOKING MODE pane
# ---------------------------------------------------------------------------

#' @noRd
pane_cooking <- function() {
  tags$div(
    id = "pane-cooking",
    class = "content-pane cooking-mode",
    uiOutput("cooking_mode_ui")
  )
}

# ---------------------------------------------------------------------------
# Recipe detail offcanvas drawer
# ---------------------------------------------------------------------------

#' @noRd
drawer_offcanvas <- function() {
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
        uiOutput("drawer_title", inline = TRUE)
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
      uiOutput("recipe_detail_content")
    )
  )
}

# ---------------------------------------------------------------------------
# Recipe compare modal
# ---------------------------------------------------------------------------

#' @noRd
compare_modal_ui <- function() {
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
        tags$div(class = "modal-body", uiOutput("recipe_compare_content")),
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
}

# ---------------------------------------------------------------------------
# Main app_ui — called per-session
# ---------------------------------------------------------------------------

#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  prefs <- get_prefs()
  initial_mode <- if (identical(prefs$color_mode, "light")) "light" else "dark"
  theme <- if (identical(initial_mode, "light")) {
    app_theme_light()
  } else {
    app_theme_dark()
  }

  shinyUI(
    bslib::page_sidebar(
      title = NULL,
      theme = theme,
      window_title = "recipeR",
      fillable = FALSE,

      app_head_tags(),

      sidebar = app_sidebar(initial_mode),

      pane_home(),
      pane_browse(),
      pane_add(),
      pane_ingredients(),
      pane_shopping(),
      pane_settings(),
      pane_cooking(),

      drawer_offcanvas(),
      compare_modal_ui()
    )
  )
}
