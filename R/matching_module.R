# Matching Module - Recipe-ingredient matching and recommendations
# Sophisticated matching algorithm for finding suitable recipes

## Calculate match percentage between recipe and inventory
calculate_match <- function(recipe, inventory) {
  if (is.null(recipe$ingredients) || length(recipe$ingredients) == 0) {
    return(0)
  }

  inv_names <- tolower(sapply(inventory, function(x) {
    if (!is.null(x$ingredient_name)) trimws(x$ingredient_name) else ""
  }))

  req_names <- tolower(sapply(recipe$ingredients, function(i) {
    if (!is.null(i$ingredient_name)) trimws(i$ingredient_name) else ""
  }))

  matched <- sum(sapply(req_names, function(r) {
    any(grepl(r, inv_names, fixed = TRUE))
  }))

  round(100 * matched / length(req_names))
}

## Get missing ingredients for a recipe
get_missing_ingredients <- function(recipe, inventory) {
  if (is.null(recipe$ingredients) || length(recipe$ingredients) == 0) {
    return(character())
  }

  inv_names <- tolower(sapply(inventory, function(x) {
    if (!is.null(x$ingredient_name)) trimws(x$ingredient_name) else ""
  }))

  req_names <- sapply(recipe$ingredients, function(i) {
    if (!is.null(i$ingredient_name)) i$ingredient_name else ""
  })

  missing <- req_names[!sapply(tolower(req_names), function(rr) {
    any(grepl(tolower(rr), inv_names, fixed = TRUE))
  })]

  unique(missing)
}

## Rank recipes by match percentage
rank_recipes_by_match <- function(inventory = NULL, min_match = 0) {
  if (is.null(inventory)) {
    inventory <- get_ingredients()
  }

  recipes <- get_recipes()
  if (length(recipes) == 0) return(list())

  # Calculate match for each recipe
  matches <- lapply(recipes, function(r) {
    list(
      recipe = r,
      match_percent = calculate_match(r, inventory),
      missing_count = length(get_missing_ingredients(r, inventory))
    )
  })

  # Filter by minimum match threshold
  matches <- Filter(function(m) m$match_percent >= min_match, matches)

  # Sort by match percentage (descending) and missing count (ascending)
  matches <- matches[order(
    sapply(matches, function(m) m$match_percent),
    sapply(matches, function(m) m$missing_count),
    decreasing = c(TRUE, FALSE)
  )]

  matches
}

## Get top N recommended recipes
get_recommended_recipes <- function(inventory = NULL, top_n = 5, min_match = 0) {
  ranked <- rank_recipes_by_match(inventory, min_match)

  if (length(ranked) == 0) return(list())

  top_n <- min(top_n, length(ranked))
  ranked[seq_len(top_n)]
}

## Get recipes that can be made with available ingredients
get_makeable_recipes <- function(inventory = NULL, min_match = 100) {
  rank_recipes_by_match(inventory, min_match)
}

## Analyze ingredient coverage across recipes
analyze_ingredient_coverage <- function(inventory = NULL) {
  if (is.null(inventory)) {
    inventory <- get_ingredients()
  }

  recipes <- get_recipes()
  if (length(recipes) == 0) return(NULL)

  inv_names <- tolower(sapply(inventory, function(x) {
    if (!is.null(x$ingredient_name)) trimws(x$ingredient_name) else ""
  }))

  all_required_ings <- c()
  all_available_ings <- tolower(sapply(inventory, function(x) x$ingredient_name))

  for (recipe in recipes) {
    for (ing in recipe$ingredients) {
      all_required_ings <- c(all_required_ings, tolower(ing$ingredient_name))
    }
  }

  all_required_ings <- unique(all_required_ings)
  covered <- sum(all_required_ings %in% inv_names)

  list(
    total_unique_ingredients = length(all_required_ings),
    covered_ingredients = covered,
    coverage_percent = round(100 * covered / length(all_required_ings)),
    gap_ingredients = setdiff(all_required_ings, inv_names)
  )
}

## Get cuisines ranked by match percentage
rank_cuisines_by_match <- function(inventory = NULL) {
  ranked <- rank_recipes_by_match(inventory)

  if (length(ranked) == 0) return(list())

  # Group by cuisine and calculate average match
  cuisines <- lapply(unique(sapply(ranked, function(m) m$recipe$source)), function(cuisine) {
    cuisine_recipes <- Filter(function(m) m$recipe$source == cuisine, ranked)
    avg_match <- mean(sapply(cuisine_recipes, function(m) m$match_percent))
    count <- length(cuisine_recipes)

    list(
      cuisine = cuisine,
      avg_match = round(avg_match),
      recipe_count = count
    )
  })

  # Sort by average match
  cuisines <- cuisines[order(sapply(cuisines, function(c) c$avg_match), decreasing = TRUE)]

  cuisines
}
