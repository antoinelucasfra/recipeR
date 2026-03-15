## Simple data storage utilities for recipeR (RDS in user home)

data_file <- function() {
  dir <- file.path(path.expand("~"), ".recipeR")
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  }
  file.path(dir, "recipes.rds")
}

shopping_file <- function() {
  dir <- file.path(path.expand("~"), ".recipeR")
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  }
  file.path(dir, "shopping.rds")
}

load_db <- function() {
  f <- data_file()
  if (!file.exists(f)) {
    return(list(recipes = list(), ingredients = list()))
  }
  tryCatch(
    readRDS(f),
    error = function(e) {
      warning(
        "recipeR: could not read data file (",
        conditionMessage(e),
        "). Starting with empty database."
      )
      list(recipes = list(), ingredients = list())
    }
  )
}

save_db <- function(db) {
  f <- data_file()
  saveRDS(db, f)
  invisible(TRUE)
}

get_shopping_list <- function() {
  f <- shopping_file()
  if (!file.exists(f)) {
    return(list())
  }
  raw <- tryCatch(readRDS(f), error = function(e) list())
  # Migrate old character-vector format to list-of-items format
  if (is.character(raw)) {
    return(lapply(raw, function(x) list(text = x, checked = FALSE)))
  }
  raw
}

save_shopping_list <- function(items) {
  f <- shopping_file()
  # Accept legacy character vector; normalise to list format before saving
  if (is.character(items)) {
    items <- lapply(items, function(x) list(text = x, checked = FALSE))
  }
  saveRDS(items, f)
  invisible(TRUE)
}

## Import/Export/Backup utilities
export_recipes_json <- function(path) {
  recs <- get_recipes()
  out <- list(
    version = "1.0",
    export_date = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ"),
    recipe_count = length(recs),
    recipes = unname(recs)
  )
  jsonlite::write_json(out, path, auto_unbox = TRUE, pretty = TRUE)
  invisible(TRUE)
}

export_recipes_csv <- function(path) {
  recs <- get_recipes()
  # Flatten to simple rows: recipe_id, title, ingredient_raw, instruction_text
  rows <- do.call(
    rbind,
    lapply(recs, function(r) {
      ing_lines <- sapply(r$ingredients, function(i) i$raw_text)
      inst_lines <- sapply(r$instructions, function(s) s$instruction_text)
      data.frame(
        recipe_id = r$recipe_id,
        title = r$title,
        ingredients = paste(ing_lines, collapse = " | "),
        instructions = paste(inst_lines, collapse = " | "),
        stringsAsFactors = FALSE
      )
    })
  )
  utils::write.csv(rows, path, row.names = FALSE)
  invisible(TRUE)
}

import_recipes_json <- function(path, overwrite = FALSE) {
  obj <- jsonlite::read_json(path, simplifyVector = TRUE)
  if (is.null(obj$recipes)) {
    stop("Invalid import format: 'recipes' missing")
  }
  # Load DB once outside the loop to avoid O(n) disk reads
  db <- load_db()
  for (r in obj$recipes) {
    dup <- NULL
    if (!is.null(r$recipe_id) && !is.null(db$recipes[[r$recipe_id]])) {
      dup <- r$recipe_id
    }
    if (!is.null(dup) && !overwrite) {
      next
    }
    add_recipe(r)
    # Refresh snapshot so next iteration sees already-written recipes
    db <- load_db()
  }
  invisible(TRUE)
}

import_recipes_csv <- function(path) {
  df <- utils::read.csv(path, stringsAsFactors = FALSE)
  for (i in seq_len(nrow(df))) {
    row <- df[i, ]
    ing_lines <- if (!is.null(row$ingredients)) {
      strsplit(row$ingredients, " | ", fixed = TRUE)[[1]]
    } else {
      character()
    }
    inst_lines <- if (!is.null(row$instructions)) {
      strsplit(row$instructions, " | ", fixed = TRUE)[[1]]
    } else {
      character()
    }
    recipe <- list(
      title = row$title,
      source = "imported",
      source_url = NA,
      ingredients = lapply(ing_lines, function(x) {
        list(raw_text = x, ingredient_name = x)
      }),
      instructions = lapply(seq_along(inst_lines), function(j) {
        list(step_number = j, instruction_text = inst_lines[j])
      }),
      date_added = Sys.time(),
      last_modified = Sys.time()
    )
    add_recipe(recipe)
  }
  invisible(TRUE)
}

backup_db <- function() {
  dir <- file.path(path.expand("~"), ".recipeR", "backups")
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  }
  src <- data_file()
  if (!file.exists(src)) {
    stop("No DB to backup")
  }
  dest <- file.path(
    dir,
    paste0("recipes_backup_", format(Sys.time(), "%Y%m%d%H%M%S"), ".rds")
  )
  file.copy(src, dest)
  dest
}

list_backups <- function() {
  dir <- file.path(path.expand("~"), ".recipeR", "backups")
  if (!dir.exists(dir)) {
    return(character())
  }
  list.files(dir, full.names = TRUE)
}

restore_backup <- function(path) {
  if (!file.exists(path)) {
    stop("Backup not found")
  }
  file.copy(path, data_file(), overwrite = TRUE)
  invisible(TRUE)
}

## Preferences
prefs_file <- function() {
  dir <- file.path(path.expand("~"), ".recipeR")
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  }
  file.path(dir, "prefs.rds")
}

get_prefs <- function() {
  f <- prefs_file()
  if (!file.exists(f)) {
    return(list(unit_system = "american"))
  }
  readRDS(f)
}

save_prefs <- function(prefs) {
  f <- prefs_file()
  saveRDS(prefs, f)
  invisible(TRUE)
}

add_recipe <- function(recipe) {
  db <- load_db()
  if (is.null(db$recipes)) {
    db$recipes <- list()
  }
  if (is.null(recipe$recipe_id)) {
    recipe$recipe_id <- paste0(
      format(Sys.time(), "%Y%m%d%H%M%S"),
      sample(1000:9999, 1)
    )
  }
  recipe$date_added <- Sys.time()
  recipe$last_modified <- Sys.time()
  db$recipes[[recipe$recipe_id]] <- recipe
  save_db(db)
  recipe
}

get_recipes <- function() {
  db <- load_db()
  if (is.null(db$recipes)) list() else db$recipes
}

update_recipe <- function(recipe_id, recipe) {
  db <- load_db()
  if (is.null(db$recipes)) {
    db$recipes <- list()
  }
  recipe$last_modified <- Sys.time()
  db$recipes[[recipe_id]] <- recipe
  save_db(db)
  recipe
}

delete_recipe <- function(recipe_id) {
  db <- load_db()
  if (!is.null(db$recipes) && !is.null(db$recipes[[recipe_id]])) {
    db$recipes[[recipe_id]] <- NULL
    save_db(db)
    return(TRUE)
  }
  FALSE
}

# Ingredient inventory helpers
add_ingredient <- function(ing) {
  db <- load_db()
  if (is.null(db$ingredients)) {
    db$ingredients <- list()
  }
  id <- if (!is.null(ing$ingredient_name)) {
    gsub("\\s+", "_", tolower(ing$ingredient_name))
  } else {
    paste0("ing_", sample(10000, 1))
  }
  ing$id <- id
  db$ingredients[[id]] <- ing
  save_db(db)
  ing
}

get_ingredients <- function() {
  db <- load_db()
  if (is.null(db$ingredients)) list() else db$ingredients
}

update_ingredient <- function(id, ing) {
  db <- load_db()
  if (is.null(db$ingredients)) {
    db$ingredients <- list()
  }
  ing$id <- id
  db$ingredients[[id]] <- ing
  save_db(db)
  ing
}

delete_ingredient <- function(id) {
  db <- load_db()
  if (!is.null(db$ingredients) && !is.null(db$ingredients[[id]])) {
    db$ingredients[[id]] <- NULL
    save_db(db)
    return(TRUE)
  }
  FALSE
}
