context("Column CDF")
library(DelayedArray)

test_that("matrix and vector CDF correspond on the columns", {
  values <- runif(100)
  matrix <- cbind(rnorm(100), values)

  cdf_values <- approx_cdf(values, 20L)
  cdf_matrix <- approx_col_cdf(matrix, 20L)

  expect_type(cdf_matrix, "list")
  expect_identical(cdf_values, cdf_matrix[[2]])
})

test_that("column names are preserved", {
  matrix <- cbind(runif(100), rnorm(100))
  colnames(matrix) <- c("A", "B")

  cdfs <- approx_col_cdf(matrix, 20L)

  expect_named(cdfs, colnames(matrix))
})

test_that("non-numeric arrays are rejected", {
  d <- DelayedArray(array(1:100, dim = c(2, 50)))
  expect_error(approx_col_cdf(d, 20L), "need as input")
})

test_that("matrix and DelayedMatrix are handled similarly", {
  matrix <- cbind(rnorm(100), runif(100))
  colnames(matrix) <- c("A", "B")

  d <- DelayedArray(matrix)

  expect_identical(
    approx_col_cdf(matrix, 20L),
    approx_col_cdf(d, 20L)
  )
})
