context("CDF")
library(DelayedArray)

common_checks <- function(cdf) {
  expect_is(cdf, "data.frame")
  expect_named(cdf, c("item", "value"))

  expect_gt(nrow(cdf), 10)
  expect_lte(nrow(cdf), 1000)

  expect(
    all(cdf$value >= 0 & cdf$value <= 1.),
    "cdf values must be in the interval [0,1]"
  )
}

test_that("works on normal vectors", {
  v <- 1:1000
  cdf <- kll_cdf(v, 20L)

  common_checks(cdf)
  expect(
    all(cdf$item %in% v),
    "cdf returned some items which do not appear in the original vector"
  )
})

test_that("works on a single-column DelayedArray", {
  d <- DelayedArray(array(runif(1000), dim = c(1000, 1)))
  cdf <- kll_cdf(d, 20L)

  common_checks(cdf)
  expect(
    all(cdf$item >= 0 & cdf$item <= 1),
    "cdf returned some items outside of the expected range"
  )
})

test_that("wants double values", {
  d <- DelayedArray(array(letters, dim = c(length(letters), 1)))
  expect_error(kll_cdf(d, 20L), "requires as input")
})

test_that("handles multidimensional arrays", {
  values <- runif(1000)
  d <- DelayedArray(array(values, dim = c(10, 100)))

  expect_identical(kll_cdf(values, 20L), kll_cdf(d, 20L))
})

test_that("works with a custom grid maker", {
  d <- DelayedArray(array(runif(1000), dim = c(1000, 1)))
  cdf1 <- kll_cdf(d, 20L)

  original <- getAutoGridMaker()
  on.exit(setAutoGridMaker(original))
  setAutoGridMaker(function(x) rowGrid(x, nrow = 100))

  cdf2 <- kll_cdf(d, 20L)
  expect_identical(cdf1, cdf2)
})
