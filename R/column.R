# kll - Streaming Quantile Approximation
# Copyright (C) 2018 Gabriele Sales
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


#' Compute the approximate CDF of the columns in a numeric array.
#'
#' @param matrix A numerical matrix.
#' @param k The K parameter for creating a KLL sketch.
#' @param ... Extra named arguments.
#'
#' @rdname approx_col_cdf
#' @export
#'
setGeneric("approx_col_cdf", function(matrix, k, ...) {
  standardGeneric("approx_col_cdf")
})

#' @rdname approx_col_cdf
setMethod(
  "approx_col_cdf", c("matrix", "integer"),
  function(matrix, k) {
    out <- lapply(
      seq_len(ncol(matrix)),
      function(col_idx) approx_cdf(matrix[, col_idx], k)
    )
    transfer_col_names(matrix, out)
  }
)

transfer_col_names <- function(source, target) {
  cnames <- colnames(source)
  if (!is.null(cnames)) {
    names(target) <- cnames
  }
  return(target)
}

#' @rdname approx_col_cdf
setMethod(
  "approx_col_cdf", c("DelayedMatrix", "integer"),
  function(matrix, k) {
    if (DelayedArray::type(matrix) != "double") {
      stop("need as input a numeric matrix")
    }

    cnum <- dim(matrix)[2]
    out <- lapply(seq_len(cnum), function(col_idx) {
      col <- matrix[, col_idx, drop = FALSE]
      approx_cdf(col, k)
    })

    transfer_col_names(matrix, out)
  }
)
