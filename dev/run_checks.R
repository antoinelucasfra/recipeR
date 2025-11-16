# Quick dev script to exercise core flows for recipeR
library(devtools)
load_all()

cat("Current data file:", data_file(), "\n")

# Create a sample recipe
rec <- list(
  title = "Test Pancakes",
  source = "manual",
  ingredients = list(
    list(ingredient_name = "flour", raw_text = "2 cups flour"),
    list(ingredient_name = "milk", raw_text = "1.5 cups milk"),
    list(ingredient_name = "egg", raw_text = "1 egg")
  ),
  instructions = list(list(step_number = 1, instruction_text = "Mix"), list(step_number = 2, instruction_text = "Cook")),
  date_added = Sys.time(),
  last_modified = Sys.time()
)

add_recipe(rec)

# Add inventory
add_ingredient(list(ingredient_name = "flour", quantity_available = 5, unit = "cups"))
add_ingredient(list(ingredient_name = "milk", quantity_available = 2, unit = "cups"))

# Show recipes and ingredients
print(str(get_recipes()))
print(str(get_ingredients()))

# Compute match for the sample recipe
recs <- get_recipes()
if (length(recs) > 0) {
  r <- recs[[1]]
  # simple match calculation here for sanity
  inv <- get_ingredients()
  inv_names <- tolower(sapply(inv, function(x) x$ingredient_name))
  req_names <- tolower(sapply(r$ingredients, function(i) i$ingredient_name))
  matched <- sum(sapply(req_names, function(rr) any(grepl(rr, inv_names, fixed = TRUE))))
  pct <- round(100 * matched / length(req_names))
  cat(sprintf("Match for '%s': %s%%\n", r$title, pct))
}

# Clear up
cat("Done. Shopping file:", shopping_file(), "\n")
print(get_shopping_list())
