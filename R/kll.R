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

#' Compute the CDF of some numeric values.
#'
#' @param object A collection of numeric values.
#' @param k The K parameter for creating a KLL sketch.
#' @param ... Extra named arguments.
#'
#' @rdname kll_cdf
#' @export
#'
setGeneric("kll_cdf", function(object, k, ...) {
  standardGeneric("kll_cdf")
})

#' @rdname kll_cdf
setMethod(
  "kll_cdf", c("numeric", "integer"),
  function(object, k) {
    kll <- kll_new(k)
    kll_update(kll, object)
    kll_cdf_impl(kll)
  }
)

#' @rdname kll_cdf
setMethod(
  "kll_cdf", c("DelayedArray", "integer"),
  function(object, k) {
    if (DelayedArray::type(object) != "double") {
      stop("kll_cdf requires as input numeric (double) values")
    }

    kll <- DelayedArray::blockReduce(
      function(x, init) kll_update(init, x),
      object,
      kll_new(k)
    )
    kll_cdf_impl(kll)
  }
)
