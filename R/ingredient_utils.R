## Ingredient parsing and scaling utilities

parse_fraction <- function(s) {
  # Handle forms like "1 1/2", "1/2", "1.5"
  s <- gsub("\u00A0", " ", s) # non-breaking spaces
  s <- trimws(s)
  if (s == "" || is.na(s)) return(NA_real_)
  # mixed number e.g. '1 1/2'
  if (grepl("^\\d+\\s+\\d+\\/\\d+$", s)) {
    parts <- strsplit(s, "\\s+")[[1]]
    whole <- as.numeric(parts[1])
    frac <- parts[2]
    nums <- strsplit(frac, "/")[[1]]
    return(whole + as.numeric(nums[1]) / as.numeric(nums[2]))
  }
  # simple fraction '1/2'
  if (grepl("^\\d+\\/\\d+$", s)) {
    nums <- strsplit(s, "/")[[1]]
    return(as.numeric(nums[1]) / as.numeric(nums[2]))
  }
  # decimal
  if (grepl("^[0-9]+[.,]?[0-9]*$", s)) {
    return(as.numeric(gsub(",", ".", s)))
  }
  NA_real_
}

parse_ingredient_line <- function(line) {
  # Try to extract quantity, unit, and name from a line like '1 1/2 cups flour'
  if (is.null(line)) return(list(quantity = NA_real_, unit = NA_character_, name = "" , raw = ""))
  raw <- trimws(as.character(line))
  if (raw == "") return(list(quantity = NA_real_, unit = NA_character_, name = "" , raw = ""))
  tokens <- strsplit(raw, "\\s+")[[1]]
  qty_raw <- NULL
  unit <- NULL
  name <- NULL
  # detect mixed number: first token integer and second token fraction
  if (length(tokens) >= 2 && grepl('^\\d+$', tokens[1]) && grepl('^\\d+\\/\\d+$', tokens[2])) {
    qty_raw <- paste(tokens[1], tokens[2])
    tokens <- tokens[-c(1,2)]
  } else if (grepl('^\\d+\\/\\d+$', tokens[1]) || grepl('^[0-9]+(?:[\\.,][0-9]+)?$', tokens[1])) {
    qty_raw <- tokens[1]
    tokens <- tokens[-1]
  }
  # next token might be unit (letters or letters with dot)
  if (length(tokens) >= 1 && grepl('^[a-zA-Z\\.]+$', tokens[1])) {
    unit <- tokens[1]
    tokens <- tokens[-1]
  }
  name <- paste(tokens, collapse = " ")
  qty <- parse_fraction(qty_raw)
  if (is.na(name) || name == "") name <- raw
  if (!is.null(unit)) unit <- tolower(unit)
  list(quantity = ifelse(is.na(qty), NA_real_, qty), unit = ifelse(is.null(unit) || unit == "", NA_character_, unit), name = trimws(name), raw = raw)
}

scale_ingredient <- function(ing, multiplier) {
  # ing is a list with quantity (numeric), unit, name, raw
  out <- ing
  if (!is.null(ing$quantity) && !is.na(ing$quantity)) {
    out$quantity <- ing$quantity * multiplier
    # format quantity nicely
    out$quantity_display <- if (out$quantity %% 1 == 0) as.character(as.integer(out$quantity)) else format(round(out$quantity,2), trim = TRUE)
  } else {
    out$quantity_display <- NA_character_
  }
  out
}

## Unit system conversion utilities
# Canonical units: volume -> ml, mass -> g
unit_aliases <- function(u) {
  if (is.null(u)) return(NA_character_)
  s <- tolower(gsub("\\.$", "", trimws(u)))
  # common aliases
  map <- list(
    cup = c("cup", "cups", "c"),
    tbsp = c("tbsp", "tablespoon", "tablespoons", "tbsp."),
    tsp = c("tsp", "teaspoon", "teaspoons"),
    ml = c("ml", "milliliter", "milliliters", "mL"),
    l = c("l", "liter", "litre", "liters", "litres"),
    oz = c("oz", "ounce", "ounces"),
    lb = c("lb", "pound", "pounds", "lbs"),
    g = c("g", "gram", "grams"),
    kg = c("kg", "kilogram", "kilograms")
  )
  for (k in names(map)) if (s %in% map[[k]]) return(k)
  s
}

unit_to_metric <- function(qty, unit) {
  # return list(amount, type, unit) where unit is 'ml' or 'g'
  if (is.null(unit) || is.na(unit) || unit == "") return(list(amount = qty, type = "unknown", unit = NA_character_))
  u <- unit_aliases(unit)
  # volume conversions to ml (US cup standard)
  if (u == "cup") return(list(amount = as.numeric(qty) * 236.588, type = "volume", unit = "ml"))
  if (u == "tbsp") return(list(amount = as.numeric(qty) * 14.7868, type = "volume", unit = "ml"))
  if (u == "tsp") return(list(amount = as.numeric(qty) * 4.92892, type = "volume", unit = "ml"))
  if (u == "l") return(list(amount = as.numeric(qty) * 1000, type = "volume", unit = "ml"))
  if (u == "ml") return(list(amount = as.numeric(qty), type = "volume", unit = "ml"))
  # mass conversions to grams
  if (u == "oz") return(list(amount = as.numeric(qty) * 28.3495, type = "mass", unit = "g"))
  if (u == "lb") return(list(amount = as.numeric(qty) * 453.592, type = "mass", unit = "g"))
  if (u == "kg") return(list(amount = as.numeric(qty) * 1000, type = "mass", unit = "g"))
  if (u == "g") return(list(amount = as.numeric(qty), type = "mass", unit = "g"))
  # unknown: return original
  list(amount = qty, type = "unknown", unit = u)
}

metric_to_preferred <- function(amount, type = c("volume", "mass"), system = c("american", "european")) {
  type <- match.arg(type)
  system <- match.arg(system)
  if (type == "volume") {
    if (system == "american") {
      # prefer cups if >= 120 ml (~0.5 cup), else tbsp/tsp
      if (amount >= 120) return(list(quantity = round(amount / 236.588, 2), unit = "cup"))
      if (amount >= 15) return(list(quantity = round(amount / 14.7868, 2), unit = "tbsp"))
      return(list(quantity = round(amount / 4.92892, 2), unit = "tsp"))
    } else {
      # european metric -> ml or l
      if (amount >= 1000) return(list(quantity = round(amount / 1000, 2), unit = "l"))
      return(list(quantity = round(amount, 1), unit = "ml"))
    }
  }
  if (type == "mass") {
    if (system == "american") {
      # prefer lb if >= 453.592g
      if (amount >= 453.592) return(list(quantity = round(amount / 453.592, 2), unit = "lb"))
      return(list(quantity = round(amount / 28.3495, 1), unit = "oz"))
    } else {
      if (amount >= 1000) return(list(quantity = round(amount / 1000, 2), unit = "kg"))
      return(list(quantity = round(amount, 0), unit = "g"))
    }
  }
  list(quantity = NA_real_, unit = NA_character_)
}

convert_to_system <- function(qty, unit, system = c("american", "european")) {
  system <- match.arg(system)
  # if qty missing, return raw
  if (is.null(qty) || is.na(qty) || is.null(unit) || is.na(unit)) return(list(quantity = qty, unit = unit, display = NA_character_))
  m <- unit_to_metric(qty, unit)
  if (m$type %in% c("volume", "mass")) {
    pref <- metric_to_preferred(m$amount, m$type, system)
    display <- paste0(pref$quantity, " ", pref$unit)
    return(list(quantity = pref$quantity, unit = pref$unit, display = display))
  }
  list(quantity = qty, unit = unit, display = paste0(qty, " ", unit))
}

## Density-based conversions
# Densities are grams per milliliter (g/ml)
density_table <- function() {
  list(
    # Flours & grains
    flour = 0.5289,            # 125 g per cup
    whole_wheat_flour = 0.55,  # approx 130g per cup
    almond_flour = 0.95,
    cornmeal = 0.65,
    rice = 0.8,
    oats = 0.55,
    # Sugars & sweeteners
    sugar = 0.845,             # 200 g per cup
    brown_sugar = 0.88,
    powdered_sugar = 0.6,
    honey = 1.42,
    maple_syrup = 1.38,
    agave_syrup = 1.35,
    # Fats & oils
    butter = 0.959,            # 227 g per cup
    coconut_oil = 0.92,
    vegetable_oil = 0.92,
    olive_oil = 0.92,
    shortening = 0.91,
    # Liquids
    water = 1.0,               # 1 g/ml baseline
    milk = 1.036,              # 245 g per cup
    heavy_cream = 1.0,
    yogurt = 1.05,
    sour_cream = 1.05,
    buttermilk = 1.03,
    # Seasonings & leaveners
    salt = 1.2,
    baking_powder = 0.72,
    baking_soda = 0.76,
    vanilla_extract = 0.88,
    almond_extract = 0.9,
    cinnamon = 0.64,
    cocoa_powder = 0.5,
    # Proteins & dairy products
    eggs = 1.05,               # approximate per 100ml
    milk_powder = 0.5,
    cream_cheese = 1.1,
    # Other common ingredients
    peanut_butter = 1.0,
    chocolate_chips = 0.65,
    nuts_general = 0.7,
    berries = 0.75,
    apple = 0.6
  )
}

get_density <- function(name) {
  if (is.null(name) || name == "") return(NA_real_)
  n <- tolower(name)
  
  # Check custom densities first (if available)
  tryCatch({
    custom <- get_custom_densities()
    if (!is.null(custom) && length(custom) > 0) {
      # Exact match on custom name
      for (ing in names(custom)) {
        if (tolower(ing) == n) return(custom[[ing]])
      }
      # Keyword match on custom names
      for (ing in names(custom)) {
        if (grepl(tolower(ing), n)) return(custom[[ing]])
      }
    }
  }, error = function(e) {
    # Silently continue if custom densities not available
  })
  
  # Fall back to built-in density table with keyword matching
  dt <- density_table()
  if (grepl("flour", n)) return(dt$flour)
  if (grepl("sugar", n)) return(dt$sugar)
  if (grepl("butter", n)) return(dt$butter)
  if (grepl("milk", n)) return(dt$milk)
  if (grepl("oil", n)) return(dt$oil)
  if (grepl("water", n)) return(dt$water)
  if (grepl("salt", n)) return(dt$salt)
  NA_real_
}

volume_ml_to_mass_g <- function(volume_ml, ingredient_name) {
  d <- get_density(ingredient_name)
  if (is.na(d)) return(NA_real_)
  as.numeric(volume_ml) * d
}

mass_g_to_volume_ml <- function(mass_g, ingredient_name) {
  d <- get_density(ingredient_name)
  if (is.na(d)) return(NA_real_)
  as.numeric(mass_g) / d
}

## Convert between units using density when necessary
convert_with_density <- function(qty, unit, target_system = c("american","european"), ingredient_name = NULL) {
  target_system <- match.arg(target_system)
  # convert to metric base
  m <- unit_to_metric(qty, unit)
  if (m$type == "unknown" && !is.null(ingredient_name)) {
    # try infer unitless as cups if name contains common words? skip for safety
  }
  # if type known, convert to preferred display
  if (m$type %in% c("volume","mass")) {
    pref <- metric_to_preferred(m$amount, m$type, target_system)
    return(list(quantity = pref$quantity, unit = pref$unit, display = paste0(pref$quantity, " ", pref$unit)))
  }
  # if unknown but we have density and want to change mass<->volume, attempt via density
  if (!is.null(ingredient_name)) {
    # if original has volume unit but metric reported unknown, try parse alias
    if (!is.na(m$amount) && !is.na(m$unit)) {
      # fallback
      return(list(quantity = qty, unit = unit, display = paste0(qty, " ", unit)))
    }
  }
  list(quantity = qty, unit = unit, display = paste0(qty, " ", unit))
}
