// kll - Streaming Quantile Approximation
// Copyright (C) 2018 Gabriele Sales
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

#include <cmath>
#include <random>
#include <utility>

#include <Rcpp.h>
using namespace Rcpp;

#include "kll.h"


KLL::KLL(int k) : k(k), c(2.0/3.0), size(0), maxSize(0), compactors{} {
  grow();
}

void KLL::grow() {
  compactors.push_back({});

  maxSize = 0;
  for (int level = 0; level < compactors.size(); level++) {
    maxSize += capacity(level);
  }
}

int KLL::capacity(int level) const {
  const double depth = compactors.size() - level - 1;
  return static_cast<int>(std::ceil(std::pow(c, depth) * k)) + 1;
}

void KLL::update(double value) {
  compactors[0].push_back(value);
  size += 1;

  if (size >= maxSize) {
    compress();
  }
}

void selectAndCopy(std::vector<double>& source, std::vector<double>& target) {
  std::sort(source.begin(), source.end());

  std::uniform_real_distribution<double> unif(0., 1.);
  std::default_random_engine re;
  const int offset = unif(re) < 0.5 ? 0 : 1;

  for (int i = offset; i < source.size(); i += 2) {
    target.push_back(source[i]);
  }
}

void KLL::compress() {
  for (int level = 0; level < compactors.size(); level++) {
    if (compactors[level].size() >= capacity(level)) {
      if (level + 1 >= compactors.size()) {
        grow();
      }

      selectAndCopy(compactors[level], compactors[level+1]);
      compactors[level].clear();

      recalcSize();
      break;
    }
  }
}

void KLL::recalcSize() {
  size = 0;
  for (int i = 0; i < compactors.size(); i++) {
    size += compactors[i].size();
  }
}

double totalWeight(const std::vector<std::pair<double, double>>& weighted) {
  double total = 0;
  for (const auto& p : weighted) {
    total += p.second;
  }
  return total;
}

std::pair<std::vector<double>, std::vector<double>> KLL::cdf() const {
  const auto weighted = weightedItems();
  const double total = totalWeight(weighted);

  std::vector<double> items;
  std::vector<double> values;
  double cumulative = 0;
  for (const auto& p : weighted) {
    cumulative += p.second;
    items.push_back(p.first);
    values.push_back(cumulative / total);
  }

  return {items, values};
}

std::vector<std::pair<double, double>> KLL::weightedItems() const {
  std::vector<std::pair<double, double>> items;
  for (int level = 0; level < compactors.size(); level++) {
    const double weight = level == 0 ? 1 : 2 << (level-1);
    for (const auto item : compactors[level]) {
      items.emplace_back(item, weight);
    }
  }

  std::sort(items.begin(), items.end());
  return items;
}


// [[Rcpp::export]]
SEXP kll_new(SEXP k_) {
  int k = as<int>(k_);
  XPtr<KLL> ptr(new KLL(k), true);
  return ptr;
}

// [[Rcpp::export]]
SEXP kll_update(SEXP kll_, const NumericVector& values) {
  XPtr<KLL> kll(kll_);
  for (double value : values) {
    kll->update(value);
  }

  return kll_;
}

// [[Rcpp::export]]
SEXP kll_cdf(SEXP kll_) {
  XPtr<KLL> kll(kll_);
  const auto res = kll->cdf();

  NumericVector items(res.first.begin(), res.first.end());
  NumericVector cdfValues(res.second.begin(), res.second.end());
  return DataFrame::create(Named("item") = items,
                           Named("value") = cdfValues);
}
