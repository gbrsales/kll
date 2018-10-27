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

#include <utility>
#include <vector>

class KLL {
public:
  KLL(int k);
  void update(double value);
  std::pair<std::vector<double>, std::vector<double>> cdf() const;

private:
  void grow();
  int capacity(int level) const;
  void compress();
  void recalcSize();
  std::vector<std::pair<double, double>> weightedItems() const;

private:
  int k;
  double c;
  int size;
  int maxSize;
  std::vector<std::vector<double> > compactors;
};
