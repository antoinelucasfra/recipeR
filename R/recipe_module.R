# Recipe Module - Core recipe management operations
# Encapsulates recipe CRUD, search, and manipulation logic

## Create a new recipe with validation
create_recipe <- function(title, source = "", source_url = NULL, ingredients = list(), instructions = list()) {
  if (is.null(title) || trimws(title) == "") {
    stop("Recipe title is required")
  }

  recipe <- list(
    title = trimws(title),
    source = trimws(source),
    source_url = source_url,
    ingredients = ingredients,
    instructions = instructions,
    date_added = Sys.time(),
    last_modified = Sys.time()
  )

  # Persist to database
  add_recipe(recipe)
}

## Get recipe by ID
get_recipe_by_id <- function(recipe_id) {
  recipes <- get_recipes()
  if (recipe_id %in% names(recipes)) {
    return(recipes[[recipe_id]])
  }
  NULL
}

## Search recipes by title or source
search_recipes <- function(query = "", source_filter = NULL) {
  recipes <- get_recipes()
  if (length(recipes) == 0) return(list())

  results <- list()
  query_lower <- tolower(trimws(query))

  for (id in names(recipes)) {
    recipe <- recipes[[id]]

    # Title or source match
    title_match <- if (query_lower != "") grepl(query_lower, tolower(recipe$title)) else TRUE
    source_match <- if (!is.null(source_filter)) recipe$source == source_filter else TRUE

    if (title_match && source_match) {
      results[[id]] <- recipe
    }
  }

  results
}

## Get all unique cuisines/sources
get_cuisines <- function() {
  recipes <- get_recipes()
  if (length(recipes) == 0) return(character())

  unique(sapply(recipes, function(r) if (!is.null(r$source)) r$source else "Unknown"))
}

## Get recipe statistics
get_recipe_stats <- function() {
  recipes <- get_recipes()

  list(
    total_recipes = length(recipes),
    total_cuisines = length(get_cuisines()),
    avg_ingredients = if (length(recipes) > 0) mean(sapply(recipes, function(r) length(r$ingredients))) else 0,
    avg_steps = if (length(recipes) > 0) mean(sapply(recipes, function(r) length(r$instructions))) else 0
  )
}

## Sort recipes by criteria
sort_recipes <- function(recipes = NULL, by = "title", decreasing = FALSE) {
  if (is.null(recipes)) {
    recipes <- get_recipes()
  }

  if (length(recipes) == 0) return(list())

  sorted_names <- switch(by,
    "title" = names(sort(sapply(recipes, function(r) r$title), decreasing = decreasing)),
    "date_added" = names(sort(sapply(recipes, function(r) r$date_added), decreasing = decreasing)),
    "source" = names(sort(sapply(recipes, function(r) r$source), decreasing = decreasing)),
    names(recipes)
  )

  recipes[sorted_names]
}

## Get recipe summary for display (title + cuisine + ingredient count)
get_recipe_summary <- function(recipe) {
  list(
    title = recipe$title,
    cuisine = recipe$source,
    ingredient_count = length(recipe$ingredients),
    step_count = length(recipe$instructions),
    date_added = recipe$date_added
  )
}

## Filter recipes by ingredient count
filter_by_complexity <- function(min_ingredients = 1, max_ingredients = Inf) {
  recipes <- get_recipes()
  if (length(recipes) == 0) return(list())

  Filter(function(r) {
    count <- length(r$ingredients)
    count >= min_ingredients && count <= max_ingredients
  }, recipes)
}
