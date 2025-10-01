#! /usr/bin/env python3

"""
Copyright 2024 Carnegie Mellon University.

NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE
MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO
WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER
INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR
MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL.
CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT
TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.

Licensed under a MIT (SEI)-style license, please see license.txt or contact
permission_at_sei.cmu.edu for full terms.

[DISTRIBUTION STATEMENT A] This material has been approved for public release
and unlimited distribution.  Please see Copyright notice for non-US Government
use and distribution.

This Software includes and/or makes use of Third-Party Software each subject to
its own license.

DM24-1686

================================

Simple script to generate graphs from a model

Uses LiNGAM

https://lingam.readthedocs.io/en/latest/tutorial/draw_graph.html

We assume:
- already did pip install lingam
- make sure dot is in system path

"""

import argparse

from pathlib import Path

import lingam
import numpy as np
import pandas as pd

from lingam.utils import make_dot


def main():
    parser = argparse.ArgumentParser(description='Makes a causal graph from dataset.')
    parser.add_argument('filepath', help='Path to input csv file for graphing')
    parser.add_argument('-o', '--output', default=None,
                        help='Output filename WITHOUT extension. '
                             'Default is input csv file path but with .png extension')
    args = parser.parse_args()

    in_path = Path(args.filepath)
    out_path = args.output
    if out_path is None:
        out_path = Path(in_path).parent / in_path.stem

    # Unclear as o the purpose of this.
    np.set_printoptions(precision=3, suppress=True)
    np.random.seed(100)

    # Load the data file
    print(f"Loading from {in_path}")
    x = pd.read_csv(in_path)

    print(f"Fitting using DirectLiNGAM ")
    model = lingam.DirectLiNGAM()
    model.fit(x)
    labels = np.array(x.columns).tolist()

    dot = make_dot(model.adjacency_matrix_, labels=labels)

    # Save as png
    print(f"Saving graph as png to {out_path}")
    dot.format = 'png'
    dot.render(out_path)


if __name__ == '__main__':
    main()
