# Revision change log — Genc_AliRiza_FinalProject (29 Oct 2026)

Implements `Spain_TrackA_Final_Report_Revision_SOP.md` against the Final Project Guide (4 pp., read in full).
Originals backed up to `submission/pre_revision_backup/` before any change.

## 1. Files inspected
- Source: `Genc_AliRiza_FinalProject.Rmd` (authoritative); rendered `Genc_AliRiza_FinalProject.html`.
- Pipeline: `R/00_inventory.R` … `R/10_score_2025.R` (`R/01_pdf_structure.R` is not in the project; it was a one-off audit and is not needed).
- Inputs read by the report: `data/processed/{cis_vox_verified, model_frame_monthly, forward_predictions}.csv`, `data/processed/fit_freeze.rds`,
  `reports/results/*` (metrics, lambdas, coefficients, freeze manifest, 2025 lock), `reports/qa/*`,
  `data/quarantine/test_2025/work/test2025_predictions.csv`, raw CIS PDFs in `data/raw/cis_2023_2024/`.
- Pre-edit status: the original `.Rmd` knitted cleanly in a fresh session (no pre-existing failure).

## 2. Changes implemented
**Header.** Short H1 and subtitle per SOP; compact byline; one-line "Main finding" box stating the negative result (computed inline).

**Section 1 (Question and data).**
- Operational research question (SOP wording); exact origin/target-window timing; release on the 10th handled as available from the 11th.
- New political-science framing with verified sources: Gayo-Avello (2013), Cranmer & Desmarais (2017), Turnbull-Dugarte (2019; now cited for what it finds — devolution, not immigration, explains early Vox support), Ahmed González (2024; cited only for Morad and Beny Jr as M.D.L.R. members). Cyril Kamer is explicitly *not* attributed to M.D.L.R. (the article does not mention him).
- Outcome vs *voto directo* vs election result; first-release dating and the June-2024 PDF regeneration.
- Predictors: collaboration crediting, zero-charted vs missing (no missing files), d+8 availability convention.
- Table 1 (code-generated counts) and dated design decisions; "pre-registered" replaced by "protocol written before any data were analysed".
- Removed the "four-week-ahead" claim (the analysis is monthly).

**Section 2 (What I did).** Table 2 (models), Ridge vs lasso vs elastic net justification, persistence as benchmark (Hyndman & Athanasopoulos 2021), Table 3 (forward folds: cutoffs, training sizes 9/12/15, forecast origins), explicit statement that 2024 errors were reused for tuning, freeze (17:38) vs scoring lock (18:10) vs prior human exposure. Lambda/coefficient tables removed from the reading flow.

**Section 3 (What I found).** Leads with the answer; Table 4 (grouped 2024 | 2025, MAE/RMSE/bias, units defined); Δ interpretation; bias explanation using frozen artefacts only (M1 λ = 3.30 → heavy shrinkage; M2 λ ≈ 0.004 → nearly unpenalised; 63% of M2's 2025 absolute error comes from its last three forecasts, Aug–Oct 2025); Figure 1 redesigned (two panels, no line across the year break or the July gaps, colour-blind-safe palette with distinct markers, axis "Forecast issued (10th of month)"); Table 5 (the check).

**Section 4 (What I do not trust).** Established / not established; three design-specific limitations (small n + tuning reuse; chart-hit construct; deviations + exposure); bounded closing sentence.

**References.** Added Ahmed González (2024), Friedman et al. (2010), Hyndman & Athanasopoulos (2021); Turnbull-Dugarte with pages and DOI; data sources.

**AI appendix.** All 14 earlier episodes kept; row 14 corrected (it previously claimed the prose was "rewritten in my own words"); rows 15–16 added truthfully. The 150-word reflection is marked in the source with a STUDENT comment: it must be confirmed or rewritten by you.

**Design/CSS** (inline `{css}` chunk, no external fonts/CDNs): Georgia body ~17.5px, system-sans headings and tables, 790px reading column, sticky TOC with the four official headings plus References/Appendix, styled numbered tables with notes, captions, `code_folding: hide`, collapsible "Reproducibility checks" panel, mobile (≤767px) and print rules. Verified at 1440px and 390px (no page-level horizontal overflow; wide tables scroll inside their container) and in print preview (9 pages).

**Reproducibility (new, runs at every knit).** (1) SHA-256 of all 24 raw CIS PDFs; (2) re-extraction of every Vox target from the raw PDFs; (3) freeze manifest; (4) rebuild of the development fit from the frozen model frame in a temporary folder — identical metrics (max diff ≈ 1e-14, also across glmnet 4.1.8 vs 5.2); (5) 2025 scoring lock; (6) reported MAEs recomputed from frozen prediction files. Plus a sign guard so the prose cannot silently contradict the results.

## 3. Integrity checks (all from project files)
| Quantity | Value | Status |
|---|---|---|
| CIS barometers / verified by eye | 24 / 24 | PASS |
| Forecast origins 2023–24 / common cases | 22 / 20 (lost: Jul 2023, Jul 2024) | PASS |
| Training cases per fold | 9 / 12 / 15 | PASS |
| 2024 validation / 2025 scored | 8 / 9 (lost: Jul 2025) | PASS |
| Chart weeks audited | 109 (Morad 109, Beny Jr 101, Cyril Kamer 74, Delarue 0, Moha The B 0) | PASS |
| Identical rows for M0/M1/M2 | dev and 2025 | PASS |
| Metrics vs prediction files | max diff < 1e-10 | PASS |
| Frozen results changed? | No refit/retune; artefacts untouched (rebuild runs in a temp folder) | PASS |
| Timeline | artist audit 17:05 → features 17:10 → frame 17:11 → freeze 17:38 → 2025 lock 18:10 (29 Oct) | PASS |
| Clean-session knit | fresh copy, `Rscript --vanilla`, 0 warnings, figure embedded, no absolute paths | PASS (R 4.3.3 here; your Mac UNVERIFIED) |

Prose length: ≈1,600 words by automated count of Sections 1–4 (includes headings and inline numbers; excludes tables, captions, code, details panel). Target ≈1,500.

## 4. Acceptance checklist (SOP §H)
| Item | Status |
|---|---|
| Four substantive sections + References + Appendix | PASS |
| ≈1,500 prose words, count disclosed | PASS (≈1,600, ~7% over) |
| Short title; precise operational RQ | PASS |
| Political relevance with verified sources, no overstated affiliations | PASS |
| CIS estimate vs direct intention vs votes | PASS |
| Timeline accurate; no "four-week-ahead" claim | PASS |
| Counts recomputed, not copied | PASS |
| 5→3 artists, weekly→monthly, CIS-only, 2022 history disclosed | PASS |
| M0, M1/M2 ridge, elastic-net check explained | PASS |
| Ridge vs lasso/elastic net justified | PASS |
| 2024 validation reused for tuning stated | PASS |
| 2025 exploratory and previously exposed | PASS |
| No refit, retuning or post-test manipulation | PASS |
| Metrics and signs consistent with frozen outputs | PASS |
| Persistence superiority visible | PASS |
| Legible, semantically correct figure and tables | PASS |
| ≥2 specific limitations, no causal language | PASS |
| Raw inputs reachable by the grader; licences honoured | **FAIL — blocker** |
| Clean knit | PASS here; UNVERIFIED on your Mac |
| AI log accurate; authentic ≤150-word reflection | UNVERIFIED (reflection drafted by AI — you must confirm/rewrite) |
| .Rmd + .html + change log delivered | PASS |

## 5. Unresolved risks (ranked)
1. **Data reachability (Guide: "put it somewhere the document can reach … with a line that downloads it").** The report knits only inside the project folder; nothing is hosted yet, and the raw Spotify charts must not be redistributed without permission. Per the Guide, contact Babak or Pouria before the deadline; meanwhile submit the project folder (CIS PDFs, derived files, scripts) through the route they approve.
2. **Deadline:** Friday 30 Oct 2026, 17:00 on Brightspace; both `.Rmd` and `.html`.
3. **Authorship:** most prose was drafted with AI (logged as rows 14–16). Read every paragraph, change what you would not say yourself, and rewrite the reflection paragraph; then remove the `<!-- STUDENT ... -->` comment.
4. **Monthly unit not confirmed with the instructor** (disclosed in Section 4).
5. Knit on your Mac once (`pdftools` and `glmnet` must be installed; both are).
