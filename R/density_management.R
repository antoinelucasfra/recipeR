## Density management storage and utilities

densities_file <- function() {
  dir <- file.path(path.expand("~"), ".recipeR")
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  file.path(dir, "densities.rds")
}

get_custom_densities <- function() {
  f <- densities_file()
  if (!file.exists(f)) return(list())
  readRDS(f)
}

save_custom_densities <- function(densities) {
  f <- densities_file()
  saveRDS(densities, f)
  invisible(TRUE)
}

add_custom_density <- function(ingredient_name, density_value) {
  densities <- get_custom_densities()
  name_key <- tolower(gsub("\\s+", "_", trimws(ingredient_name)))
  densities[[name_key]] <- as.numeric(density_value)
  save_custom_densities(densities)
  invisible(TRUE)
}

delete_custom_density <- function(ingredient_name) {
  densities <- get_custom_densities()
  name_key <- tolower(gsub("\\s+", "_", trimws(ingredient_name)))
  densities[[name_key]] <- NULL
  save_custom_densities(densities)
  invisible(TRUE)
}

list_all_densities <- function() {
  # Combine built-in and custom densities
  builtin <- density_table()
  custom <- get_custom_densities()
  combined <- c(builtin, custom)
  # return as data frame
  data.frame(
    ingredient = names(combined),
    density = unlist(combined),
    source = c(rep("builtin", length(builtin)), rep("custom", length(custom))),
    stringsAsFactors = FALSE
  )
}
