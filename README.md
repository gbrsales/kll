# kll

![Build Status](https://travis-ci.org/gbrsales/kll.svg?branch=master)

An R package implementing the first algorithm described by Karnin, Lang and
Liberty in [Optimal Quantile Approximation in Streams](http://arxiv.org/abs/1603.05346).

Efficiently computes (an approximation of) the CDF of numeric values stored in a vector or in a [DelayedArray](https://bioconductor.org/packages/release/bioc/html/DelayedArray.html).

## Usage

```{r}
library(DelayedArray)
library(kll)

d <- DelayedArray(array(runif(1000000, dim = c(1000000, 1))))
approx_cdf(d, 20L)
```

The library handles blocking transparently. For instance, the code below will process the array in chunks of 100 rows each while producing the same final result as above.

```{r}
setAutoGridMaker(function(x) rowGrid(x, nrow = 100))
approx_cdf(d, 20L)
```

It is also possible to obtain column-level CDFs:

```{r}
d <- DelayedArray(array(runif(1000), dim = c(500, 2)))
approx_col_cdf(d, 20L)
```

## Stability

The package is still under active development. It should be considered **experimental**.
