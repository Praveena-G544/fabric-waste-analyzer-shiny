# 🧵 Fabric Waste Analyzer (Shiny version)
**Smart Fabric Cutting and Waste Reduction System — Advanced Mini Project**

A single, self-contained **R Shiny app**. No separate frontend, no Plumber
API, no browser file to open manually — click **Run App** in RStudio and
the whole website appears.

> Educational, approximate decision-support tool only. It does not replace
> a professional tailor's pattern-making or industrial nesting software.
> Always verify actual pattern dimensions and fabric grain direction
> before cutting.

## Folder structure

```
fabric-waste-analyzer-shiny/
├── app.R                     # UI + server (the only file you run)
├── R/                        # auto-sourced by Shiny before app.R runs
│   ├── validation.R          # input-checking helpers
│   ├── calculations.R        # area, %, factorial, even/odd
│   ├── piece_calculator.R    # measurements -> piece sizes
│   ├── layout_generator.R    # shelf-packing algorithm, 3 layouts
│   ├── layout_comparator.R   # ranks layouts, picks the best
│   ├── waste_analyzer.R      # utilization/waste/category
│   ├── reuse_suggestions.R   # rule-based leftover reuse ideas
│   ├── recommendation_engine.R # combines everything for the final page
│   ├── csv_processor.R       # optional CSV upload/validation
│   └── plot_helpers.R        # draws the cutting-layout diagram
├── data/
│   └── sample_garment_pieces.csv
└── fabric-waste-analyzer-shiny.Rproj
```

## Requirements

- R (4.0+) and RStudio
- The `shiny` package (usually already installed with RStudio; if not:
  `install.packages("shiny")`)

## How to run it

1. Open `fabric-waste-analyzer-shiny.Rproj` in RStudio.
2. Open `app.R`.
3. Click the **Run App** button that appears at the top of the editor
   (or run `shiny::runApp()` in the console).
4. A window opens with the whole site: Home → Fabric → Measurements →
   Pieces → Layouts → Waste → Reuse → Recommendation.

That's it — no server to start separately, no browser file to find, no
firewall prompts. Shiny handles all of that internally.

## How the pieces fit together

- **`app.R`** only builds the user interface (the tabs, forms, buttons)
  and wires button clicks to functions. It contains no calculation logic
  itself.
- Every calculation — fabric area, garment piece sizing, the cutting
  layout packing algorithm, waste %, reuse suggestions, and the final
  recommendation — lives in its own file inside **`R/`**, exactly
  mirroring the original modular design.
- Shiny automatically loads every file in `R/` before `app.R` starts, so
  you never need `source()` calls.

## Uploading this to GitHub

**Web upload (no commands):**
1. Create a new empty repository on github.com.
2. "Add file → Upload files", then drag in everything inside this folder.
3. Commit.

**Git commands (optional):**
```bash
git init
git add .
git commit -m "Initial commit: Fabric Waste Analyzer (Shiny)"
git branch -M main
git remote add origin https://github.com/<your-username>/fabric-waste-analyzer.git
git push -u origin main
```

## Notes for your viva

- This is a genuine **R backend** project — every calculation runs in R,
  and Shiny is R's standard framework for turning R code into an
  interactive website.
- The **shelf-packing algorithm** (`layout_generator.R`) is a simplified,
  explainable method for arranging rectangles — not industrial nesting
  software.
- Piece-size formulas (`piece_calculator.R`) are simplified educational
  formulas, not professional tailoring standards.
- Efficiency categories (Excellent/Good/Moderate/High Waste) are
  project-defined, not official industry standards.
- CSV upload is optional; the app works fully from manual input.
- No AI/ML is used; it's mentioned only as a possible future enhancement.
