skip_on_cran()
skip_if_not_installed("curl")
skip_if_offline()
skip_if_not_installed("rstanarm")

data("pbcLong", package = "rstanarm")
m1 <- download_model("stanmvreg_1")
skip_if(is.null(m1))

test_that("clean_names", {
  expect_identical(
    clean_names(m1),
    c("logBili", "albumin", "year", "id", "sex")
  )
})

test_that("find_predictors", {
  expect_identical(
    find_predictors(m1),
    list(
      y1 = list(conditional = "year"),
      y2 = list(conditional = c("sex", "year"))
    )
  )
  expect_identical(find_predictors(m1, flatten = TRUE), c("year", "sex"))
  expect_identical(
    find_predictors(m1, effects = "all", component = "all"),
    list(
      y1 = list(conditional = "year", random = "id"),
      y2 = list(
        conditional = c("sex", "year"),
        random = "id"
      )
    )
  )
  expect_identical(
    find_predictors(
      m1,
      effects = "all",
      component = "all",
      flatten = TRUE
    ),
    c("year", "id", "sex")
  )
})

test_that("find_response", {
  expect_equal(
    find_response(m1, combine = TRUE),
    c(y1 = "logBili", y2 = "albumin")
  )
  expect_equal(
    find_response(m1, combine = FALSE),
    c(y1 = "logBili", y2 = "albumin")
  )
})

test_that("get_response", {
  expect_equal(nrow(get_response(m1)), 304)
  expect_equal(colnames(get_response(m1)), c("logBili", "albumin"))
})

test_that("find_statistic", {
  expect_null(find_statistic(m1))
})

test_that("find_variables", {
  expect_identical(
    find_variables(m1),
    list(
      response = c(y1 = "logBili", y2 = "albumin"),
      y1 = list(conditional = "year", random = "id"),
      y2 = list(
        conditional = c("sex", "year"),
        random = "id"
      )
    )
  )
  expect_identical(
    find_variables(m1, flatten = TRUE),
    c("logBili", "albumin", "year", "id", "sex")
  )
  expect_identical(
    find_variables(m1, effects = "random"),
    list(
      response = c(y1 = "logBili", y2 = "albumin"),
      y1 = list(random = "id"),
      y2 = list(random = "id")
    )
  )
})

test_that("find_terms", {
  expect_identical(
    find_terms(m1),
    list(
      y1 = list(
        response = "logBili",
        conditional = "year",
        random = "id"
      ),
      y2 = list(
        response = "albumin",
        conditional = c("sex", "year"),
        random = c("year", "id")
      )
    )
  )
  expect_identical(
    find_terms(m1, flatten = TRUE),
    c("logBili", "year", "id", "albumin", "sex")
  )
})

test_that("n_obs", {
  expect_equal(n_obs(m1), 304)
})

test_that("find_parameters", {
  expect_equal(
    find_parameters(m1, component = "all", effects = "full"),
    structure(
      list(
        y1 = list(
          conditional = c("y1|(Intercept)", "y1|year"),
          random = c(
            sprintf("b[y1|(Intercept) id:%i]", 1:40),
            "Sigma[id:y1|(Intercept),y1|(Intercept)]",
            "Sigma[id:y2|(Intercept),y1|(Intercept)]",
            "Sigma[id:y2|year,y1|(Intercept)]"
          ),
          sigma = "y1|sigma"
        ),
        y2 = list(
          conditional = c("y2|(Intercept)", "y2|sexf", "y2|year"),
          random = c(
            sprintf(
              c("b[y2|(Intercept) id:%i]", "b[y2|year id:%i]"),
              rep(1:40, each = 2)
            ),
            "Sigma[id:y2|(Intercept),y1|(Intercept)]",
            "Sigma[id:y2|year,y1|(Intercept)]",
            "Sigma[id:y2|(Intercept),y2|(Intercept)]",
            "Sigma[id:y2|year,y2|(Intercept)]",
            "Sigma[id:y2|year,y2|year]"
          ),
          sigma = "y2|sigma"
        )
      ),
      is_mv = "1"
    )
  )
  expect_equal(
    find_parameters(m1, component = "all"),
    structure(
      list(
        y1 = list(
          conditional = c("y1|(Intercept)", "y1|year"),
          random = c(
            "Sigma[id:y1|(Intercept),y1|(Intercept)]",
            "Sigma[id:y2|(Intercept),y1|(Intercept)]",
            "Sigma[id:y2|year,y1|(Intercept)]"
          ),
          sigma = "y1|sigma"
        ),
        y2 = list(
          conditional = c("y2|(Intercept)", "y2|sexf", "y2|year"),
          random = c(
            "Sigma[id:y2|(Intercept),y1|(Intercept)]",
            "Sigma[id:y2|year,y1|(Intercept)]",
            "Sigma[id:y2|(Intercept),y2|(Intercept)]",
            "Sigma[id:y2|year,y2|(Intercept)]",
            "Sigma[id:y2|year,y2|year]"
          ),
          sigma = "y2|sigma"
        )
      ),
      is_mv = "1"
    )
  )

  expect_equal(
    find_parameters(m1, effects = "full"),
    structure(
      list(
        y1 = list(
          conditional = c("y1|(Intercept)", "y1|year"),
          random = c(
            sprintf("b[y1|(Intercept) id:%i]", 1:40),
            "Sigma[id:y1|(Intercept),y1|(Intercept)]",
            "Sigma[id:y2|(Intercept),y1|(Intercept)]",
            "Sigma[id:y2|year,y1|(Intercept)]"
          )
        ),
        y2 = list(
          conditional = c("y2|(Intercept)", "y2|sexf", "y2|year"),
          random = c(
            sprintf(
              c("b[y2|(Intercept) id:%i]", "b[y2|year id:%i]"),
              rep(1:40, each = 2)
            ),
            "Sigma[id:y2|(Intercept),y1|(Intercept)]",
            "Sigma[id:y2|year,y1|(Intercept)]",
            "Sigma[id:y2|(Intercept),y2|(Intercept)]",
            "Sigma[id:y2|year,y2|(Intercept)]",
            "Sigma[id:y2|year,y2|year]"
          )
        )
      ),
      is_mv = "1"
    )
  )
  expect_equal(
    find_parameters(m1, effects = "fixed"),
    structure(
      list(
        y1 = list(conditional = c("y1|(Intercept)", "y1|year")),
        y2 = list(conditional = c("y2|(Intercept)", "y2|sexf", "y2|year"))
      ),
      is_mv = "1"
    )
  )

  expect_equal(
    find_parameters(m1, effects = "fixed", component = "all"),
    structure(
      list(
        y1 = list(
          conditional = c("y1|(Intercept)", "y1|year"),
          sigma = "y1|sigma"
        ),
        y2 = list(
          conditional = c("y2|(Intercept)", "y2|sexf", "y2|year"),
          sigma = "y2|sigma"
        )
      ),
      is_mv = "1"
    )
  )

  expect_equal(
    find_parameters(m1, effects = "fixed"),
    structure(
      list(
        y1 = list(conditional = c("y1|(Intercept)", "y1|year")),
        y2 = list(conditional = c("y2|(Intercept)", "y2|sexf", "y2|year"))
      ),
      is_mv = "1"
    )
  )

  expect_equal(
    find_parameters(m1, effects = "random", component = "all"),
    structure(
      list(
        y1 = list(random = c(
          sprintf("b[y1|(Intercept) id:%i]", 1:40),
          "Sigma[id:y1|(Intercept),y1|(Intercept)]",
          "Sigma[id:y2|(Intercept),y1|(Intercept)]",
          "Sigma[id:y2|year,y1|(Intercept)]"
        )),
        y2 = list(random = c(
          sprintf(
            c("b[y2|(Intercept) id:%i]", "b[y2|year id:%i]"),
            rep(1:40, each = 2)
          ),
          "Sigma[id:y2|(Intercept),y1|(Intercept)]",
          "Sigma[id:y2|year,y1|(Intercept)]",
          "Sigma[id:y2|(Intercept),y2|(Intercept)]",
          "Sigma[id:y2|year,y2|(Intercept)]",
          "Sigma[id:y2|year,y2|year]"
        ))
      ),
      is_mv = "1"
    )
  )

  expect_equal(
    find_parameters(m1, effects = "grouplevel"),
    list(
      y1 = list(random = sprintf("b[y1|(Intercept) id:%i]", 1:40)),
      y2 = list(random = sprintf(
        c("b[y2|(Intercept) id:%i]", "b[y2|year id:%i]"),
        rep(1:40, each = 2)
      ))
    ),
    ignore_attr = TRUE
  )
  expect_equal(
    find_parameters(m1, effects = "random"),
    list(
      y1 = list(random = c(
        sprintf("b[y1|(Intercept) id:%i]", 1:40),
        "Sigma[id:y1|(Intercept),y1|(Intercept)]",
        "Sigma[id:y2|(Intercept),y1|(Intercept)]",
        "Sigma[id:y2|year,y1|(Intercept)]"
      )),
      y2 = list(random = c(
        sprintf(c("b[y2|(Intercept) id:%i]", "b[y2|year id:%i]"), rep(1:40, each = 2)),
        "Sigma[id:y2|(Intercept),y1|(Intercept)]",
        "Sigma[id:y2|year,y1|(Intercept)]",
        "Sigma[id:y2|(Intercept),y2|(Intercept)]",
        "Sigma[id:y2|year,y2|(Intercept)]",
        "Sigma[id:y2|year,y2|year]"
      ))
    ),
    ignore_attr = TRUE
  )
})

test_that("get_parameters", {
  expect_named(
    get_parameters(m1),
    c("y1|(Intercept)", "y1|year", "y2|(Intercept)", "y2|sexf", "y2|year")
  )
  expect_named(
    get_parameters(m1, effects = "all"),
    c(
      "y1|(Intercept)", "y1|year", "Sigma[id:y1|(Intercept),y1|(Intercept)]",
      "Sigma[id:y2|(Intercept),y1|(Intercept)]", "Sigma[id:y2|year,y1|(Intercept)]",
      "y2|(Intercept)", "y2|sexf", "y2|year", "Sigma[id:y2|(Intercept),y2|(Intercept)]",
      "Sigma[id:y2|year,y2|(Intercept)]", "Sigma[id:y2|year,y2|year]"
    )
  )
  expect_named(
    get_parameters(m1, effects = "full"),
    c(
      "y1|(Intercept)", "y1|year", "b[y1|(Intercept) id:1]", "b[y1|(Intercept) id:2]",
      "b[y1|(Intercept) id:3]", "b[y1|(Intercept) id:4]", "b[y1|(Intercept) id:5]",
      "b[y1|(Intercept) id:6]", "b[y1|(Intercept) id:7]", "b[y1|(Intercept) id:8]",
      "b[y1|(Intercept) id:9]", "b[y1|(Intercept) id:10]", "b[y1|(Intercept) id:11]",
      "b[y1|(Intercept) id:12]", "b[y1|(Intercept) id:13]", "b[y1|(Intercept) id:14]",
      "b[y1|(Intercept) id:15]", "b[y1|(Intercept) id:16]", "b[y1|(Intercept) id:17]",
      "b[y1|(Intercept) id:18]", "b[y1|(Intercept) id:19]", "b[y1|(Intercept) id:20]",
      "b[y1|(Intercept) id:21]", "b[y1|(Intercept) id:22]", "b[y1|(Intercept) id:23]",
      "b[y1|(Intercept) id:24]", "b[y1|(Intercept) id:25]", "b[y1|(Intercept) id:26]",
      "b[y1|(Intercept) id:27]", "b[y1|(Intercept) id:28]", "b[y1|(Intercept) id:29]",
      "b[y1|(Intercept) id:30]", "b[y1|(Intercept) id:31]", "b[y1|(Intercept) id:32]",
      "b[y1|(Intercept) id:33]", "b[y1|(Intercept) id:34]", "b[y1|(Intercept) id:35]",
      "b[y1|(Intercept) id:36]", "b[y1|(Intercept) id:37]", "b[y1|(Intercept) id:38]",
      "b[y1|(Intercept) id:39]", "b[y1|(Intercept) id:40]", "Sigma[id:y1|(Intercept),y1|(Intercept)]",
      "Sigma[id:y2|(Intercept),y1|(Intercept)]", "Sigma[id:y2|year,y1|(Intercept)]",
      "y2|(Intercept)", "y2|sexf", "y2|year", "b[y2|(Intercept) id:1]",
      "b[y2|year id:1]", "b[y2|(Intercept) id:2]", "b[y2|year id:2]",
      "b[y2|(Intercept) id:3]", "b[y2|year id:3]", "b[y2|(Intercept) id:4]",
      "b[y2|year id:4]", "b[y2|(Intercept) id:5]", "b[y2|year id:5]",
      "b[y2|(Intercept) id:6]", "b[y2|year id:6]", "b[y2|(Intercept) id:7]",
      "b[y2|year id:7]", "b[y2|(Intercept) id:8]", "b[y2|year id:8]",
      "b[y2|(Intercept) id:9]", "b[y2|year id:9]", "b[y2|(Intercept) id:10]",
      "b[y2|year id:10]", "b[y2|(Intercept) id:11]", "b[y2|year id:11]",
      "b[y2|(Intercept) id:12]", "b[y2|year id:12]", "b[y2|(Intercept) id:13]",
      "b[y2|year id:13]", "b[y2|(Intercept) id:14]", "b[y2|year id:14]",
      "b[y2|(Intercept) id:15]", "b[y2|year id:15]", "b[y2|(Intercept) id:16]",
      "b[y2|year id:16]", "b[y2|(Intercept) id:17]", "b[y2|year id:17]",
      "b[y2|(Intercept) id:18]", "b[y2|year id:18]", "b[y2|(Intercept) id:19]",
      "b[y2|year id:19]", "b[y2|(Intercept) id:20]", "b[y2|year id:20]",
      "b[y2|(Intercept) id:21]", "b[y2|year id:21]", "b[y2|(Intercept) id:22]",
      "b[y2|year id:22]", "b[y2|(Intercept) id:23]", "b[y2|year id:23]",
      "b[y2|(Intercept) id:24]", "b[y2|year id:24]", "b[y2|(Intercept) id:25]",
      "b[y2|year id:25]", "b[y2|(Intercept) id:26]", "b[y2|year id:26]",
      "b[y2|(Intercept) id:27]", "b[y2|year id:27]", "b[y2|(Intercept) id:28]",
      "b[y2|year id:28]", "b[y2|(Intercept) id:29]", "b[y2|year id:29]",
      "b[y2|(Intercept) id:30]", "b[y2|year id:30]", "b[y2|(Intercept) id:31]",
      "b[y2|year id:31]", "b[y2|(Intercept) id:32]", "b[y2|year id:32]",
      "b[y2|(Intercept) id:33]", "b[y2|year id:33]", "b[y2|(Intercept) id:34]",
      "b[y2|year id:34]", "b[y2|(Intercept) id:35]", "b[y2|year id:35]",
      "b[y2|(Intercept) id:36]", "b[y2|year id:36]", "b[y2|(Intercept) id:37]",
      "b[y2|year id:37]", "b[y2|(Intercept) id:38]", "b[y2|year id:38]",
      "b[y2|(Intercept) id:39]", "b[y2|year id:39]", "b[y2|(Intercept) id:40]",
      "b[y2|year id:40]", "Sigma[id:y2|(Intercept),y2|(Intercept)]",
      "Sigma[id:y2|year,y2|(Intercept)]", "Sigma[id:y2|year,y2|year]"
    )
  )
})

test_that("linkfun", {
  expect_false(is.null(link_function(m1)))
  expect_length(link_function(m1), 2)
})

test_that("linkinv", {
  expect_false(is.null(link_inverse(m1)))
  expect_length(link_inverse(m1), 2)
})


test_that("is_multivariate", {
  expect_true(is_multivariate(m1))
})

test_that("clean_parameters", {
  expect_equal(
    clean_parameters(m1),
    data.frame(
      Parameter = c(
        "y1|(Intercept)", "y1|year", "y2|(Intercept)",
        "y2|sexf", "y2|year", "b[y1|(Intercept) id:1]", "b[y1|(Intercept) id:2]",
        "b[y1|(Intercept) id:3]", "b[y1|(Intercept) id:4]", "b[y1|(Intercept) id:5]",
        "b[y1|(Intercept) id:6]", "b[y1|(Intercept) id:7]", "b[y1|(Intercept) id:8]",
        "b[y1|(Intercept) id:9]", "b[y1|(Intercept) id:10]", "b[y1|(Intercept) id:11]",
        "b[y1|(Intercept) id:12]", "b[y1|(Intercept) id:13]", "b[y1|(Intercept) id:14]",
        "b[y1|(Intercept) id:15]", "b[y1|(Intercept) id:16]", "b[y1|(Intercept) id:17]",
        "b[y1|(Intercept) id:18]", "b[y1|(Intercept) id:19]", "b[y1|(Intercept) id:20]",
        "b[y1|(Intercept) id:21]", "b[y1|(Intercept) id:22]", "b[y1|(Intercept) id:23]",
        "b[y1|(Intercept) id:24]", "b[y1|(Intercept) id:25]", "b[y1|(Intercept) id:26]",
        "b[y1|(Intercept) id:27]", "b[y1|(Intercept) id:28]", "b[y1|(Intercept) id:29]",
        "b[y1|(Intercept) id:30]", "b[y1|(Intercept) id:31]", "b[y1|(Intercept) id:32]",
        "b[y1|(Intercept) id:33]", "b[y1|(Intercept) id:34]", "b[y1|(Intercept) id:35]",
        "b[y1|(Intercept) id:36]", "b[y1|(Intercept) id:37]", "b[y1|(Intercept) id:38]",
        "b[y1|(Intercept) id:39]", "b[y1|(Intercept) id:40]", "Sigma[id:y1|(Intercept),y1|(Intercept)]",
        "Sigma[id:y2|(Intercept),y1|(Intercept)]", "Sigma[id:y2|year,y1|(Intercept)]",
        "b[y2|(Intercept) id:1]", "b[y2|year id:1]", "b[y2|(Intercept) id:2]",
        "b[y2|year id:2]", "b[y2|(Intercept) id:3]", "b[y2|year id:3]",
        "b[y2|(Intercept) id:4]", "b[y2|year id:4]", "b[y2|(Intercept) id:5]",
        "b[y2|year id:5]", "b[y2|(Intercept) id:6]", "b[y2|year id:6]",
        "b[y2|(Intercept) id:7]", "b[y2|year id:7]", "b[y2|(Intercept) id:8]",
        "b[y2|year id:8]", "b[y2|(Intercept) id:9]", "b[y2|year id:9]",
        "b[y2|(Intercept) id:10]", "b[y2|year id:10]", "b[y2|(Intercept) id:11]",
        "b[y2|year id:11]", "b[y2|(Intercept) id:12]", "b[y2|year id:12]",
        "b[y2|(Intercept) id:13]", "b[y2|year id:13]", "b[y2|(Intercept) id:14]",
        "b[y2|year id:14]", "b[y2|(Intercept) id:15]", "b[y2|year id:15]",
        "b[y2|(Intercept) id:16]", "b[y2|year id:16]", "b[y2|(Intercept) id:17]",
        "b[y2|year id:17]", "b[y2|(Intercept) id:18]", "b[y2|year id:18]",
        "b[y2|(Intercept) id:19]", "b[y2|year id:19]", "b[y2|(Intercept) id:20]",
        "b[y2|year id:20]", "b[y2|(Intercept) id:21]", "b[y2|year id:21]",
        "b[y2|(Intercept) id:22]", "b[y2|year id:22]", "b[y2|(Intercept) id:23]",
        "b[y2|year id:23]", "b[y2|(Intercept) id:24]", "b[y2|year id:24]",
        "b[y2|(Intercept) id:25]", "b[y2|year id:25]", "b[y2|(Intercept) id:26]",
        "b[y2|year id:26]", "b[y2|(Intercept) id:27]", "b[y2|year id:27]",
        "b[y2|(Intercept) id:28]", "b[y2|year id:28]", "b[y2|(Intercept) id:29]",
        "b[y2|year id:29]", "b[y2|(Intercept) id:30]", "b[y2|year id:30]",
        "b[y2|(Intercept) id:31]", "b[y2|year id:31]", "b[y2|(Intercept) id:32]",
        "b[y2|year id:32]", "b[y2|(Intercept) id:33]", "b[y2|year id:33]",
        "b[y2|(Intercept) id:34]", "b[y2|year id:34]", "b[y2|(Intercept) id:35]",
        "b[y2|year id:35]", "b[y2|(Intercept) id:36]", "b[y2|year id:36]",
        "b[y2|(Intercept) id:37]", "b[y2|year id:37]", "b[y2|(Intercept) id:38]",
        "b[y2|year id:38]", "b[y2|(Intercept) id:39]", "b[y2|year id:39]",
        "b[y2|(Intercept) id:40]", "b[y2|year id:40]", "Sigma[id:y2|(Intercept),y1|(Intercept)]",
        "Sigma[id:y2|year,y1|(Intercept)]", "Sigma[id:y2|(Intercept),y2|(Intercept)]",
        "Sigma[id:y2|year,y2|(Intercept)]", "Sigma[id:y2|year,y2|year]",
        "y1|sigma", "y2|sigma"
      ),
      Effects = c(
        "fixed", "fixed", "fixed",
        "fixed", "fixed", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "random", "random", "random",
        "random", "random", "random", "random", "fixed", "fixed"
      ),
      Component = c(
        "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "sigma", "sigma"
      ),
      Group = c(
        "", "", "", "", "", "Intercept: id", "Intercept: id", "Intercept: id",
        "Intercept: id", "Intercept: id", "Intercept: id", "Intercept: id",
        "Intercept: id", "Intercept: id", "Intercept: id", "Intercept: id",
        "Intercept: id", "Intercept: id", "Intercept: id", "Intercept: id",
        "Intercept: id", "Intercept: id", "Intercept: id", "Intercept: id",
        "Intercept: id", "Intercept: id", "Intercept: id", "Intercept: id",
        "Intercept: id", "Intercept: id", "Intercept: id", "Intercept: id",
        "Intercept: id", "Intercept: id", "Intercept: id", "Intercept: id",
        "Intercept: id", "Intercept: id", "Intercept: id", "Intercept: id",
        "Intercept: id", "Intercept: id", "Intercept: id", "Intercept: id",
        "Intercept: id", "Var/Cov: id", "Var/Cov: id", "Var/Cov: id",
        "Intercept: id", "year: id", "Intercept: id", "year: id", "Intercept: id",
        "year: id", "Intercept: id", "year: id", "Intercept: id", "year: id",
        "Intercept: id", "year: id", "Intercept: id", "year: id", "Intercept: id",
        "year: id", "Intercept: id", "year: id", "Intercept: id", "year: id",
        "Intercept: id", "year: id", "Intercept: id", "year: id", "Intercept: id",
        "year: id", "Intercept: id", "year: id", "Intercept: id", "year: id",
        "Intercept: id", "year: id", "Intercept: id", "year: id", "Intercept: id",
        "year: id", "Intercept: id", "year: id", "Intercept: id", "year: id",
        "Intercept: id", "year: id", "Intercept: id", "year: id", "Intercept: id",
        "year: id", "Intercept: id", "year: id", "Intercept: id", "year: id",
        "Intercept: id", "year: id", "Intercept: id", "year: id", "Intercept: id",
        "year: id", "Intercept: id", "year: id", "Intercept: id", "year: id",
        "Intercept: id", "year: id", "Intercept: id", "year: id", "Intercept: id",
        "year: id", "Intercept: id", "year: id", "Intercept: id", "year: id",
        "Intercept: id", "year: id", "Intercept: id", "year: id", "Intercept: id",
        "year: id", "Intercept: id", "year: id", "Intercept: id", "year: id",
        "Var/Cov: id", "Var/Cov: id", "Var/Cov: id", "Var/Cov: id", "Var/Cov: id",
        "", ""
      ),
      Response = c(
        "y1", "y1", "y2", "y2", "y2", "y1", "y1",
        "y1", "y1", "y1", "y1", "y1", "y1", "y1", "y1", "y1", "y1", "y1",
        "y1", "y1", "y1", "y1", "y1", "y1", "y1", "y1", "y1", "y1", "y1",
        "y1", "y1", "y1", "y1", "y1", "y1", "y1", "y1", "y1", "y1", "y1",
        "y1", "y1", "y1", "y1", "y1", "y1", "y1", "y1", "y2", "y2", "y2",
        "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2",
        "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2",
        "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2",
        "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2",
        "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2",
        "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2",
        "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2", "y2",
        "y2", "y2", "y2", "y2", "y2", "y1", "y2"
      ),
      Cleaned_Parameter = c(
        "(Intercept)", "year", "(Intercept)", "sexf", "year", "id:1", "id:2", "id:3",
        "id:4", "id:5", "id:6", "id:7", "id:8", "id:9", "id:10", "id:11",
        "id:12", "id:13", "id:14", "id:15", "id:16", "id:17", "id:18",
        "id:19", "id:20", "id:21", "id:22", "id:23", "id:24", "id:25",
        "id:26", "id:27", "id:28", "id:29", "id:30", "id:31", "id:32",
        "id:33", "id:34", "id:35", "id:36", "id:37", "id:38", "id:39",
        "id:40", "(Intercept)", "(Intercept)", "year ~ (Intercept)",
        "id:1", "id:1", "id:2", "id:2", "id:3", "id:3", "id:4", "id:4",
        "id:5", "id:5", "id:6", "id:6", "id:7", "id:7", "id:8", "id:8",
        "id:9", "id:9", "id:10", "id:10", "id:11", "id:11", "id:12",
        "id:12", "id:13", "id:13", "id:14", "id:14", "id:15", "id:15",
        "id:16", "id:16", "id:17", "id:17", "id:18", "id:18", "id:19",
        "id:19", "id:20", "id:20", "id:21", "id:21", "id:22", "id:22",
        "id:23", "id:23", "id:24", "id:24", "id:25", "id:25", "id:26",
        "id:26", "id:27", "id:27", "id:28", "id:28", "id:29", "id:29",
        "id:30", "id:30", "id:31", "id:31", "id:32", "id:32", "id:33",
        "id:33", "id:34", "id:34", "id:35", "id:35", "id:36", "id:36",
        "id:37", "id:37", "id:38", "id:38", "id:39", "id:39", "id:40",
        "id:40", "(Intercept)", "year ~ (Intercept)", "(Intercept)",
        "year ~ (Intercept)", "year", "sigma", "sigma"
      ),
      stringsAsFactors = FALSE
    ),
    ignore_attr = TRUE
  )
})
