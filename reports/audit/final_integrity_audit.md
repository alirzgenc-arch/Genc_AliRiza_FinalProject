# Final integrity audit — Stage A (SOP v2)

Audit run: 29 Oct 2026, ~20:15–21:00 CET, by Claude (AI) for the student. Read-only on frozen artefacts; no model was fitted, tuned or scored.
Times below are CET (UTC+1). File times were read on the student's Mac with `stat` (reported in UTC, converted here).
**A file time shows when a file was last written. It does not prove when a decision was made, and nothing here is under version control.**
Where this audit says "the record states", that is the level of evidence.

Verification levels used:
- **FILE**: consistent with file contents, hashes or file times.
- **CODE**: implemented in the script, checked by reading it.
- **RUN**: re-executed in this audit.
- **STUDENT**: rests on the student's account only.
- **UNVERIFIED**: no evidence available here.

## 1. Chronological evidence matrix

| # | Event | Date/time (CET) | Source artefact | Information accessible (student / AI) | Affected decision | Risk class | Verification |
|---|---|---|---|---|---|---|---|
| 1 | Italy design submitted (in-class Assignment 4) | 14 Oct 2026 | Photo of the hand-written assignment, shown by the student in chat (not stored in the project) | Design text only | Original design: Italian rappers' streams → four-week-ahead FdI polling, 2025 test | — | STUDENT (photo viewed by AI; not archived) |
| 2 | Student gives an AI tool access to Italian training/test material | Before 28 Oct; exact date not recorded | Student's account (SOP v2 §3); v4 ledger `IT-LEGACY` ("details not reconstructed"); v3 risk register `IT-1` ("prior 2025 outcome exposure in the Italy project") | Student and AI: Italian files. Scope beyond "at least one late-2025 chart" is unknown. | Italy design abandoned | Researcher/AI test exposure (Italy project) | STUDENT; the late-2025 chart is **not independently documented** |
| 3 | No Italian model fitted | — | v4 ledger, D53 | — | Rules out fitted-model leakage in Italy | — | FILE (records state it); not provable as a negative |
| 4 | Spain five-artist roster (D13) | 28 Oct | v4 `FINAL_DECISION_LOG.md` D13 | Artist names | Roster K = 5 | Post-hoc relative to the 14 Oct lock | FILE |
| 5 | ES-E01–E03, DOC-E04: AI search previews show Spanish 2025 polling content | 28 Oct | v4 `FINAL_RISK_AND_EXPOSURE.md` | Student/AI: 2025 Spanish poll snippets (values not reproduced) | None recorded; polling-result searches stopped | Researcher/AI test exposure | FILE (ledger) |
| 6 | First CIS PDFs downloaded | 28 Oct 16:25 onward | raw PDF mtimes (earliest 3390) | Public CIS documents | — | — | FILE |
| 7 | Methods contract v4 (protocol) final | 29 Oct 13:18 | `FINAL_METHODS_CONTRACT.md` (time as stored in the zip) | — | Protocol, weekly ≥ 30 rule, FB-M fallback | Post-14-Oct design | FILE (zip time; weak) |
| 8 | REC-E05: search snippets (2023–24 outcomes, 2026 news; no 2025 value) | 29 Oct (morning) | v4 ledger | As stated | None | Researcher/AI exposure (low) | FILE |
| 9 | Project folders created | 29 Oct 14:48 | `data/metadata/*` dir times | — | — | — | FILE |
| 10 | PDF structure audit (digits masked) | 29 Oct 15:13–15:23 | `reports/qa/pdf_structure_*` | Development PDFs only | Column 3 = target | — | FILE |
| 11 | Inventory, extraction, verification lock | 16:44 / 16:45 / 16:47 | `cis_raw_inventory.csv`, `cis_extraction_qa.csv`, `cis_vox_verified.csv` | Development data | — | — | FILE |
| 12 | D47 (CIS only), D48 (monthly measure c), D49 (2022 history) recorded | 16:30–16:40 per record | `AMENDMENTS.md` (last write 18:05) | — | Roster, music measure | Post-hoc (disclosed) | FILE (entry text only; file time is later) |
| 13 | E06 window 1: AI search titles incl. 2025–26 Spanish headlines | ≈16:45–17:00 | `AMENDMENTS.md` E06; this session | AI: headlines; no values requested | None | Researcher/AI test exposure (low) | FILE + AI session |
| 14 | Vintage notes for 6 regenerated 2024 PDFs | 16:59 | `data/interim/cis_vox_manual_check.csv` (notes column: rtve / El Independiente / Europa Press) | Public press | Confirms first-release values | — | FILE. The notes were written after the 16:47 verification lock; values are re-extracted at every knit (check 2), so they cannot have drifted. |
| 15 | Official release dates; poll feasibility (weekly FAIL 10 < 30, monthly PASS) | 17:00 / 17:02 | `cis_release_dates.csv`, `poll_feasibility_summary.txt` | Poll counts only | Weekly → monthly (FB-M) | — | FILE + CODE. Precedes all music files. |
| 16 | Artist audit → features → frame | 17:05 / 17:10 / 17:11 | `artist_name_audit.csv`, `music_monthly.csv`, `model_frame_monthly.csv` | Development charts (names, week counts; then values) | K = 5 → 3 (D51) | Post-hoc (disclosed) | FILE. Audit precedes features. |
| 17 | Fit + freeze manifest | 17:38 | `fit_freeze_manifest.txt` (header "17:38 CET"); 6 files at 16:38:48 UTC | Development only | λ, models | Tuning on validation (disclosed) | FILE + RUN (manifest hashes match; rebuild identical) |
| 18 | D52: open 2025 as exploratory (student option B) | ≈17:50 | `AMENDMENTS.md` D52; notes | Development results seen | Opening 2025 | Post-hoc test decision (disclosed) | FILE |
| 19 | E06 window 2: AI search titles during 2025 release-date lookup | ≈17:50–18:05 | E06 | As 13 | None | Researcher/AI exposure (low) | FILE |
| 20 | 2025 prep, by-eye check, single scoring batch, lock | 18:06 / 18:10:27 / 18:10:45 | `test2025_prep_qa.txt`, quarantine `work/`, `test2025_lock.txt` | 2025 data (student); AI saw aggregate results | None (no refit) | — | FILE + RUN (lock hashes match) |
| 21 | SOP v1 revision; derived files staged to the AI workspace for knitting | ≈19:00–20:00 | this session | AI: derived development features, frozen predictions, 2025 work files. **Raw Spotify charts were never staged.** | Report only | Licensing (see blocker B2) | AI session |
| 22 | Stage A audit; D53 and E06 recorded | ≈20:20 | `AMENDMENTS.md` | — | Report text only | — | FILE (not backdated) |

## 2. Claims in the report: PASS / FAIL / UNVERIFIED

| Claim (report section) | Status | Evidence |
|---|---|---|
| Counts: 24 barometers, 22 origins, 20 cases, 9 before F1, 109 weeks, 8 / 9 forecasts (S1–S3) | PASS | Computed inline from the frozen frame and prediction files; matches `model_frame_qa.txt`. |
| Window is ≥ 10th of m+1 and < 10th of m+2 (S1) | PASS (CODE) | `R/04_poll_calendar.R` l.53 |
| A release on the 10th is available from the 11th (S1) | PASS (CODE) | `R/04` l.42 and l.52 (`available <= t`) |
| Charts available at week end + 8 days; missing file = NA; absent = 0 (S1) | PASS (CODE + FILE) | `R/06` l.7–8, 68, 77; 0 NA in `music_feature_qa.csv` |
| Target is column 3, % valid vote, not *voto directo* (S1) | PASS (RUN) | Knit check 2 re-extracts all 24 development values from the raw PDFs |
| Every value checked by eye (S1) | PASS for the record; the act itself is STUDENT | `cis_vox_manual_check.csv`: 24 × `OK`. A `TRUE` flag cannot prove the human act. |
| Vintage of 6 regenerated PDFs checked against same-day press (S1) | PASS (FILE) | Check-sheet notes (#14) |
| Weekly → monthly decided on poll counts before any music feature (S1) | PASS (FILE) | #15 precedes #16 |
| Two artists dropped after a names-and-week-counts audit, before stream values (S1) | PASS (FILE + CODE) | `R/05` is value-free; 17:05 < 17:10 |
| Training uses `target_mature_at <= cutoff`; scaling on training rows only (S2) | PASS (CODE) | `R/07` l.38–40; `R/08` `scaler()` l.40–51 |
| 2024 errors reused for tuning (S2, S4) | PASS (disclosed) | `R/08` grid search |
| Files match the frozen manifest; event order rests on file times (S2) | PASS (RUN) / chronology UNVERIFIED-authentic | Knit checks 3–5; no version control |
| No refit or retune after 2025 was opened | PASS (FILE + RUN) | Freeze hashes unchanged; `R/10` scores from `fit_freeze.rds`; lock present |
| Metrics equal recomputation from prediction files | PASS (RUN) | Knit check 6, diff < 1e-10 |
| Frozen MAE anchors (2024: 1.25 / 1.60 / 1.38; 2025: 1.91 / 4.33 / 5.63; Δ −0.23 / +1.29; EN −0.22 / +2.06) | PASS | Unchanged from the stored outputs. No discrepancy, so no STOP. |
| Persistence best in both periods (S3) | PASS | Sign guard in the load chunk |
| Italy design of 14 Oct (S1) | PASS (STUDENT photo) | #1 |
| Accidental AI access to Italian training/test files (S1) | UNVERIFIED (student's account) | Report says "by my account"; the late-2025 chart is flagged as not independently documented |
| No Italian model fitted (S1) | PASS (records state it) | #3 |
| Spain protocol written after 14 Oct, without instructor approval (S1) | PASS | `data/metadata/instructor/` is empty; no approval on file |
| Spain protocol predates any Spain analysis (S1) | PASS (FILE, weak) | 13:18 contract < 15:13 first analysis output. Earlier PDF downloads (28 Oct) are collection, not analysis. |
| 2025 exposure: ES-E01–E03, E06; no value used (S4) | PASS (FILE) | Ledgers; no design change follows any entry |
| Ahmed González (2024) discusses Morad and Beny Jr, sons of Moroccan immigrants from L'Hospitalet; Cyril Kamer not mentioned (S1) | PASS | Article PDF checked 29 Oct: pp. 4, 12, 13, 20; "Cyril Kamer" absent |
| Ahmed González URL (Refs) | PASS (per SOP), UNVERIFIED (link) | Changed to `/trans/articulo/677/…` as SOP v2 requires. The site's indexed English path is `/trans/article/677/…` (fetched and confirmed). The `/articulo/` form could not be fetched from here; open it once before submission. |
| Turnbull-Dugarte (2019) qualified to the 2018 Andalusian election (S1) | PASS | *Research & Politics* 6(2) |
| Spotify data statement (Refs) | PASS (corrected) | Old text "used under written permission" replaced: the instructor advised that no permission was needed (D54); raw files published in the repository (D55). |
| Monthly unit not confirmed with the instructor (S4) | PASS (disclosed) | No instructor file |
| Prose ≈ 1,500 words | PASS (≈ 3% over) | Automated count of Sections 1–4 in the rendered HTML: 1,569 tokens including 27 heading words → **≈ 1,542 prose words**. Excludes tables, notes, captions, code, the details panel and the key-finding box. |
| Reflection ≤ 150 words, student-confirmed | 122 words; confirmation UNVERIFIED | `<!-- STUDENT … -->` marker kept |
| AI appendix complete | PASS with one gap | 17 rows. The Italy AI-access episode is described in S1 but has no row, because its date, tool and purpose are not on record. Add a row only if you can state them. |
| Clean knit | PASS here | Fresh copy, `Rscript --vanilla`, 0 warnings, all six checks passed (R 4.3.3, glmnet 4.1.8). Mac knit UNVERIFIED after these edits. |
| HTML: no page overflow at 1440 / 390 px; no absolute paths | PASS (RUN) | Playwright measurement and screenshots |

## 3. Integrity tests (SOP §7)

1. **Counts / dates / features agree with code — PASS.** All are computed inline; the sign guard stops the knit on contradiction.
2. **Window inequality and publication-day exclusion implemented — PASS (CODE).**
3. **Manual verification — PASS as record; not provable.** The dated sheet exists, with file time 16:59 for the last edit.
4. **Parser extracts the target, not *voto directo* — PASS (RUN).** Run on the development originals only.
5. **Manifests — PASS.**
   - Correct files and values; no user paths.
   - Chronology is **not authenticated**: file times only.
   - Parsing splits on spaces. Current paths contain none, but a path with a space would break it (noted for Stage B).
6. **Validation, λ, freeze, scoring and quarantine match documented intent — PASS.** Tuning reuse is disclosed.
7. **Stored predictions reproduce frozen metrics — PASS.** Rows are keyed by design × model; the same cases are used across M0/M1/M2.
8. **Style changes only through the source — PASS.** The HTML is knitted.
9. **No new fits after 2025 — PASS.**
   - The knit rebuild runs `R/08` on the *development* frame in a temporary folder, as authorised by the reproducibility SOP.
   - It never touches 2025.
10. **Word count, reflection, appendix, citations — see §2.**

## 4. STOP / escalate items (not self-repaired)

- **B1 — Spotify permission: resolved.** The instructor advised that no permission was needed (D54); report text corrected.
- **B2 — Derived Spotify aggregates in the AI workspace.**
  - Files: `music_monthly.csv`, `model_frame_monthly.csv` and frozen predictions. These were copied into the AI's cloud workspace for knitting during the SOP v1 revision.
  - Raw chart CSVs were never copied.
  - Resolved by D54–D55: the complete data set is published in the repository.
- **B3 — Design-lock deviation.** The Spain design post-dates the 14 Oct lock, with no instructor approval. This is disclosed, not repaired; ask Babak or Pouria if you can before the deadline.
- No frozen output contradicts the report. No date implies a real data leak. No 2025 browsing was needed.

Pointer: the raw-to-report chain is **not** certified here. See Stage B, `Spain_TrackA_FULL_REPRODUCIBILITY_TEST_SOP_v2.md`, with its report in `reports/audit/repro/`.
