# Ingredient Module - Core ingredient inventory management
# Encapsulates ingredient CRUD and inventory operations

## Create or update ingredient in inventory
upsert_ingredient <- function(name, quantity = 0, unit = "", category = NA, is_staple = FALSE) {
  if (is.null(name) || trimws(name) == "") {
    stop("Ingredient name is required")
  }

  ing <- list(
    ingredient_name = trimws(name),
    quantity_available = as.numeric(quantity),
    unit = trimws(unit),
    category = category,
    is_staple = is_staple
  )

  add_ingredient(ing)
  invisible(ing)
}

## Get ingredient by name (case-insensitive)
get_ingredient_by_name <- function(name) {
  ings <- get_ingredients()
  name_lower <- tolower(trimws(name))

  for (ing in ings) {
    if (tolower(ing$ingredient_name) == name_lower) {
      return(ing)
    }
  }
  NULL
}

## Check if ingredient exists in inventory
has_ingredient <- function(name) {
  !is.null(get_ingredient_by_name(name))
}

## Get all ingredients sorted by category
get_ingredients_by_category <- function() {
  ings <- get_ingredients()
  if (length(ings) == 0) return(list())

  # Group by category
  categories <- lapply(unique(sapply(ings, function(i) i$category %||% "Uncategorized")), function(cat) {
    Filter(function(i) (i$category %||% "Uncategorized") == cat, ings)
  })

  categories
}

## Get staple ingredients
get_staple_ingredients <- function() {
  ings <- get_ingredients()
  Filter(function(i) isTRUE(i$is_staple), ings)
}

## Get non-staple ingredients (items to shop for)
get_shopping_ingredients <- function() {
  ings <- get_ingredients()
  Filter(function(i) !isTRUE(i$is_staple), ings)
}

## Update ingredient quantity
update_ingredient_quantity <- function(name, new_quantity) {
  ing <- get_ingredient_by_name(name)
  if (is.null(ing)) {
    stop(sprintf("Ingredient '%s' not found", name))
  }

  ing$quantity_available <- as.numeric(new_quantity)
  add_ingredient(ing)
  invisible(ing)
}

## Bulk import ingredients from data frame
import_ingredients_bulk <- function(ingredients_df) {
  if (!is.data.frame(ingredients_df)) {
    stop("Input must be a data frame")
  }

  required_cols <- c("name", "quantity")
  if (!all(required_cols %in% names(ingredients_df))) {
    stop(sprintf("Data frame must contain columns: %s", paste(required_cols, collapse = ", ")))
  }

  count <- 0
  for (i in seq_len(nrow(ingredients_df))) {
    row <- ingredients_df[i, ]
    upsert_ingredient(
      name = row$name,
      quantity = row$quantity,
      unit = if ("unit" %in% names(row)) row$unit else "",
      category = if ("category" %in% names(row)) row$category else NA,
      is_staple = if ("is_staple" %in% names(row)) row$is_staple else FALSE
    )
    count <- count + 1
  }

  count
}

## Get inventory statistics
get_inventory_stats <- function() {
  ings <- get_ingredients()

  list(
    total_items = length(ings),
    staple_count = length(get_staple_ingredients()),
    shopping_count = length(get_shopping_ingredients()),
    avg_quantity = if (length(ings) > 0) mean(sapply(ings, function(i) i$quantity_available)) else 0
  )
}
