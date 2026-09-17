# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**AIR Tool (AI Robustness Tool)** — a Quarto/Shiny interactive dashboard for assessing ML classifier robustness by identifying and quantifying bias sources using causal inference. Built by Carnegie Mellon University's Software Engineering Institute (SEI), version 2.3.0.

## Commands

### Development Environment

```bash
nix develop          # Enter reproducible dev shell (R, Rust, Tetrad, all deps)
nix flake update     # Update locked dependencies
```
`.envrc` auto-loads the Nix shell if `direnv` is installed.

### Running the Tool

```bash
scripts/run_quarto.sh
# or equivalently:
quarto preview airtool.qmd --server --port 4173
```

Renders and serves the Shiny app at `localhost:4173`.

### Rust Components

```bash
cd identify && cargo build --release   # Causal graph identification CLI
cd score && cargo build --release      # BIC scoring library
```

### Formatting

```bash
dprint fmt    # Format code (config: dprint.json)
```

### Changelog

```bash
git cliff     # Generate changelog (config: cliff.toml, uses conventional commits)
```

## Architecture

The tool has a **four-step user workflow**: Build Causal Graph → Identify Bias Sources → Select Model → View Results.

Three main components work together:

### 1. `airtool.qmd` — Orchestration & UI (R + Quarto/Shiny)
The entire interactive application (~5,100 lines). Handles file uploads (CSV data, knowledge files, R models), triggers causal discovery via rJava/Tetrad, invokes the `identify` CLI, runs TMLE/AIPW estimators for the ATE, and renders results (confidence interval ribbon plots, interpretation text). The Shiny server context begins around line 407.

### 2. `identify/` — Causal Identification (Rust CLI)
Takes a treatment variable, outcome variable, and a DAG file as inputs; outputs JSON with two adjustment sets:
- **Z1**: parents of the treatment variable
- **Z2**: confounders of intermediate variables on the treatment→outcome path

Uses `petgraph` for graph traversal. Called as a subprocess from `airtool.qmd`.

### 3. `score/` — Scoring Engine (Rust library)
Implements BIC (Bayesian Information Criterion) scoring for both discrete and continuous data via the `ScoringMethod` trait. Used by the causal discovery step to evaluate candidate graphs. Depends on `ndarray-linalg` / OpenBLAS.

### Supporting Pieces
- **Tetrad** (Java, via rJava): performs causal discovery (PC/FCI algorithm variants). Heap configured via `AIR_JAVA_XMS_GB` / `AIR_JAVA_XMX_GB` env vars.
- **`unpacker/unpack.py`**: Python 3.6+ utility for extracting Docker/OCI container images (stdlib only).
- **`container-files/`**: scripts used inside the Docker image at runtime.
- **`test_data/`**: example datasets (auto_engine, psp, UAV, etc.) with reference graphs and sample models for manual testing.

## Key Technical Notes

- **Java heap**: controlled by `AIR_JAVA_XMS_GB` / `AIR_JAVA_XMX_GB` — relevant when Tetrad runs out of memory on large graphs.
- **Non-x86 targets**: recently added support (see commit `2ff1742`); Rust cross-compilation settings may matter.
- **Data requirements**: input CSVs must be tabular; models must be saved in R `.rda` format.
- **No automated test suite**: validation is manual — upload test data from `test_data/`, run the workflow, compare against reference graphs in `test_data/scripts/`.
