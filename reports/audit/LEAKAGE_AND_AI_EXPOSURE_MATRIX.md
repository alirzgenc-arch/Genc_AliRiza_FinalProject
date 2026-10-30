# Leakage and AI-exposure matrix (Stage A, 29 Oct 2026)

This matrix contains no outcome values. Italian file contents are not reproduced; none are held in this project.

**Two kinds of risk are kept apart:**
- **ML leakage**: information unavailable at forecast time enters a fitted model's training, features, preprocessing or tuning.
- **Researcher/AI exposure**: a person or AI tool sees future or test information. This can shape design choices (selection contamination) without any fitted model seeing it.

An AI tool *seeing* a file is the second kind, not the first.

## A. Italy project (abandoned)

| Item | Record |
|---|---|
| Design | 14 Oct 2026 in-class Assignment 4 (photo shown by the student): migration-origin Italian rappers' streams → four-week-ahead Fratelli d'Italia national polling, with a 2025 test. SOP v2 names Baby Gang and Ghali as the initial artists; this is not confirmed by any project file. |
| Incident | The student reports accidentally giving an AI tool access to Italian material intended for training and testing. Records `IT-LEGACY` and `IT-1` note prior 2025 outcome exposure, with details not reconstructed. The student's statement that at least one late-2025 Italian Spotify chart was exposed is **not independently documented**. The full scope is unknown, and no access logs are available. |
| Fitted models | None, according to the records. **No ML leakage is demonstrated, or possible, for a model that was never fitted.** |
| Classification | Researcher/AI test exposure in the Italy project; possible design contamination. |
| Response | Italy abandoned; restart with Spain as a precaution. No Italian files or values were carried into the Spain project (folder audit R01; Spain paths contain only CIS and Spain chart files). |
| What it does not show | It does not show that Spain is contamination-free, and it does not show that any AI was trained on the data. |

## B. Spain design history

| Step | Date (CET) | Status |
|---|---|---|
| Roster K = 5 (D13) | 28 Oct | After the 14 Oct lock; no approval on file |
| Protocol v4 (weekly primary; FB-M monthly fallback; weekly needs ≥ 30 training weeks) | 29 Oct 13:18 (zip time) | Before any Spain analysis output (first output 15:13) |
| D47 CIS only; D48 monthly music measure; D49 2022 history | 16:30–16:40 (entry text) | Before the music features (17:10) |
| Weekly FAIL 10 < 30 → FB-M | 17:02 | Poll counts only; precedes all music files |
| K = 5 → 3 (D51) | 17:05 audit | Names and week counts only; precedes stream values |
| Fit and freeze | 17:38 | Development only |
| D52 open 2025 (exploratory) | ≈17:50 | After seeing development results (disclosed) |
| 2025 scoring lock | 18:10 | One batch |

## C. Temporal data controls (ML leakage)

| Control | Implementation | Status |
|---|---|---|
| Target window [10th of m+1, 10th of m+2) | `R/04` l.53 | PASS (code) |
| Poll inputs available at origin; a release on the origin day is excluded | `R/04` l.42 and 52 | PASS (code) |
| Chart availability: week end + 8 days ≤ origin | `R/06` l.68, 77 (hard stop) | PASS (code) |
| Training cases mature before the cutoff | `R/07` l.38–40; `R/08` | PASS (code) |
| Scaling on training rows only | `R/08` `scaler()` | PASS (code) |
| No random split; same cases for M0/M1/M2 | `R/08`; knit check 6 | PASS |
| Tuning on validation | λ chosen on the same 2024 forecasts | Disclosed limitation (tuning/selection-on-validation) |
| 2025 kept out of fitting | Freeze 17:38 < lock 18:10; hashes match | PASS (file times, not authenticated) |

## D. Test (2025) exposure — Spain

| ID | When | Who saw what | Values used? | Risk |
|---|---|---|---|---|
| ES-E01 | Reported 28 Oct | Earlier assistant: an October 2025 Spanish estimate in a search preview | No | Researcher/AI exposure |
| ES-E02 | 28 Oct | Search output with post-development national and 2025 regional figures | No | Researcher/AI exposure |
| ES-E03 | 28 Oct | Mixed-year poll search result with 2025 content | No | Researcher/AI exposure; "no exposure" objective FAIL (irreversible) |
| DOC-E04 | 28 Oct | Modern artist and event context in music searches | No | Low |
| REC-E05 | 29 Oct | 2023–24 outcome snippets; 2026 news; no 2025 values | No | Low |
| E06 | 29 Oct ≈16:45–17:00 and ≈17:50–18:05 | This assistant: search-result titles with 2025–26 Spanish headlines | No | Low |
| D52 | 29 Oct ≈17:50 | Student had seen the development results before deciding to open 2025 | — | Post-hoc test decision |

**Consequence:** 2025 is an *exploratory* out-of-time test, not a pristine holdout. This is stated in the report.

## E. AI access limits in this project

| Material | AI access |
|---|---|
| Raw CIS PDFs (public) | Yes (development 2022–24); used in knit checks |
| Raw Spotify chart CSVs | Not copied to the AI workspace during the analysis or the audits: audits and the Stage B rebuild ran on the student's Mac, and the AI saw only value-free QA outputs before the fit. On 30 Oct (after the lock and all tests), the full project was copied to the AI workspace to build the public GitHub repository, at the student's request (D55). |
| Derived Spotify aggregates (`music_monthly.csv`, `model_frame_monthly.csv`) | Copied to the AI workspace during the SOP v1 revision, after the scoring lock. |
| 2025 quarantine | Before the lock, the AI saw only file names, counts and the QA outputs the student shared. After the lock, the frozen prediction file and 2025 work files were copied for knitting. They were not browsed in Stage A, and nothing was rescored. |
| Italian files | None in this project. |
