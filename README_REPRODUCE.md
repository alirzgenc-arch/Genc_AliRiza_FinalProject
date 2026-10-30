# Reproducing Genc_AliRiza_FinalProject

All commands run from the project root (the folder containing `Spain_TrackA.Rproj`). Paths are relative, and no `setwd()` is needed.

## 1. Requirements

- R ≥ 4.3 with the packages `rmarkdown`, `knitr`, `digest`, `pdftools` and `glmnet`. Pandoc is also needed (it comes with RStudio).
- Tested with these setups:
  - R 4.6.1 / glmnet 5.2 (macOS, author);
  - R 4.5.3 / glmnet 5.0 (Ubuntu 22.04 aarch64, conda-forge);
  - R 4.3.3 / glmnet 4.1.8 (Ubuntu x86-64).

  All three give identical reported numbers. The largest numerical difference in refitted predictions was about 5e-14.

## 2. Inputs

| Input | Location | Availability |
|---|---|---|
| CIS *Estimación de voto* PDFs, Nov 2022 – Dec 2024 (24 files) | `data/raw/cis_2023_2024/{2022,2023,2024}/` | Public (cis.es). SHA-256 values are in `reports/qa/cis_raw_inventory.csv`. |
| CIS first-release dates, with sources | `data/metadata/cis_release_dates.csv` | Included |
| Spotify Weekly Top Songs Spain, 1 Dec 2022 – 26 Dec 2024 (109 CSVs) | `data/raw/music_dev/spotify_weekly_es/{2022,2023,2024}/regional-es-weekly-YYYY-MM-DD.csv` | Included in this repository (D55). SHA-256 per file in `reports/qa/music_file_inventory.csv`. |
| Human inputs | `data/interim/cis_vox_manual_check.csv` (by-eye checks) and `data/metadata/artist_aliases.csv` (confirmed spellings) | Included. These record human decisions and are inputs, not outputs. |
| 2025 test material | `data/quarantine/test_2025/` | Scored once, at 18:10 on 29 Oct 2026. **Do not rerun `R/09` or `R/10`.** |

## 3. Development pipeline: raw inputs to model frame

Run this in a **copy** of the project, never in place. The 2025 lock (`reports/results/test2025_lock.txt`) binds the original files. Re-running `R/03` rewrites a timestamp column in `cis_vox_verified.csv`, and the knit-time check would then stop by design.

```bash
Rscript --vanilla R/00_inventory.R       # file inventory and hashes (no values)
Rscript --vanilla R/02_extract_cis.R     # Vox estimate (3rd column, % valid vote) from each PDF
Rscript --vanilla R/03_verify_cis.R      # requires the by-eye check sheet
Rscript --vanilla R/04_poll_calendar.R   # first-release dates, forecast windows, feasibility
Rscript --vanilla R/05_artist_audit.R    # artist spellings and week counts (no streams)
Rscript --vanilla R/06_music_features.R  # log1p mean weekly chart-listed streams, month m-1, d+8 rule
Rscript --vanilla R/07_model_frame.R     # model frame and leakage assertions
Rscript --vanilla R/08_fit_models.R      # development fit (forward folds, ridge / elastic net)
```

Then compare the copy with the frozen project:

```bash
python3 reports/audit/repro/scripts/L3_compare.py <copy> <original>   # value-free, by keys
```

Expected result: every output is byte-identical, except the `verified_check_sheet_mtime` column of `cis_vox_verified.csv`. `model_frame_monthly.csv` must match the SHA-256 recorded in `reports/results/fit_freeze_manifest.txt`. `R/08` outputs must agree numerically with the frozen files (tolerance 1e-8); `reports/audit/repro/scripts/L2_integrity.R` checks this by keys.

## 4. Report

```bash
Rscript --vanilla -e 'rmarkdown::render("Genc_AliRiza_FinalProject.Rmd")'
```

The knit stops unless six checks pass:
1. raw PDF hashes;
2. re-extraction of every target;
3. freeze manifest;
4. development refit in a temporary folder;
5. 2025 lock;
6. metrics recomputed from the stored predictions.

The report reads the frozen artefacts. The 2025 numbers come from the locked prediction file and are not re-estimated.

Full test record: `reports/audit/repro/FULL_REPRODUCIBILITY_REPORT.md`.
