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
                var el = document.getElementById('browse-search_query');
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
# Main app_ui — called per-session
# ---------------------------------------------------------------------------

#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  prefs        <- get_prefs()
  initial_mode <- if (identical(prefs$color_mode, "light")) "light" else "dark"
  theme        <- if (identical(initial_mode, "light")) app_theme_light() else app_theme_dark()

  shinyUI(
    bslib::page_sidebar(
      title        = NULL,
      theme        = theme,
      window_title = "recipeR",
      fillable     = FALSE,
      app_head_tags(),
      sidebar = app_sidebar(initial_mode),
      mod_home_ui("home"),
      mod_browse_ui("browse"),
      mod_add_ui("add"),
      mod_ingredients_ui("ingredients"),
      mod_shopping_ui("shopping"),
      mod_settings_ui("settings"),
      mod_cooking_ui("cooking")
    )
  )
}
