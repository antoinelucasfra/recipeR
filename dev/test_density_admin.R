# Test script for density admin UI integration
# This demonstrates the density management workflow

devtools::load_all()

cat("===== DENSITY ADMIN UI INTEGRATION TEST =====\n\n")

# Clean up any existing custom densities
custom_densities_file <- densities_file()
if (file.exists(custom_densities_file)) {
  file.remove(custom_densities_file)
  cat("✓ Cleaned up existing custom densities\n\n")
}

# Test 1: List all densities
cat("TEST 1: Initial density table (built-in only)\n")
all_dens <- list_all_densities()
cat(sprintf("  Total built-in densities: %d\n", nrow(all_dens)))
cat(sprintf("  Sample: %s\n", paste(head(all_dens$ingredient, 3), collapse=", ")))
print(head(all_dens, 3))
cat("\n")

# Test 2: Add custom density
cat("TEST 2: Add custom density via add_custom_density()\n")
add_custom_density("matcha", 0.72)
add_custom_density("coconut_flour", 0.85)
cat("  Added: matcha = 0.72 g/ml\n")
cat("  Added: coconut_flour = 0.85 g/ml\n\n")

# Test 3: Verify custom densities persisted
cat("TEST 3: List all densities (with custom)\n")
all_dens <- list_all_densities()
cat(sprintf("  Total densities: %d\n", nrow(all_dens)))
custom_rows <- all_dens[all_dens$source == "custom", ]
cat(sprintf("  Custom densities added: %d\n", nrow(custom_rows)))
print(custom_rows)
cat("\n")

# Test 4: Verify custom densities work with get_density()
cat("TEST 4: Verify custom density is usable in conversions\n")
dens_matcha <- get_density("matcha")
cat(sprintf("  get_density('matcha') = %f\n", dens_matcha))
cat(sprintf("  Expected: 0.72, Match: %s\n", ifelse(abs(dens_matcha - 0.72) < 0.001, "✓", "✗")))
cat("\n")

# Test 5: Test density-based conversion with custom ingredient
cat("TEST 5: Test volume-to-mass conversion with custom ingredient\n")
ml_volume <- 240
mass_g <- volume_ml_to_mass_g(ml_volume, "matcha")
cat(sprintf("  %d ml of matcha = %.1f g\n", ml_volume, mass_g))
cat(sprintf("  Expected: ~173g (240 × 0.72), Got: %.1f\n", mass_g))
cat("\n")

# Test 6: Simulate Shiny handler input (validate inputs)
cat("TEST 6: Simulate handler validation\n")
test_cases <- list(
  list(name = "", value = 1.0, valid = FALSE, reason = "empty name"),
  list(name = "sugar", value = NA, valid = FALSE, reason = "NA value"),
  list(name = "sugar", value = -0.5, valid = FALSE, reason = "negative value"),
  list(name = "sugar", value = 0, valid = FALSE, reason = "zero value"),
  list(name = "custom_spice", value = 1.5, valid = TRUE, reason = "valid")
)

for (i in seq_along(test_cases)) {
  tc <- test_cases[[i]]
  is_valid <- !(is.null(tc$name) || tc$name == "") && !(is.null(tc$value) || is.na(tc$value) || tc$value <= 0)
  match <- is_valid == tc$valid
  status <- if (match) "✓" else "✗"
  cat(sprintf("  %s Case %d (%s): %s\n", status, i, tc$reason, if (match) "PASS" else "FAIL"))
}
cat("\n")

cat("===== ALL TESTS COMPLETED =====\n")
