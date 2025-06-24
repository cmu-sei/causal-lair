/home/djshepard/.cargo/bin/git-cliff 85249bca3ac9234edde11c0b3bc895ff5da6071e..HEAD                                                                                                   42s  11:54:19
# Changelog
## [Unreleased]


### <!-- 0 -->🚀 Features

- feat/ui-overhaul + bug-fixes: material-flat styling, reactive graph, simpler thresholds, safer DOT
  - Styling & UX
    - Re-skinned all interactive controls to material-flat
      - actionBttn() calls now use style = "material-flat"
      - Custom CSS makes fileInput() browse buttons + progress bars match the palette, adds hover elevation, tighter corner-radius and fixes overlap/squish.
    - Replaced three “radio block” buttons with a single selectInput("model_exist") for a cleaner model picker.
    - Dropped the dedicated “Update Graph” button – the graph now re-highlights automatically whenever both X & Y selectors are filled (vars_ready()).
  - Threshold UI
    - Removed directional operators (tv_dir, ov_dir). Both X & Y are binarised on ≥ threshold only.
    - New helpers (nice_step(), split_threshold(), make_threshold_ui()) create numeric inputs with sensible step sizes and no all-ones/all-zeros edge cases.
  - Server logic
    - Added highlighted_graph() reactive and rewired blankGraph to use it, eliminating manual colour changes scattered across observers.
    - Introduced graph_ready() / vars_ready() reactive flags to gate UI pieces that depend on both variable choices.
    - Pruned the obsolete observer tied to the old update button; rebuilt adjustment-set handling inside a simplified observeEvent(vars_ready()).
  - Learner pipeline
    - runSuperLearner() / processResults() signatures simplified (only thresholds passed).
    - Consistent binarisation logic moved inline; helper binarize_var() deleted.
  - Graph colour-injection
    - Rewrote get_updated_graph() to:
      - strip stale fill attributes,
      - emit new, standalone node declarations instead of appending attributes to edge lines (fixes Graphviz “syntax error near '->'” in PDF build),
      - avoid duplicate declarations with an internal cache.
  - Report generation
    - Adjusted histogram calls (no dir args) and graph calls to new get_updated_graph() signature.
    - Added debug dump (updatedgraph_DEBUG.dot) for easier future troubleshooting.
  - Misc
    - Commented out options(warn = 2) during development noise.
    - Sidebar text tweaked from H4→H5 to stay visually consistent.
- feat(app): rename to `airtool.qmd`, add material-flat UI polish, centralise logging, and simplify thresholds
  
- Branding / filenames
    -  AIRTool_v2.2.qmd  →  airtool.qmd
    -  scripts/AIRReport.qmd → report.qmd
    -  update preview script, .gitignore, and cleanup script to match
  
- UI polish
    -  Adopt **material-flat** buttons everywhere (bye-bye jelly)
    -  Re-style <input type="file"> browse buttons + progress bar for true
       Material look/feel & consistent shadows/spacing
    -  Switch “existing model?” picker from radioGroupButtons → selectInput
    -  Remove “Update Graph” button – graph now auto-refreshes when
       both X & Y variables are chosen
    -  Tighten copy (“Step 1-…”, etc.) and use h5 instead of h4 to
       respect visual hierarchy
  
- Threshold inputs
    -  Drop verbose dir/threshold logic; treat ≥ threshold as default
    -  New helpers `nice_step()`, `split_threshold()`, and
       `make_threshold_ui()` auto-size numericInput step values
  
- Histograms
    -  Completely rewritten `get_histogram_x()` / `get_histogram_y()`
       (cleaner bins, fixed legend order, deterministic binwidth)
  
- Graph highlighting
    -  New reactive `highlighted_graph()`; colour nodes once,
       deduplicate fills, remove dangling declarations
    -  Slimmed-down `get_updated_graph()` (idempotent & DOT-safe)
  
- Reactive flow
    -  `vars_ready()` and `graph_ready()` replace old `graph_update`
       sentinel; graph & downstream UI now gate on these
    -  Observer rewritten to recompute adjustment sets automatically
       whenever X/Y change
  
- Logging
    -  Silenced console spam (commented out stray cat()s)
    -  Added `suppressMessages()` around big library block
    -  TODO: next step is to swap ad-hoc cat() calls for
       a thin wrapper around the **logger** package (see below)
  
- Misc
    -  Turned off `options(shiny.trace = TRUE)` by default
    -  build-scripts and cleanup scripts track new filenames
    -  switched report template copy path

### <!-- 1 -->🐛 Bug Fixes
- fixed final graph output in left pane
- fixed histogram legend position to make them look less terrible
- fixed issue with dot file formatting
- fix bug where PDFs cannot be printed because dot is missing

### <!-- 10 -->💼 Other
- added Markov Checker and Grid Search, but adjustment set is broken
- reintroduced rust binary for step 2 to serve as placeholder until updated tetrad binary is added
- attempted to fix issue where final graph wasn't rendering after calculations finished
- Fully updated with new Tetrad jar
- debug state
- replaced Step 2 rust algorithm withupdated Ramsey-Percovic algorithm
- Clean up the repo, add some cleanup functions to the shell
- roll all R code into the main qmd while re-factoring
- fish functions for identifying modified files and performing cleanup
- initial re-factoring state, before things get crazy
- core: isolate TMLE vs ML paths & remove brittle I/O
  * Introduce tmle_buffer, ml_buffer, combined_buffer.
  * runSuperLearner() now returns one-row summary + diagnostics; no temp CSV.
  * processResults() rebuilt to join causal + ML frames and emit single summary row.
  * Replace file-based graph plumbing with in-memory buffers.
  * Rewrite Shiny observers for parallel-safe operation.
  * Drop dead TetradSearch methods and platform-specific branches.
  * Fix ribbon plot CI handling; make plots/report in-memory.
- AIR: drop ImageMagick, switch to native Cairo/PDF workflow & clean-up build
  * render pipeline
    • new `save_plot_pdf()` and `save_dot_to_pdf()` helpers – ggplot and
      DiagrammeR graphs are now written straight to high-dpi PDF
    • report template embeds the PDFs (`![](foo.pdf){width=100%}`) so the
      final PDF stays pin-sharp when zoomed
    • removed all magick-based helpers and their calls
  * fonts / graphics stack
    • global `theme_set(theme_gray(base_family = "DejaVu Sans"))`
    • force Cairo devices (`png(type="cairo")`, `cairo_pdf()`)
    • writable /etc/fonts with DejaVu added in flake for container images
  * code refactor
    • consolidated library imports; dropped magick
    • `ml_buffer()` now keeps only the Stacked SL row to avoid duplicates
    • rebuilt `df_vars` locally and export to workers with `clusterExport`
    • added guard clauses + clearer errors in `download_report()`
  * infrastructure
    • deleted obsolete Dockerfile (Nix container replaces it)
    • flake: removed nix-vscode-extensions overlay, add rsvg, DiagrammeRsvg,
      tidy baseInfo (fonts.conf, local.conf), prune code-server bits
    • updated lockfile accordingly
  * UI / metadata
    • dashboard title clarified (“AIR — prototype…”)
    • report *.qmd cleaned: blocks use `echo: false`, removed knitr echoes
  This re-enables PDF report generation at full resolution, removes an
  entire ImageMagick dependency tree, and shrinks the image size.

- Add structured file-based logging via `logger`
  - Pull in the `logger` package and initialize a rolling log file under `logs/` named by timestamp
  - Set log level to DEBUG and install a `appender_file()` to capture every log
  - Define convenience wrappers: `log_debug()`, `log_info()`, `log_warn()`, `log_error()`
  - Redirect all remaining stdout/stderr messages into the same log via `sink()`
  - Replace ad-hoc `cat()`/`warning()` calls in core routines (`AIR_getGraph`, `AIR_getAdjSets`, `runSuperLearner`, etc.) with structured `log_debug()`/`log_info()` calls
  - Prune out commented-out legacy logging fragments
  - Update Nix flake to include `rPackages.logger`
  - Modify `run_quarto.sh` to launch Quarto in quiet mode and print only a single “AIR Tool at …” banner
  
  This gives us a single, clean, DEBUG-level log file without polluting the console.

- Lock UI during calculation, improve step size logic, and persist input state
  - Added shinyjs for JS-based UI locking and disabled states
  - Refactored all UI renderers to lock or replace inputs (file, select, numeric, action buttons) after "Conduct Experiment" is clicked
  - Inputs retain chosen values after locking; file uploads and ATE now show as greyed-out labels
  - Improved numeric step size logic (fine_step) for threshold selectors to use half-bin increments based on histogram width, making adjustments more intuitive
  - Changed go button label to "Conduct Experiment"
  - Moved most session state/init into Quarto server context for proper reset on reload
  - Added missing shinyjs dep to flake
  - Made script/run_quarto.sh silent by default (remove distractions from console)
  - Renamed the log file to reflect new loggin infrastructure (not all logs are error logs)

Make AIR Tool robust + debuggable

* Logging
  • export log_* helpers to .GlobalEnv
  • enable shiny.fullstacktrace + custom shiny.error handler

* Java / Tetrad bootstrap
  • add safe_jcall() – traps Java exceptions
  • add get_tetrad_path() helper; use everywhere
  • share safe_jcall + get_tetrad_path with parallel workers

* Graph helpers
  • new graph_to_dot() wrapper for all DOT generation
  • escape DOT-unsafe chars in change_node_color()

* DOT parsing fix
  • rewrite is_edge_line(), split_line(), first_node(), second_node()
    to parse quoted edges → Y-selector now shows descendants

* Validation / guards
  • tiny helpers: check_numeric(), check_column_exists(), safe_thresh()
  • strict file-type/size checks for data, knowledge, model uploads
  • reactive guards both_ready(), reachability checks

* Parallel cluster
  • clusterExport() now ships safe_jcall, log helpers, graph_to_dot,
    get_tetrad_path → no more “TETRAD_PATH not found” in workers

* Knowledge file
  • expect columns level,variable (matches custom format)

* UI polish
  • X/Y selectors persist after lock; histogram/threshold wait for data

* Cleanup
  • remove duplicate initialize_java() blocks
  • replace raw .jcall() with safe_jcall() across codebase

## [v0.5.1]

### <!-- 1 -->🐛 Bug Fixes
- fixed code causing histogram issues on step 2 selection.
  fixed code that made rust's identify binary nondeterministic. note: this binary is currently rwx, but execute privilages should be double-checked before build
- fixed QUARTO_R path variable
- fixed error with 'do it all for me' associated with results interpretation
- fixed bugs: buttons are two colors and add alerts after each step
- fixed identify rust binary bug and reinserted into code base
- fix output binary path issue for identify
- fixed knowledge file logic
- fixed knowledge file upload bug that was causing button to not appear
- fix windows line endings
- fix flake path issue
- fix log file folder creation
- fixed Y variable selector so that users can no longer select parents/ancestors of X as the Y variable
- fixed some color scheming that should help with forced dark mode readers
- fixed some issues with quarto dashboard markdown rendering on the 'docs' tab
- fix the download button
- fixing line endings and getting rid of warnings and errors
- fix flake lock issue with github actions
- fix flake lock issue with github actions
- fix tagging issue
- fix API rate limiting issue
- fix API rate limiting issue
- fix space issue on the runner
- fix cachix usage in the workflow
- fix trusted keys
- fix cachix

### <!-- 10 -->💼 Other
- replaced `identify.R` with `identify`, which is a static Rust binary.
  `identify` takes in two arguments and returns two arguments.
  R requires the library `jsonlite` be installed to parse the output, so it was added to the install_dependencies.R script. This should run smoothly (though I haven't tested it end to end).
- (hopefully) fixed bug where app crashed after user attempted to use their own model. The issue arises because the model was assumed to be passing the model as a reactive element. This was fixed by explicitly passing the model to the function. This is my best guess at fixing this bug
- Fix for validation of histogram data
- Initial scoring code for the BOSS port
- Merge branch 'master' of ssh://code.sei.cmu.edu:7999/cdc/tailor---air
  need to keep my changes to flake.nix
- looks like a lot of my fixes got lost at some point. Adding them back into the chain
- added source code for identify
- updated to include fully-recovered rust binary
- added execute permissions to identify binary. In the .qmd, created global variables for Z1 and Z2 due to interpretation UI section throwing an error that it was missing.
- noticed some aggregations that might also cause issues in the interpretation UI section
- there was a single fat-fingered colon that broke the ui interpretation... repushing
- finally fixed the ui interpretation bug!
- added hotfix for model bug
- Remove binaries and prevent them from entering the tree
- Initial attempt to add identify binary as a flake
- added path variable as --param3 to identify rust binary
- Merge branch 'master' of ssh://code.sei.cmu.edu:7999/cdc/tailor---air
  merging remote commits so that everything is up to date before I start
  making changes (Nick)
- added some (untested) logic to check knowledge file header and alert user if missing
- added 'about' and 'key' tabs to the tool. About describes the tool (basically the readme for now) and Key explicitly defines all color schemes used in the tool
- deleted stray comma
- added support for parallel computing of superlearner loops
- need to test this on linux. suspect windows issues
- parallel computing task successfully integrated
- added verbose log files for progress and error tracking
- added automatic log clearing logic. logs older than 30 days will be removed when tool is run
- updated error message to point to log file rather than listing non-existent message
- altered docs splash screen to remove non-useful content
- added /logs folder to .gitignore
- added logic to mkdir logs/ in case it doesn't exist
- remove logs from repo
- Merge branch 'master' of ssh://code.sei.cmu.edu:7999/cdc/tailor---air
- added logic to ensure log folder exists
- removed popups for step 1 and 2 for first calculation only (because you can see it directly)
- added additional logic to Y variable selector. Users can no longer select parents/ancestors of X as Y
- dependency updates -- remove package that changed its license
- merged Nick and Dave changes 20250326
- removed some duplicate html chunks
- changed penalty discount from 2 to 1
- added popup to warn users against using forced darkmode readers, while I attempt to find a better solution
- added download button and AIRReport.qmd file to knit together all output into a single pdf document. Unfortunately, I am unable to test this on windows and will have to rely on a docker build to test
- added tinytex to nix flake dependencies to allow pdf downloads
- removed tinytex, because apparently I did it wrong. Will need assistance adding this in the proper location...
- attempting to add a tinytex repo to nix flake
- increased texlive package from light to full
- added 'framed' to packages installed
- added latexextra package to flake
- mark all the files
- updated gray colors for adjustment sets to be consistent with key
- added logic to skip moving results file until final iteration of processresults
- added timestamps onto existing log entries
- initial check-in of scripts and instruction to unpack and run the container, without having container tools
- Clean up the repo - fix windows line endings, remove files that should not be check in, ignore files that shoud not be checked in, prevent future events of windows line endings
- updating deps, fixing vulns
- build the scoring code and include it in the flake, even as of yet untested
- Cleaning up console errors and extraneous messages
  Minor clean-ups to the text and formatting.
- Update README.md
- Initial Github Action to build and host an airtool container
- github actions build is failing due to space limitations - this is an attempt at a fix
- Fix cachix account issue for github actions
- Use self-hosted runner option
- get rid of the requirement for sudo
- cachix v14 is required for buildCommand to work

### <!-- 9 -->◀️ Revert
- reverting a change I made to the QUARTO_R path that didn't help
