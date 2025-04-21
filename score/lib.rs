// AIR Tool
// 
// Copyright 2024 Carnegie Mellon University.
// 
// NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE
// MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO
// WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER
// INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR
// MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL.
// CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT
// TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
// 
// Licensed under a MIT (SEI)-style license, please see license.txt or contact
// permission_at_sei.cmu.edu for full terms.
// 
// [DISTRIBUTION STATEMENT A] This material has been approved for public release
// and unlimited distribution.  Please see Copyright notice for non-US Government
// use and distribution.
// 
// This Software includes and/or makes use of Third-Party Software each subject to
// its own license.
// 
// DM24-1686

//! boss_scoring: A library demonstrating discrete and continuous BIC scoring extracted from BOSS.

use ndarray::{Array2, Axis};
use ndarray_linalg::Inverse;

/// A trait that standardizes the scoring interface.
/// This mimics the Tetrad `Score` interface: we pass in a target node index,
/// plus an array of parent indices, and get back a local "BIC-like" score.
pub trait ScoringMethod {
    /// Returns the local score for `node` given `parents`.
    fn local_score(&self, node: usize, parents: &[usize]) -> f64;

    /// Returns the sample size of the data.
    fn sample_size(&self) -> usize;

    /// Optionally, a convenience method to get "localScoreDiff"
    /// which is localScore(y|Z+x) - localScore(y|Z).
    fn local_score_diff(&self, x: usize, y: usize, z: &[usize]) -> f64 {
        self.local_score(y, &append_array(z, x)) - self.local_score(y, z)
    }
}

/// A helper function to append a single `extra` index to an existing slice of indices.
fn append_array(arr: &[usize], extra: usize) -> Vec<usize> {
    let mut new_vec = arr.to_vec();
    new_vec.push(extra);
    new_vec
}

/// A struct for "DiscreteBicScore"-like logic.
pub struct DiscreteBicScore {
    /// 2D integer-coded data: rows x columns
    data: Vec<Vec<i32>>,
    /// Number of rows in `data`.
    nrows: usize,
    /// Number of columns in `data`.
    ncols: usize,
    /// Number of categories for each column
    num_categories: Vec<usize>,
    /// BIC penalty discount
    penalty_discount: f64,
    /// Optional structure prior
    structure_prior: f64,
}

impl DiscreteBicScore {
    /// Create a new DiscreteBicScore. 
    /// `data` is expected to be row-major (outer vector = rows).
    /// `num_cats` is a vector of same length as number of columns in data.
    pub fn new(data: Vec<Vec<i32>>,
               num_cats: Vec<usize>,
               penalty_discount: f64,
               structure_prior: f64) -> Self {
        let nrows = data.len();
        let ncols = if nrows > 0 { data[0].len() } else { 0 };
        DiscreteBicScore {
            data,
            nrows,
            ncols,
            num_categories: num_cats,
            penalty_discount,
            structure_prior,
        }
    }

    /// Helper: compute the structure prior penalty for `k` parents.
    fn structure_penalty(&self, k: usize) -> f64 {
        // Example: mimic Tetrad approach: if structurePrior = 0, no effect
        if self.structure_prior.abs() <= f64::EPSILON {
            0.0
        } else {
            let p = self.structure_prior / (self.ncols as f64);
            -((k as f64) * p.ln() + (self.ncols as f64 - k as f64) * (1.0 - p).ln())
        }
    }
}

/// Implementation of the scoring trait for discrete data.
impl ScoringMethod for DiscreteBicScore {
    fn local_score(&self, node: usize, parents: &[usize]) -> f64 {
        // 1. gather child categories
        let c = self.num_categories[node];

        // 2. gather #categories for each parent
        let dims: Vec<usize> = parents.iter()
                                      .map(|&p| self.num_categories[p])
                                      .collect();

        // 3. r = product of parent dims
        let mut r = 1usize;
        for &d in &dims {
            r *= d;
        }

        // 4. Create freq. tables: n_jk[r][c]
        let mut n_jk = vec![vec![0usize; c]; r];
        let mut n_j = vec![0usize; r];

        // 5. Fill counts
        for row in 0..self.nrows {
            let child_val = self.data[row][node];
            if child_val < 0 {
                // skip missing
                continue;
            }
            // compute rowIndex in [0..r) for these parents
            let mut row_index = 0;
            let mut factor = 1;

            // TODO: Validate the pi really should be unused.
            for (_pi, &p) in parents.iter().enumerate().rev() {
                // get parent's category
                let parent_val = self.data[row][p];
                if parent_val < 0 {
                    // missing
                    row_index = 0; // skip?
                    continue;
                }
                // combine into row_index
                row_index += (parent_val as usize) * factor;
                factor *= self.num_categories[p];
            }

            // increment counts
            n_jk[row_index][child_val as usize] += 1;
            n_j[row_index] += 1;
        }

        // 6. log-likelihood
        let mut lik = 0.0;
        for j in 0..r {
            let row_count = n_j[j] as f64;
            if row_count == 0.0 { continue; }
            for k in 0..c {
                let cell_count = n_jk[j][k] as f64;
                if cell_count == 0.0 { continue; }
                lik += cell_count * (cell_count / row_count).ln();
            }
        }

        // 7. #params = r * (c - 1)
        let params = r * (c - 1);

        // 8. BIC = 2*lik - penalty_discount * params * ln(N) + 2*(structure prior)
        let n = self.sample_size() as f64;
        let bic = 2.0 * lik
                   - self.penalty_discount * (params as f64) * n.ln()
                   + 2.0 * self.structure_penalty(parents.len());

        // if NaN or infinite, return NaN
        if bic.is_nan() || !bic.is_finite() {
            f64::NAN
        } else {
            bic
        }
    }

    fn sample_size(&self) -> usize {
        self.nrows
    }
}

/// A struct for "ContinuousBicScore" (like a simplified `SemBicScore`).
/// We'll store a matrix for data, assume no missingness for simplicity.
pub struct ContinuousBicScore {
    /// Data is rows x cols
    data: Array2<f64>,
    /// # of rows
    nrows: usize,
    /// # of cols
    ncols: usize,
    /// Penalty discount
    penalty_discount: f64,
    /// Structure prior
    structure_prior: f64,
}

impl ContinuousBicScore {
    pub fn new(data: Array2<f64>,
               penalty_discount: f64,
               structure_prior: f64) -> Self {
        let nrows = data.nrows();
        let ncols = data.ncols();
        Self {
            data,
            nrows,
            ncols,
            penalty_discount,
            structure_prior,
        }
    }

    /// Simple structure penalty, as in SemBicScore.
    fn structure_penalty(&self, k: usize) -> f64 {
        if self.structure_prior.abs() <= f64::EPSILON {
            0.0
        } else {
            // we mimic Tetrad's getStructurePrior(k):
            let p = self.structure_prior / (self.ncols as f64);
            -((k as f64) * p.ln() + (self.ncols as f64 - k as f64) * (1.0 - p).ln())
        }
    }

    /// Regress 'node' on 'parents' and return residual variance
    fn residual_variance(&self, node: usize, parents: &[usize]) -> Option<f64> {
        if parents.is_empty() {
            // variance of node is the sample variance
            let col = self.data.index_axis(Axis(1), node);
            let mean = col.sum() / (self.nrows as f64);
            let mut ssq = 0.0;
            for &val in col {
                let diff = val - mean;
                ssq += diff * diff;
            }
            Some(ssq / (self.nrows as f64))
        } else {
            // build design matrix X (nrows x (k)) from parents
            let k = parents.len();
            let mut x = Array2::<f64>::zeros((self.nrows, k));
            for (j, &p) in parents.iter().enumerate() {
                for i in 0..self.nrows {
                    x[[i, j]] = self.data[[i, p]];
                }
            }
            // build Y vector
            let mut y = vec![0.0; self.nrows];
            for i in 0..self.nrows {
                y[i] = self.data[[i, node]];
            }

            // TODO: If the result is wrong, ensure that y is not mutated below.
            let y_prime = y.clone();

            // compute Beta = (X^T X)^{-1} X^T y
            // we do naive inversion for demonstration. Real usage: robust linear solve
            let xt = x.t();
            let xtx = xt.dot(&x);
            let inv = xtx.clone().inv().ok()?;
            let xty = xt.dot(&Array2::from_shape_vec((self.nrows, 1), y).ok()?);
            let beta = inv.dot(&xty);

            // compute residual variance: var(y - X beta)
            let mut resid_ssq = 0.0;
            for i in 0..self.nrows {
                let mut pred = 0.0;
                for j in 0..k {
                    pred += x[[i, j]] * beta[[j, 0]];
                }
                let diff = y_prime[i] - pred;
                resid_ssq += diff * diff;
            }
            Some(resid_ssq / (self.nrows as f64))
        }
    }
}

impl ScoringMethod for ContinuousBicScore {
    fn local_score(&self, node: usize, parents: &[usize]) -> f64 {
        // 1. compute variance of residual
        let var_e = match self.residual_variance(node, parents) {
            Some(v) => v,
            None => return f64::NAN, // if inversion fails
        };

        // 2. log-likelihood ~ - (N/2) * ln(var_e)
        let lik = -0.5 * (self.nrows as f64) * var_e.ln();

        // 3. #params = parents.len(); (ignore intercept for BIC or assume data is mean-centered)
        let k = parents.len();

        // 4. penalty
        let c = self.penalty_discount;
        let n = self.sample_size() as f64;
        let bic = 2.0 * lik
                   - c * (k as f64) * n.ln()
                   - 2.0 * self.structure_penalty(k);

        if bic.is_nan() || !bic.is_finite() { f64::NAN } else { bic }
    }

    fn sample_size(&self) -> usize {
        self.nrows
    }
}
