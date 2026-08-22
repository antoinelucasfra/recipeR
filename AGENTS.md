# AGENTS.md — recipeR

## Project Overview

recipeR is a golem-based Shiny application for managing recipes and ingredients. It provides unit conversion (American/metric), ingredient matching against inventory, density-based volume-to-mass conversions, shopping list management, and file-based persistence. Data is stored in RDS files under `~/.recipeR/`.

## Architecture & Data Flow

The app follows the standard golem pattern: `app_ui` + `app_server` wired in `run_app()`.

### Server entry (`app_server.R`)
Central `reactiveValues` object `rv` holds the entire app state:
- `rv$recipes` — list of recipe objects
- `rv$ingredients` — ingredient inventory
- `rv$shopping` — shopping list items
- `rv$compare_pair`, `rv$selected_card_ids` — browse tab state
- `rv$cooking_recipe`, `rv$cooking_step` — cooking mode state

`refresh_data()` is called on start and after every mutation (add/edit/delete recipe or ingredient) to reload from disk. Theme toggle in `app_server` calls `session$setCurrentTheme()` and persists preference via `save_prefs()`.

### Data flow
```
User action -> Module server -> data_storage.R functions -> RDS files on disk
                    ^
                    | (refresh_data after mutations)
                    v
              rv reactiveValues
```

### Module wiring (app_server.R)
```
mod_home_server("home", rv)
mod_browse_server("browse", rv, refresh_data)
mod_add_server("add", rv, refresh_data)
mod_ingredients_server("ingredients", rv, refresh_data)
mod_cooking_server("cooking", rv)
mod_shopping_server("shopping", rv)
mod_settings_server("settings", rv, refresh_data, session)
```

## Key Directories

| Directory | Purpose |
|-----------|---------|
  | `R/` | All source code (15 files): modules, helpers, UI, server |
| `R/mod_*.R` | Shiny modules (one per tab) |
| `R/app_ui.R` | Full UI definition (~257 lines, bslib + Bootstrap 5) |
| `R/app_server.R` | Server entry point, reactive state, module wiring |
| `R/data_storage.R` | RDS persistence layer (CRUD for recipes, ingredients, shopping, prefs) |
| `R/ingredient_utils.R` | Ingredient line parsing, unit conversion, density lookups |
| `R/density_management.R` | Custom density CRUD (overrides built-in densities) |
| `R/matching_module.R` | Recipe-ingredient matching algorithm |
| `inst/app/www/` | Static assets: `custom.css` (29.9 KB), `favicon.ico` |
| `inst/golem-config.yml` | Golem configuration (dev/prod profiles) |
| `dev/` | Development scripts (run_dev, checks, test scripts) |
| `tests/testthat/` | Test directory (1 test file) |
| `vignettes/` | Vignette skeleton (`recipeR.Rmd`) |

## Development Commands

| Purpose | Command |
|---------|---------|
| Load package | `devtools::load_all()` |
| Run app (dev) | `golem::run_dev()` (uses `dev/run_dev.R`) |
| Run app (prod) | `options(golem.app.prod = TRUE); run_app()` |
| Run all tests | `devtools::test()` |
| Run single test | `devtools::test(filter = "parse_fraction")` |
| Lint R code | `lintr::lint_package()` |
| Format R code | `air format .` |
| Restore deps | `renv::restore()` |
| Snapshot deps | `renv::snapshot()` |
| Deploy to Connect | `rsconnect::deployApp()` (or blue button in app.R) |
| R CMD check | `devtools::check()` |

## Code Conventions & Common Patterns

### Golem module pattern
Every module has `mod_<name>_ui(id)` returning a `tagList` and `mod_<name>_server(id, rv, ...)`. Modules never use global variables; state lives in `rv` reactive values.

### UI
- `bslib` Bootstrap 5 with `page_sidebar()` layout
- Dark/light theme toggle via `color_mode` input
- Components: `card()`, `value_box()`, `layout_columns()`, `accordion()`, `DT::DTOutput()`
- Custom CSS in `inst/app/www/custom.css`
- Font: Inter (Google Fonts via bslib)

### Data persistence
- All data stored as RDS in `~/.recipeR/`
- `data_storage.R` exports: `get_recipes()`, `save_recipes()`, `get_ingredients()`, `save_ingredients()`, `get_shopping_list()`, `save_shopping_list()`, `get_prefs()`, `save_prefs()`
- Import/Export: `export_recipes_json()`, `export_recipes_csv()`, `import_recipes_json()`, `import_recipes_csv()`
- Backup/Restore: `create_backup()`, `restore_backup()`, `list_backups()`
- Error handling: `tryCatch` with graceful fallback to empty state

### Ingredient utilities (`ingredient_utils.R`)
  - `parse_fraction(s)` — parses "1 1/2", "1/2", "1.5", "2" to numeric
  - `parse_ingredient_line(line)` — extracts `$quantity`, `$unit`, `$name`, `$raw` from a line like "1 1/2 cups flour"
  - `unit_to_metric(amount, unit)` — convert to ml or g
  - `metric_to_preferred(amount, type, system)` — convert back to preferred unit system
  - `get_density(name)` — lookup built-in density (g/ml) for an ingredient
  - `parse_ingredients_raw(text)` — parse a multi-line ingredient list into structured rows
  - 40+ built-in densities for common ingredients (flours, sugars, fats, liquids, seasonings)
### Density management (`density_management.R`)
- Custom densities stored in `~/.recipeR/densities.rds`
- `add_custom_density()`, `delete_custom_density()`, `get_custom_densities()`
- `list_all_densities()` merges built-in + custom
- Custom densities take priority over built-in

### Matching (`matching_module.R`)
- Computes match percentage between recipe ingredients and available inventory
- Used in browse tab for filtering/sorting recipes by ingredient availability

### Naming
- `snake_case` for functions and variables
- `mod_<name>_*` for module functions
- `rv` for the central reactiveValues object
- `refresh_data` for the reload-callback pattern

### Error handling
- `tryCatch` around file I/O with warnings and fallback to empty state
- Defensive `is.null` checks on parsed user input
- `NA_real_` / `NA_character_` for missing parsed values

### Git branch naming
`<type>/<short-description>` — e.g. `feat/add-nutrition-tab`, `fix/parsing-empty-lines`

### Commit types
`feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`

## Important Files

| File | Purpose |
|------|---------|
| `app.R` | Entry point for deployment (uses `pkgload::load_all()` + `run_app()`) |
| `R/run_app.R` | Exported golem entry: registers www path, calls `shinyApp()` |
| `R/app_ui.R` | Full UI with bslib themes, sidebar, tab navigation |
| `R/app_server.R` | Server logic, reactiveValues init, module wiring, theme toggle |
| `R/data_storage.R` | All file I/O: recipes, ingredients, shopping, prefs, import/export, backup |
| `R/ingredient_utils.R` | Parsing, conversion, density lookup logic |
| `R/density_management.R` | Custom density CRUD |
| `R/matching_module.R` | Ingredient matching algorithm |
| `inst/golem-config.yml` | Golem configuration (dev vs production) |
| `inst/app/www/custom.css` | App styling |
| `DESCRIPTION` | Package metadata, dependencies |
| `manifest.json` | Posit Connect deployment manifest |
| `renv.lock` | Reproducible dependency lockfile |
| `air.toml` | R formatter config (line width 80) |

## Runtime/Tooling Preferences

- **R** >= 4.1.0, R 4.5.2 used at deploy time (per manifest.json)
- **renv** for dependency management — never use `install.packages()` directly
- **air** for R formatting (config: `air.toml` with line-width = 80)
- **golem** framework conventions throughout
- **bslib** Bootstrap 5 for UI (no shinythemes, no fluidPage)

## Testing & QA

- **Framework**: testthat (3rd edition, per renv.lock)
- **Test location**: `tests/testthat/`
  - **Files**: `test_ingredient_utils.R` (10 tests across 4 contexts)
- **Coverage**: fraction parsing, ingredient line parsing, unit conversion (round-trip American/metric), density-based volume-to-mass conversion
- **Dev test scripts**: `dev/test_density_admin.R`, `dev/test_density_feature_complete.R` (manual/QE-style)
- **Run**: `devtools::test()` or `devtools::test(filter = "pattern")`
**CI**: GitHub Actions (`.github/workflows/ci.yml`) runs `devtools::test()`, `air --check .`, and `lintr::lint_dir("R")` on push/PR to `main`/`develop`.
**Local pre-commit** (workspace convention): `air-format` + `jarl-check` (R); the `devtools::test()` gate runs in CI.
