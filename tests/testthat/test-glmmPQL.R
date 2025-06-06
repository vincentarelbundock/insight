skip_if_not_installed("nlme")
skip_if_not_installed("MASS")
skip_if(getRversion() < "4.3.0")

test_that("find_formula, get_data glmmPQL", {
  example_dat <- data.frame(
    prop = c(0.2, 0.2, 0.5, 0.7, 0.1, 1, 1, 1, 0.1),
    size = c("small", "small", "small", "large", "large", "large", "large", "small", "small"),
    x = c(0.1, 0.1, 0.8, 0.7, 0.6, 0.5, 0.5, 0.1, 0.1),
    species = c("sp1", "sp1", "sp2", "sp2", "sp3", "sp3", "sp4", "sp4", "sp4"),
    stringsAsFactors = FALSE
  )

  mn <- MASS::glmmPQL(prop ~ x + size,
    random = ~ 1 | species,
    family = "quasibinomial", data = example_dat
  )
  expect_identical(find_formula(mn)$conditional, as.formula("prop ~ x + size"))
  expect_named(get_data(mn), c("prop", "x", "size", "species"))
})
