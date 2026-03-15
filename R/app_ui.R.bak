# recipeR UI — dark sidebar layout
# Bootstrap 5 (Shiny 1.7+), custom CSS in inst/app/www/custom.css

app_ui <- function() {
  shinyUI(
    tagList(
      # -----------------------------------------------------------------------
      # Head: meta, CSS, FA, shinyjs
      # -----------------------------------------------------------------------
      tags$head(
        shinyjs::useShinyjs(),
        tags$meta(charset = "utf-8"),
        tags$meta(
          name = "viewport",
          content = "width=device-width, initial-scale=1"
        ),
        tags$title("recipeR"),
        tags$link(
          rel = "stylesheet",
          href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
        ),
        tags$link(
          rel = "stylesheet",
          href = "www/custom.css"
        ),
        # JS: sidebar navigation + keyboard shortcut '/'
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
              // notify Shiny of current tab (used for autofocus etc)
              Shiny.setInputValue('active_tab', id);
            }

            document.addEventListener('DOMContentLoaded', function() {
              // wire sidebar nav clicks
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
              });

              // filter panel chevron toggle
              var fhdr = document.getElementById('filter-panel-header');
              if (fhdr) {
                fhdr.addEventListener('click', function() {
                  fhdr.classList.toggle('open');
                });
              }

              // Bootstrap tooltips
              var tips = [].slice.call(
                document.querySelectorAll('[data-bs-toggle=\"tooltip\"]')
              );
              tips.forEach(function(el) { new bootstrap.Tooltip(el); });
            });

            // expose helper for server-side navigation
            window.recipeR_navigate = activatePane;
          })();
          "
        ))
      ),

      # -----------------------------------------------------------------------
      # App Shell
      # -----------------------------------------------------------------------
      tags$div(
        id = "app-shell",

        # -------------------------------------------------------------------
        # Left Sidebar
        # -------------------------------------------------------------------
        tags$nav(
          id = "app-sidebar",

          # Logo
          tags$div(
            class = "sidebar-logo",
            tags$div(
              class = "sidebar-logo-icon",
              tags$i(class = "fas fa-utensils")
            ),
            tags$span(class = "sidebar-logo-text", "recipeR")
          ),

          # Nav items
          tags$div(
            class = "sidebar-nav",

            tags$button(
              class = "sidebar-nav-item active",
              `data-pane` = "home",
              tags$i(class = "fas fa-house"),
              "Home"
            ),
            tags$button(
              class = "sidebar-nav-item",
              `data-pane` = "browse",
              tags$i(class = "fas fa-book-open"),
              "Browse Recipes"
            ),
            tags$button(
              class = "sidebar-nav-item",
              `data-pane` = "add",
              tags$i(class = "fas fa-plus"),
              "Add Recipe"
            ),
            tags$button(
              class = "sidebar-nav-item",
              `data-pane` = "ingredients",
              tags$i(class = "fas fa-carrot"),
              "My Ingredients"
            ),
            tags$button(
              class = "sidebar-nav-item",
              `data-pane` = "shopping",
              tags$i(class = "fas fa-cart-shopping"),
              "Shopping List"
            ),
            tags$button(
              class = "sidebar-nav-item",
              `data-pane` = "settings",
              tags$i(class = "fas fa-gear"),
              "Settings"
            )
          ),

          tags$div(
            class = "sidebar-footer",
            "Press / to search"
          )
        ),

        # -------------------------------------------------------------------
        # Main Content
        # -------------------------------------------------------------------
        tags$main(
          id = "main-content",

          # -----------------------------------------------------------------
          # HOME PANE
          # -----------------------------------------------------------------
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

            # Stats
            tags$div(
              class = "stats-grid",
              tags$div(
                class = "stat-card",
                tags$div(class = "stat-card-icon", tags$i(class = "fas fa-book")),
                tags$div(class = "stat-value", textOutput("stat_total_recipes")),
                tags$div(class = "stat-label", "Total Recipes")
              ),
              tags$div(
                class = "stat-card",
                tags$div(class = "stat-card-icon", tags$i(class = "fas fa-globe")),
                tags$div(class = "stat-value", textOutput("stat_cuisines")),
                tags$div(class = "stat-label", "Cuisines")
              ),
              tags$div(
                class = "stat-card",
                tags$div(class = "stat-card-icon", tags$i(class = "fas fa-carrot")),
                tags$div(class = "stat-value", textOutput("stat_ingredients")),
                tags$div(class = "stat-label", "Ingredients")
              ),
              tags$div(
                class = "stat-card",
                tags$div(class = "stat-card-icon", tags$i(class = "fas fa-chart-bar")),
                tags$div(class = "stat-value", textOutput("stat_avg_ingredients")),
                tags$div(class = "stat-label", "Avg per Recipe")
              )
            ),

            # Features
            tags$div(
              class = "feature-grid",
              tags$div(
                class = "feature-card",
                tags$div(class = "feature-card-icon", tags$i(class = "fas fa-magnifying-glass")),
                tags$h5("Browse Recipes"),
                tags$p(
                  "Search and filter your collection with live ingredient match scores."
                )
              ),
              tags$div(
                class = "feature-card",
                tags$div(class = "feature-card-icon", tags$i(class = "fas fa-plus")),
                tags$h5("Add Recipes"),
                tags$p(
                  "Create new recipes with free-text ingredient parsing and step tracking."
                )
              ),
              tags$div(
                class = "feature-card",
                tags$div(class = "feature-card-icon", tags$i(class = "fas fa-scale-balanced")),
                tags$h5("Scale & Match"),
                tags$p(
                  "Scale any recipe and auto-add missing ingredients to your shopping list."
                )
              ),
              tags$div(
                class = "feature-card",
                tags$div(class = "feature-card-icon", tags$i(class = "fas fa-gear")),
                tags$h5("Settings"),
                tags$p(
                  "Manage unit preferences, densities, and import/export your recipes."
                )
              )
            )
          ),

          # -----------------------------------------------------------------
          # BROWSE PANE
          # -----------------------------------------------------------------
          tags$div(
            id = "pane-browse",
            class = "content-pane",

            tags$div(
              class = "page-header",
              tags$div(
                style = "display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:0.75rem;",
                tags$div(
                  tags$h1(class = "page-title", "Browse Recipes"),
                  tags$p(class = "page-subtitle", "Click a card to view details and scale")
                ),
                tags$div(
                  style = "display:flex;gap:0.5rem;",
                  actionButton(
                    "compare_selected",
                    tagList(tags$i(class = "fas fa-code-compare"), "Compare"),
                    class = "btn btn-secondary btn-sm",
                    title = "Select exactly two cards then click",
                    `data-bs-toggle` = "tooltip"
                  )
                )
              )
            ),

            # Search
            tags$div(
              class = "search-bar-wrap",
              tags$i(class = "fas fa-magnifying-glass search-icon"),
              textInput(
                "search_query",
                NULL,
                placeholder = "Search recipes...",
                width = "100%"
              ),
              tags$span(class = "search-hint", "/")
            ),

            # Filters (collapsible)
            tags$div(
              class = "filter-panel-wrap",
              tags$div(
                id = "filter-panel-header",
                class = "filter-panel-header",
                tags$h6(
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
                style = "display:none;",
                tags$div(
                  class = "row g-3 mb-3",
                  tags$div(
                    class = "col-md-6",
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
                    class = "col-md-6",
                    tags$label("Source URL", `for` = "source_filter"),
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
            ),

            # Browse stats bar
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
              )
            ),

            # Recipe cards grid
            uiOutput("recipe_cards_grid")
          ),

          # -----------------------------------------------------------------
          # ADD RECIPE PANE
          # -----------------------------------------------------------------
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

            tags$div(
              class = "row",
              tags$div(
                class = "col-lg-7",
                tags$div(
                  class = "panel",
                  tags$div(class = "panel-header", tags$h5("Recipe Details")),
                  tags$div(
                    class = "panel-body",
                    textInput(
                      "new_title",
                      "Title",
                      placeholder = "e.g., Vegetable Pad Thai",
                      width = "100%"
                    ),
                    textInput(
                      "new_source",
                      "Cuisine / Source",
                      placeholder = "e.g., Thai",
                      width = "100%"
                    ),
                    textInput("new_source_url", "Source URL (optional)", width = "100%"),
                    tags$label("Ingredients", style = "margin-top:0.5rem;"),
                    tags$small(
                      class = "text-muted d-block mb-1",
                      "One per line — e.g. \"1 1/2 cups flour\""
                    ),
                    textAreaInput(
                      "new_ingredients_raw",
                      NULL,
                      placeholder = "1 1/2 cups flour\n2 large eggs\n3 tbsp sugar",
                      rows = 6,
                      width = "100%"
                    ),
                    tags$label("Instructions", style = "margin-top:0.5rem;"),
                    tags$small(
                      class = "text-muted d-block mb-1",
                      "One step per line"
                    ),
                    textAreaInput(
                      "new_instructions",
                      NULL,
                      placeholder = "Mix dry ingredients\nAdd wet ingredients\nBake 30 min at 350°F",
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
                )
              )
            )
          ),

          # -----------------------------------------------------------------
          # MY INGREDIENTS PANE
          # -----------------------------------------------------------------
          tags$div(
            id = "pane-ingredients",
            class = "content-pane",

            tags$div(
              class = "page-header",
              tags$h1(class = "page-title", "Ingredient Inventory"),
              tags$p(class = "page-subtitle", "Track what you have — drives recipe match scores")
            ),

            tags$div(
              class = "row",
              tags$div(
                class = "col-lg-8",
                tags$div(
                  class = "panel mb-3",
                  tags$div(class = "panel-header", tags$h5("Add Ingredient")),
                  tags$div(
                    class = "panel-body",
                    tags$div(
                      class = "row g-3",
                      tags$div(
                        class = "col-md-4",
                        textInput("ing_name", "Name", width = "100%")
                      ),
                      tags$div(
                        class = "col-md-4",
                        numericInput("ing_qty", "Quantity", value = 1, min = 0, width = "100%")
                      ),
                      tags$div(
                        class = "col-md-4",
                        textInput(
                          "ing_unit",
                          "Unit",
                          placeholder = "cup, tsp, g…",
                          width = "100%"
                        )
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
              )
            )
          ),

          # -----------------------------------------------------------------
          # SHOPPING LIST PANE
          # -----------------------------------------------------------------
          tags$div(
            id = "pane-shopping",
            class = "content-pane",

            tags$div(
              class = "page-header",
              tags$h1(class = "page-title", "Shopping List"),
              tags$p(
                class = "page-subtitle",
                "Add manually or via a recipe's missing ingredients"
              )
            ),

            tags$div(
              class = "row",
              tags$div(
                class = "col-lg-5",
                tags$div(
                  class = "panel mb-3",
                  tags$div(
                    class = "panel-body",
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
                tags$div(
                  class = "panel",
                  tags$div(
                    class = "panel-header",
                    tags$h5(
                      tags$i(class = "fas fa-cart-shopping"),
                      " Items"
                    ),
                    actionButton(
                      "clear_shop_list",
                      "Clear all",
                      class = "btn btn-danger btn-sm"
                    )
                  ),
                  tags$div(
                    class = "panel-body",
                    uiOutput("shopping_list_output")
                  )
                )
              )
            )
          ),

          # -----------------------------------------------------------------
          # SETTINGS PANE
          # -----------------------------------------------------------------
          tags$div(
            id = "pane-settings",
            class = "content-pane",

            tags$div(
              class = "page-header",
              tags$h1(class = "page-title", "Settings"),
              tags$p(class = "page-subtitle", "Preferences, densities, import / export")
            ),

            tags$div(
              class = "row",
              tags$div(
                class = "col-lg-7",

                # Units
                tags$div(
                  class = "panel mb-4",
                  tags$div(
                    class = "panel-header",
                    tags$h5(tags$i(class = "fas fa-ruler"), " Unit Preferences")
                  ),
                  tags$div(
                    class = "panel-body",
                    radioButtons(
                      "unit_system",
                      NULL,
                      choices = c("American" = "american", "European / Metric" = "european"),
                      selected = "american",
                      inline = TRUE
                    ),
                    actionButton(
                      "save_prefs",
                      tagList(tags$i(class = "fas fa-floppy-disk"), " Save"),
                      class = "btn btn-primary mt-3"
                    )
                  )
                ),

                # Densities
                tags$div(
                  class = "panel mb-4",
                  tags$div(
                    class = "panel-header",
                    tags$h5(tags$i(class = "fas fa-flask"), " Ingredient Densities")
                  ),
                  tags$div(
                    class = "panel-body",
                    tags$p(
                      class = "text-muted",
                      style = "font-size:0.825rem;margin-bottom:1rem;",
                      "Densities (g/ml) are used for volume-to-mass conversions."
                    ),
                    DT::dataTableOutput("densities_table"),
                    tags$div(class = "divider"),
                    tags$h6(
                      style = "font-size:0.8rem;font-weight:700;text-transform:uppercase;
                               letter-spacing:0.5px;color:var(--text-muted);margin-bottom:0.75rem;",
                      "Add Custom Density"
                    ),
                    tags$div(
                      class = "row g-3",
                      tags$div(
                        class = "col-md-6",
                        textInput(
                          "new_density_ingredient",
                          "Ingredient",
                          width = "100%"
                        )
                      ),
                      tags$div(
                        class = "col-md-6",
                        numericInput(
                          "new_density_value",
                          "Density (g/ml)",
                          value = 1.0,
                          min = 0.1,
                          step = 0.01,
                          width = "100%"
                        )
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
                  )
                ),

                # Import / Export
                tags$div(
                  class = "panel",
                  tags$div(
                    class = "panel-header",
                    tags$h5(tags$i(class = "fas fa-right-left"), " Import & Export")
                  ),
                  tags$div(
                    class = "panel-body",
                    tags$h6(
                      style = "font-size:0.8rem;font-weight:700;color:var(--text-muted);
                               text-transform:uppercase;letter-spacing:0.5px;margin-bottom:0.75rem;",
                      "Export"
                    ),
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
                    tags$div(class = "divider"),
                    tags$h6(
                      style = "font-size:0.8rem;font-weight:700;color:var(--text-muted);
                               text-transform:uppercase;letter-spacing:0.5px;margin-bottom:0.75rem;",
                      "Import"
                    ),
                    fileInput(
                      "import_file",
                      NULL,
                      accept = c(".json", ".csv"),
                      placeholder = "Choose JSON or CSV…"
                    ),
                    actionButton(
                      "import_btn",
                      tagList(tags$i(class = "fas fa-upload"), " Import"),
                      class = "btn btn-success"
                    )
                  )
                )
              )
            )
          )
        ) # end #main-content
      ), # end #app-shell

      # -----------------------------------------------------------------------
      # Recipe Detail Offcanvas Drawer (right side)
      # -----------------------------------------------------------------------
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
            "Recipe Details"
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
      ),

      # -----------------------------------------------------------------------
      # Compare Modal
      # -----------------------------------------------------------------------
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
            tags$div(
              class = "modal-body",
              uiOutput("recipe_compare_content")
            ),
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
  )
}
