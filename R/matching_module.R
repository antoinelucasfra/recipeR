# Matching Module - Recipe-ingredient matching and recommendations
# Sophisticated matching algorithm for finding suitable recipes

## Recipe-ingredient matching and recommendations
inventory_names <- function(inventory) {
  tolower(sapply(inventory, function(x) {
    if (!is.null(x$ingredient_name)) trimws(x$ingredient_name) else ""
  }))
}

ingredient_matches <- function(inv_names, req_name) {
  r <- tolower(trimws(req_name))
  any(grepl(r, inv_names, fixed = TRUE))
}

calculate_match <- function(recipe, inventory) {
  if (is.null(recipe$ingredients) || length(recipe$ingredients) == 0) {
    return(0)
  }
  inv_names <- inventory_names(inventory)
  req_names <- tolower(sapply(recipe$ingredients, function(i) {
    if (!is.null(i$ingredient_name)) trimws(i$ingredient_name) else ""
  }))
  matched <- sum(vapply(
    req_names,
    function(r) ingredient_matches(inv_names, r),
    logical(1)
  ))
  round(100 * matched / length(req_names))
}

## Get missing ingredients for a recipe
get_missing_ingredients <- function(recipe, inventory) {
  if (is.null(recipe$ingredients) || length(recipe$ingredients) == 0) {
    return(character())
  }
  inv_names <- inventory_names(inventory)
  req_names <- sapply(recipe$ingredients, function(i) {
    if (!is.null(i$ingredient_name)) i$ingredient_name else ""
  })
  missing <- req_names[
    !vapply(
      tolower(req_names),
      function(rr) ingredient_matches(inv_names, rr),
      logical(1)
    )
  ]
  unique(missing)
}
