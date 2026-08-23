# recipeR UI — bslib 0.9 + Bootstrap 5 dark / light theme
# Layout: page_sidebar() + custom JS tab navigation
# Components: card(), value_box(), layout_columns(), accordion()

# ---------------------------------------------------------------------------
# Theme — shinyglass Liquid Glass (bslib theme, runtime light/dark/auto)
# ---------------------------------------------------------------------------

#' @noRd
app_theme <- function(mode = c("dark", "light", "auto")) {
  mode <- match.arg(mode)
  shinyglass::glass_theme(
    preset = mode,
    primary = "#6366f1",
    intensity = 0.45
  )
}

# ---------------------------------------------------------------------------
# Head elements
# ---------------------------------------------------------------------------

#' @noRd
app_head_tags <- function() {
  tags$head(
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
            el.removeAttribute('aria-current');
          });
          var pane = document.getElementById('pane-' + id);
          if (pane) pane.classList.add('active');
          var nav = document.querySelector('[data-pane=\"' + id + '\"]');
          if (nav) {
            nav.classList.add('active');
            nav.setAttribute('aria-current', 'page');
          }
          Shiny.setInputValue('active_tab', id);
        }

        document.addEventListener('DOMContentLoaded', function() {
          document.querySelectorAll('.sidebar-nav-item').forEach(function(el) {
            el.addEventListener('click', function() {
              activatePane(el.getAttribute('data-pane'));
            });
          });

          // Home feature cards navigate to their pane
          document.querySelectorAll('[data-goto]').forEach(function(el) {
            var go = function() { activatePane(el.getAttribute('data-goto')); };
            el.addEventListener('click', go);
            el.addEventListener('keydown', function(e) {
              if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); go(); }
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
              var open = fhdr.classList.toggle('open');
              fhdr.setAttribute('aria-expanded', open ? 'true' : 'false');
            });
            fhdr.addEventListener('keydown', function(e) {
              if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                fhdr.click();
              }
            });
          }
        });

        Shiny.addCustomMessageHandler('runjs', function(msg) {
          eval(msg.code);
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
      role = "navigation",
      `aria-label` = "Primary",
      tags$button(
        type = "button",
        class = "sidebar-nav-item active",
        `aria-current` = "page",
        `data-pane` = "home",
        tags$i(class = "fas fa-house"),
        " Home"
      ),
      tags$button(
        type = "button",
        class = "sidebar-nav-item",
        `data-pane` = "browse",
        tags$i(class = "fas fa-book-open"),
        " Browse"
      ),
      tags$button(
        type = "button",
        class = "sidebar-nav-item",
        `data-pane` = "add",
        tags$i(class = "fas fa-plus"),
        " Add Recipe"
      ),
      tags$button(
        type = "button",
        class = "sidebar-nav-item",
        `data-pane` = "ingredients",
        tags$i(class = "fas fa-carrot"),
        " My Ingredients"
      ),
      tags$button(
        type = "button",
        class = "sidebar-nav-item",
        `data-pane` = "shopping",
        tags$i(class = "fas fa-cart-shopping"),
        " Shopping"
      ),
      tags$button(
        type = "button",
        class = "sidebar-nav-item",
        `data-pane` = "settings",
        tags$i(class = "fas fa-gear"),
        " Settings"
      )
    ),

    tags$div(
      class = "sidebar-footer",
      shinyglass::glass_theme_toggle(
        inputId = "color_mode",
        selected = initial_mode
      ),
      shinyglass::glass_intensity_slider(
        inputId = "glass_intensity",
        label = NULL
      ),
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
  prefs <- get_prefs()
  initial_mode <- prefs$color_mode %||% "dark"
  if (!initial_mode %in% c("light", "dark", "auto")) {
    initial_mode <- "dark"
  }
  theme <- app_theme(initial_mode)

  shinyUI(
    bslib::page_sidebar(
      title = NULL,
      theme = theme,
      window_title = "recipeR",
      fillable = FALSE,
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
