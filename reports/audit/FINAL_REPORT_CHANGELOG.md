# Final report changelog — Stage A (SOP v2), 29 Oct 2026

Source edited: `Genc_AliRiza_FinalProject.Rmd`. The HTML is knitted from it; no manual HTML patches.
Backups were made before any edit:
- `submission/pre_stageA_backup/` on the Mac;
- `backup_stageA_before.Rmd` in the AI workspace.

**Impact on numbers: NONE.**
- No model, data file, frozen artefact or 2025 output was changed.
- All numbers are still computed inline from the frozen files.
- The six knit-time checks and the sign guard pass.

Line numbers refer to the revised `.Rmd`.

| Line | Section | Change | Why (SOP v2) | Evidence |
|---|---|---|---|---|
| 208 | S1 relevance | Turnbull-Dugarte limited to the 2018 Andalusian election. Ahmed González now "discusses Morad and Beny Jr … as part of this scene" instead of calling them collective members. Cyril Kamer kept as not discussed. One sentence trimmed. | §5 S1 | Article PDF pp. 4, 12, 13, 20 |
| 210 | S1 outcome | Names the check sheet. Adds the same-day-press vintage check for the six regenerated 2024 PDFs. Shorter. | §5 S1, §7.3 | `data/interim/cis_vox_manual_check.csv` notes |
| 212 | S1 predictors | Wording tightened; content unchanged. | Word count | — |
| 228 (new) | S1 | **Design history** paragraph: the 14 Oct Italy design; accidental AI access to Italian training/test files (student's account; late-2025 chart flagged as not independently documented); no Italian model fitted; possible design contamination, not demonstrated leakage; Spain restart after the deadline without approval; protocol predates Spain analysis. | §3 | D53; `LEAKAGE_AND_AI_EXPOSURE_MATRIX.md` §A |
| 230 | S1 decisions | Replaces "protocol written before any data were analysed" with "each dated in `AMENDMENTS.md` (times from files, not version control)". | §3, §4 | File times only |
| 232 | S1 bullet | Monthly fallback "decided on poll counts before any music feature existed". | §3 artist/frequency provenance | 17:02 < 17:10 |
| — | S1 bullet | "2022 as history only" bullet removed; Table 1 still states it. | Word count | Table 1 row 1 |
| 252 | S2 why ridge | Lasso sentence condensed; argument unchanged. | Word count | — |
| 270 | S2 freeze | Adds a Table 3 takeaway. Replaces "The freeze guarantees that 2025 could not change the models" with "Today's files match that manifest; the order of events rests on file timestamps, not an authenticated log". | §5 S2, §4 | Knit checks 3–5 |
| 348 | S3 bias | Shorter. Removes the clause about Vox's higher 2025 level and the closing persistence sentence. Uses only frozen outputs. | §5 S3, word count | — |
| 350 | Figure caption | States the target window exactly, notes that 2024 errors were used to choose λ, and calls 2025 an exploratory test of frozen models. | §5 S3 | — |
| 369 | Figure y-axis | "Vox, target-window CIS estimate (% valid vote)" | §5 S3 | — |
| 371 | Figure x-axis | `gap.axis = 0.2` so every month is labelled; the 2025 panel had dropped Mar, May and Sep. | §6 | Screenshot check |
| 397 | S3 check | Rationale stated first; shorter. | Word count | — |
| 403–405 | S4 L1, L2 | Shorter; content kept. | Word count | — |
| 407 | S4 L3 | Replaces "I had read some 2025 Spanish polling news" with the recorded exposures (ES-E01–E03, E06; no value used). Points to the design history. Adds the redistribution limit. | §3, §5 S4 | Exposure ledger |
| — | S4 close | "Bounded failure" paragraph removed; it repeated "What it does not establish". | Word count | — |
| 411 | References | URL changed to `/trans/articulo/677/…` | §5 S1 | See audit: open the link once |
| 450 | AI log row 16 | Turnbull-Dugarte qualifier added. | Accuracy | — |
| 451 (new) | AI log row 17 | Checking: this final audit and revision. | §5 refs/AI | This session |
| — | Reflection | Unchanged (122 words). `<!-- STUDENT -->` marker **kept**, since you have not yet confirmed it. | §5 | — |

**Other files changed:**
- `AMENDMENTS.md`: appended **D53** (Italy → Spain history) and **E06** (AI search-title exposure). Both are marked as recorded at about 20:20 on 29 Oct, not backdated.
- New in `reports/audit/`: this file, `final_integrity_audit.md` and `LEAKAGE_AND_AI_EXPOSURE_MATRIX.md`.

**Word count:** Sections 1–4 come to ≈1,542 prose words (1,569 tokens including headings). Before this revision the same method gave 1,598 tokens.

## Later changes, 29 Oct ≈20:35–20:48
| Where | Change | Why |
|---|---|---|
| References: Data | "used under written permission" changed to "The instructor advised that no permission was needed…; the raw files are included in the project repository" | D54–D55 |
| Repro panel, checks 3 and 5 | `strsplit(" ")` replaced by a space-safe `read_manifest()` with row-count guards | Stage B test L2-4. Lock and manifest files are untouched. |
| Repro panel note | Points to `reports/audit/repro/` | Stage B |
| AI log | Row 18 (Checking: reproducibility test) | Record of AI use |
| New file | `README_REPRODUCE.md` | Stage B L0/L4 |

Impact on numbers: NONE.

## Guide compliance pass, 30 Oct ≈15:45
| Where | Change | Why (Final Project Guide) |
|---|---|---|
| Setup chunk | Downloads the project from GitHub (`archive/refs/heads/main.zip`) when the .Rmd is knitted outside the project folder; it then knits from there | "a line in the document that downloads it from there"; must "run from raw inputs to reported numbers on a machine that is not yours" |
| References: Data | Repository link added | Same |
| Setup comment | Dropped the phrase naming `install.packages()` | "No install.packages() in the document" |
| S2, S3, S4 | Four small trims (≈40 words): S3 opening, the freeze sentence, L1, the S1 closing clause | Prose now ≈1,481 words (limit 1,500) |

Tested: the .Rmd alone in an empty folder (another computer, R 4.3.3) downloads the repository, passes all six checks, and renders text identical to the in-project build. Impact on numbers: NONE.
