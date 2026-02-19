# GitHub Copilot Instructions — recipeR

This file governs all Copilot suggestions in the `recipeR` repository.
All rules in `~/project/AGENTS.md` also apply. This file documents project-specific directives.

---

## Identity

- Git email: `antoine.lucas.fra@gmail.com`
- Always sign commits with GPG key `79C78C5311C38AB06EF3804FAC8647A90C69EBC0`
- Never pass `--no-gpg-sign` or `--no-verify`

---

## Stack

- golem + Shiny, R 4.5.2 managed by `rig`
- `renv` for packages — never `install.packages()`, always `renv::install()` + `renv::snapshot()`
- `air` for formatting — never `styler`
- No CI — run `devtools::test()` manually before every deploy
- Data: file-based RDS at `~/.recipeR/` — this is NOT a database
- Deploy: `rsconnect::deployApp()` to `connect.posit.cloud`, account `antoinelucasfra`

---

## Data Persistence

- All persistence goes through functions in `R/data_storage.R` — never access `~/.recipeR/` directly
- Files: `~/.recipeR/recipes.rds`, `~/.recipeR/shopping.rds`, `~/.recipeR/prefs.rds`, `~/.recipeR/backups/`
- Use `add_recipe()`, `get_recipes()`, `update_recipe()`, `delete_recipe()` for recipe CRUD
- Use `get_shopping_list()`, `save_shopping_list()` for shopping list
- Use `get_prefs()`, `save_prefs()` for user preferences
- Use `backup_db()` before any migration or destructive operation

---

## Golem Architecture

- `R/_disable_autoload.R` — never delete this file; the app will break without it
- New modules: always `golem::add_module("name")` — never create `mod_*.R` manually
- Each `mod_*.R` contains exactly one `_ui()` and one `_server()` function pair
- `utils_*.R` and pure-logic files contain only pure functions — no `reactive()`, `observe()`
- `app_ui.R` and `app_server.R` are thin wires — delegate logic to modules
- Never edit `NAMESPACE` by hand — regenerate with `devtools::document()`
- All functions must have roxygen2 docs (`#' @param`, `#' @return`, `#' @export`)
- Use explicit namespacing: `jsonlite::write_json()` not bare `write_json()`

---

## Key Functions (do not break their signatures)

- `parse_fraction(str)` → numeric (e.g. `"1 1/2"` → `1.5`)
- `parse_ingredient_line(line)` → `list(quantity, unit, name)`
- `unit_to_metric(amount, unit)` → `list(amount, unit)`
- `metric_to_preferred(amount, type, system)` → `list(amount, unit)` where `system` is `"american"` or `"metric"`
- `get_density(ingredient_name)` → numeric or `NA`
- `volume_ml_to_mass_g(volume_ml, ingredient)` → numeric (grams)

---

## Testing

- Always run `devtools::test()` before deploying — all 4 tests must pass
- Test file: `tests/testthat/test_ingredient_utils.R`
- Test file uses `source('../../R/ingredient_utils.R')` directly — do not move files without updating this path
- Never remove or weaken existing test assertions

---

## Deployment

- Pre-deploy: `devtools::test()` → `air format .` → `renv::snapshot()` → `recipeR::run_app()` locally
- Deploy command (from `dev/03_deploy.R`):

```r
rsconnect::deployApp(
  appName = desc::desc_get_field("Package"),
  appTitle = desc::desc_get_field("Package"),
  appFiles = c("R/", "inst/", "data/", "NAMESPACE", "DESCRIPTION", "app.R"),
  appId = rsconnect::deployments(".")$appID,
  lint = FALSE,
  forceUpdate = TRUE
)
```

- Never include `renv/library/`, `.env`, or `~/.recipeR/` in `appFiles`
- Never hardcode account name or server URL — configure via rsconnect account settings

---

## Git Conventions

- No CI — always run checks manually before pushing
- Commit types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `ci`, `chore`, `deploy`, `perf`, `revert`
- Scope examples: `feat(recipe): ...`, `fix(units): ...`, `refactor(storage): ...`
- Subject: imperative mood, ≤72 chars, no trailing period
- Never push directly to `main`
- Never `git push --force` on `main`
- Never `git add .` without reviewing `git status` and `git diff --staged`
- Never commit `~/.recipeR/`, `*.Rproj`, `.Rhistory`, `.DS_Store`, `renv/library/`

---

## Hard Rules

- Never delete `R/_disable_autoload.R`
- Never access `~/.recipeR/` directly — always use `R/data_storage.R` functions
- Never use `install.packages()` — always `renv::install()` + `renv::snapshot()`
- Never use `styler` — always `air`
- Never deploy without running `devtools::test()` first
- Never add secrets or credentials to source files
