## Simple data storage utilities for recipeR (RDS in user home)

data_file <- function() {
  dir <- file.path(path.expand("~"), ".recipeR")
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  file.path(dir, "recipes.rds")
}

shopping_file <- function() {
  dir <- file.path(path.expand("~"), ".recipeR")
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  file.path(dir, "shopping.rds")
}

load_db <- function() {
  f <- data_file()
  if (!file.exists(f)) return(list(recipes = list(), ingredients = list()))
  readRDS(f)
}

save_db <- function(db) {
  f <- data_file()
  saveRDS(db, f)
  invisible(TRUE)
}

get_shopping_list <- function() {
  f <- shopping_file()
  if (!file.exists(f)) return(character())
  readRDS(f)
}

save_shopping_list <- function(items) {
  f <- shopping_file()
  saveRDS(as.character(items), f)
  invisible(TRUE)
}

add_recipe <- function(recipe) {
  db <- load_db()
  if (is.null(db$recipes)) db$recipes <- list()
  if (is.null(recipe$recipe_id)) {
    recipe$recipe_id <- paste0(format(Sys.time(), "%Y%m%d%H%M%S"), sample(1000:9999, 1))
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
  if (is.null(db$recipes)) db$recipes <- list()
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
  if (is.null(db$ingredients)) db$ingredients <- list()
  id <- if (!is.null(ing$ingredient_name)) gsub("\\s+", "_", tolower(ing$ingredient_name)) else paste0("ing_", sample(10000, 1))
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
  if (is.null(db$ingredients)) db$ingredients <- list()
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
