library(testthat)
source('../../R/ingredient_utils.R')

test_that('parse_fraction handles mixed numbers and fractions', {
  expect_equal(parse_fraction('1 1/2'), 1.5)
  expect_equal(parse_fraction('1/2'), 0.5)
  expect_equal(parse_fraction('2'), 2)
  expect_equal(round(parse_fraction('1.25'),2), 1.25)
})

test_that('parse_ingredient_line extracts quantity unit and name', {
  p <- parse_ingredient_line('1 1/2 cups flour')
  expect_equal(round(p$quantity,2), 1.5)
  expect_true(grepl('flour', p$name))
  expect_true(!is.na(p$unit))
})

test_that('unit conversion to metric and back works', {
  m <- unit_to_metric(1, 'cup')
  expect_true(abs(m$amount - 236.588) < 0.1)
  pref <- metric_to_preferred(236.588, 'volume', 'american')
  expect_equal(pref$unit, 'cup')
})

test_that('density conversions approximate expected values', {
  # 1 cup flour ~125g
  d <- get_density('all purpose flour')
  expect_true(!is.na(d))
  g <- volume_ml_to_mass_g(236.588, 'flour')
  expect_true(abs(g - 125) < 20) # allow tolerance
})
