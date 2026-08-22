## Ingredient parsing and scaling utilities

parse_fraction <- function(s) {
  # Handle forms like "1 1/2", "1/2", "1.5"
  s <- gsub("\u00A0", " ", s) # non-breaking spaces
  s <- trimws(s)
  if (s == "" || is.na(s)) {
    return(NA_real_)
  }
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
  if (is.null(line)) {
    return(list(quantity = NA_real_, unit = NA_character_, name = "", raw = ""))
  }
  raw <- trimws(as.character(line))
  if (raw == "") {
    return(list(quantity = NA_real_, unit = NA_character_, name = "", raw = ""))
  }
  tokens <- strsplit(raw, "\\s+")[[1]]
  qty_raw <- NULL
  unit <- NULL
  name <- NULL
  # detect mixed number: first token integer and second token fraction
  if (
    length(tokens) >= 2 &&
      grepl('^\\d+$', tokens[1]) &&
      grepl('^\\d+\\/\\d+$', tokens[2])
  ) {
    qty_raw <- paste(tokens[1], tokens[2])
    tokens <- tokens[-c(1, 2)]
  } else if (
    grepl('^\\d+\\/\\d+$', tokens[1]) ||
      grepl('^[0-9]+(?:[\\.,][0-9]+)?$', tokens[1])
  ) {
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
  if (is.na(name) || name == "") {
    name <- raw
  }
  if (!is.null(unit)) {
    unit <- tolower(unit)
  }
  list(
    quantity = ifelse(is.na(qty), NA_real_, qty),
    unit = ifelse(is.null(unit) || unit == "", NA_character_, unit),
    name = trimws(name),
    raw = raw
  )
}

parse_ingredients_raw <- function(text) {
  lines <- trimws(unlist(strsplit(
    as.character(text),
    "[\\r\\n]+",
    perl = TRUE
  )))
  lines <- lines[nzchar(lines)]
  lapply(seq_along(lines), function(i) {
    parsed <- parse_ingredient_line(lines[i])
    list(
      ingredient_name = parsed$name,
      raw_text = parsed$raw,
      quantity = parsed$quantity,
      unit = parsed$unit,
      is_optional = FALSE
    )
  })
}

## Unit system conversion utilities
# Canonical units: volume -> ml, mass -> g
unit_aliases <- local({
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
  function(u) {
    if (is.null(u)) {
      return(NA_character_)
    }
    s <- tolower(gsub("\\.$", "", trimws(u)))
    for (k in names(map)) {
      if (s %in% map[[k]]) return(k)
    }
    s
  }
})

unit_to_metric <- function(qty, unit) {
  # return list(amount, type, unit) where unit is 'ml' or 'g'
  if (is.null(unit) || is.na(unit) || unit == "") {
    return(list(amount = qty, type = "unknown", unit = NA_character_))
  }
  u <- unit_aliases(unit)
  vol_ml <- c(cup = 236.588, tbsp = 14.7868, tsp = 4.92892, l = 1000, ml = 1)
  mass_g <- c(oz = 28.3495, lb = 453.592, kg = 1000, g = 1)
  if (!is.na(u) && u %in% names(vol_ml)) {
    return(list(
      amount = as.numeric(qty) * vol_ml[[u]],
      type = "volume",
      unit = "ml"
    ))
  }
  if (!is.na(u) && u %in% names(mass_g)) {
    return(list(
      amount = as.numeric(qty) * mass_g[[u]],
      type = "mass",
      unit = "g"
    ))
  }
  # unknown: return original
  list(amount = qty, type = "unknown", unit = u)
}

metric_to_preferred <- function(
  amount,
  type = c("volume", "mass"),
  system = c("american", "european")
) {
  type <- match.arg(type)
  system <- match.arg(system)
  if (type == "volume") {
    if (system == "american") {
      # prefer cups if >= 120 ml (~0.5 cup), else tbsp/tsp
      if (amount >= 120) {
        return(list(quantity = round(amount / 236.588, 2), unit = "cup"))
      }
      if (amount >= 15) {
        return(list(quantity = round(amount / 14.7868, 2), unit = "tbsp"))
      }
      return(list(quantity = round(amount / 4.92892, 2), unit = "tsp"))
    } else {
      # european metric -> ml or l
      if (amount >= 1000) {
        return(list(quantity = round(amount / 1000, 2), unit = "l"))
      }
      return(list(quantity = round(amount, 1), unit = "ml"))
    }
  }
  if (type == "mass") {
    if (system == "american") {
      # prefer lb if >= 453.592g
      if (amount >= 453.592) {
        return(list(quantity = round(amount / 453.592, 2), unit = "lb"))
      }
      return(list(quantity = round(amount / 28.3495, 1), unit = "oz"))
    } else {
      if (amount >= 1000) {
        return(list(quantity = round(amount / 1000, 2), unit = "kg"))
      }
      return(list(quantity = round(amount, 0), unit = "g"))
    }
  }
  list(quantity = NA_real_, unit = NA_character_)
}
