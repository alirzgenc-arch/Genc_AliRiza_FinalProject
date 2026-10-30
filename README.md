# Can Urban-Music Streaming Improve Forecasts of Vox Support?

**Final project (Track A), Applied AI for Political Scientists, Leiden University.** Ali Rıza Genç (s5265126).

The project asks whether chart-listed Spotify streams for Morad, Beny Jr and Cyril Kamer improve monthly forecasts of Vox's CIS vote-share estimate beyond earlier CIS releases.

**Main result.** In 2024 development validation, adding the music variables lowered the error slightly. On the frozen 2025 exploratory test, they raised it. A persistence forecast (repeating the last CIS estimate) was the most accurate in both periods.

## Contents

| Path | What it is |
|---|---|
| `Genc_AliRiza_FinalProject.Rmd` / `.html` | The report: source and rendered output |
| `R/00_inventory.R` … `R/10_score_2025.R` | The pipeline, from raw files to the model frame, fit and the one-time 2025 scoring |
| `data/raw/` | Raw CIS barometer PDFs and Spotify weekly Spain Top 200 CSVs (development period) |
| `data/quarantine/test_2025/` | 2025 test inputs, scored once and locked |
| `data/metadata/`, `data/interim/`, `data/processed/` | Release dates and aliases, human check sheet, derived files |
| `reports/qa/`, `reports/results/` | Value-free QA outputs; frozen metrics, freeze manifest, 2025 lock |
| `AMENDMENTS.md` | Dated record of every deviation from the original protocol |
| `reports/audit/` | Integrity audit, AI-exposure matrix, changelog, full reproducibility test |
| `README_REPRODUCE.md` | Step-by-step reproduction instructions |

## Reproduce

Requires R with `rmarkdown`, `knitr`, `digest`, `pdftools` and `glmnet`.

```bash
git clone https://github.com/alirzgenc-arch/genc_aliriza_finalproject.git
cd genc_aliriza_finalproject
Rscript --vanilla -e 'rmarkdown::render("Genc_AliRiza_FinalProject.Rmd")'
```

The knit stops unless six built-in checks pass:
- raw PDF hashes;
- re-extraction of the targets from the PDFs;
- freeze manifest;
- development refit;
- 2025 lock;
- recomputed metrics.

To rebuild everything from the raw files, see `README_REPRODUCE.md`.

**Data note.** CIS PDFs: cis.es. Spotify charts: charts.spotify.com; the instructor advised that no permission was needed for this course project (`AMENDMENTS.md`, D54–D55).
