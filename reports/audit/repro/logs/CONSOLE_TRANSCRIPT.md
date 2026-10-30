# Console output of the Stage B runs (VM on the student's Mac, 29 Oct 2026 ≈20:33–20:47 CET)

Transcribed verbatim from the tool output returned to the AI. The raw log files remain in the VM test folder
(`$HOME/Spain_TrackA_repro_test/logs/`, removed with the session). All output is value-free by script design.

## Environment
R version 4.5.3 (2026-03-11) | rmarkdown 2.32 | knitr 1.52 | digest 0.6.39 | pdftools 3.9.1 | glmnet 5.0 | pandoc 3.13 (render) | poppler 26.07.0 | OpenBLAS 0.3.34 | Ubuntu 22.04.5 aarch64 | TZ Europe/Amsterdam (set) | C.UTF-8

## L1 render
[WARNING] Deprecated: --mathjax. Use --math-method=mathjax[:URL] instead.
R-level warnings captured: 0 | pandoc used: 3.13 | exit=0 | L1_render.html 1,154,324 bytes | "All six checks passed": present | images 1 | rtables 6
Text diff vs project HTML: 496 vs 496 lines; 4 differing lines = 2 syntax-highlight tokenisations of `1e-8` / `1e-10` in shown code.

## L2 (L2_integrity.R, in full/)
L2-hash-fit_freeze_manifest.txt  4 match; 0 missing                PASS
L2-paths-fit_freeze_manifest.txt 0 bad paths                       PASS
L2-hash-test2025_lock.txt        10 match; 0 missing               PASS
L2-paths-test2025_lock.txt       0 bad paths                       PASS
L2-parse-space                   4 fields (naive); robust parser path = 'data/raw/some folder/file name.csv'   FAIL (old parser; fixed in Rmd)
L2-refit-pred                    40 rows; keys equal=TRUE; max diff=4.97e-14; other cols identical=TRUE   PASS
L2-refit-lambda                  4 rows; keys equal=TRUE; max diff=0; other cols identical=TRUE           PASS
L2-refit-metrics                 5 rows; keys equal=TRUE; max diff=9.99e-15; other cols identical=TRUE    PASS
L2-refit-coef                    22 rows; keys equal=TRUE; max diff=1.02e-14; other cols identical=TRUE   PASS
L2-refit-rds                     TRUE | grid TRUE                  PASS
L2-refit-bytes                   differs (numeric check above decides)   PASS (informative)
L2-metrics-2024                  5 matched; max diff=1.71e-14; same cases=TRUE   PASS
L2-metrics-2025                  5 matched; max diff=2.75e-14; same cases=TRUE   PASS
L2-no-rescore                    R/10 not sourced; predictions only read          PASS
(Same 13 PASS / 1 FAIL pattern reproduced in the AI cloud workspace, R 4.3.3 / glmnet 4.1.8.)

## L3 (raw/): R/00 -> R/07, all exit 0
00: CIS PDFs 24 | IDs 24/24 | Spotify CSVs 109 | weeks 109/109 | issues 0
02: 24 earlier checks kept, 0 rows need checking | EXTRACTED_UNVERIFIED 23, _INTEGER 1
03: verification PASSED | 24/24 | raw PDFs unchanged 24/24 | 2022=2, 2023=11, 2024=11
04: 24 official dates | WEEKLY 10 (need >= 30) 3/3/2 FAIL | MONTHLY 9 (need >= 8) 3/3/2 PASS | lost pre-F1 origin 2023-07-10
05: 109 files | Morad 109, Beny Jr 101, Cyril Kamer 74; 'benny blanco' 10, 'CYRIL' 13 (excluded by alias file); no spelling: delarue, moha_the_b
06: months 22 | artists 3 | NA 0 | all-absent months: cyril_kamer 3
07: origins 22 | common 20 | F1 train 9 | blocks 3/3/2 | music nonconstant TRUE x3 | leakage assertions PASSED | floors PASS

## L3 compare (L3_compare.py raw vs full)
byte-identical: cis_raw_inventory, music_file_inventory, missing_and_duplicates, cis_vox_extracted, cis_extraction_qa,
cis_vox_manual_check, poll_calendar_monthly, poll_feasibility_origins, poll_feasibility_summary.txt, artist_name_audit,
music_monthly, music_feature_qa, model_frame_monthly, model_frame_qa.txt
cis_vox_verified.csv: rows 24 vs 24; keys equal; cols equal; differing cells only in verified_check_sheet_mtime (24)

## L3 date checks (L3_date_checks.R)
origin_on_10th TRUE | win_start_10th_m1 TRUE | win_end_10th_m2 TRUE | mature_after_window TRUE | poll_age_ge_1_day TRUE
n_prior_releases_match TRUE | n_target_releases_match TRUE | august_windows_empty TRUE | dropped_cases 2023-07,2024-07
music_month_is_m_minus_1 TRUE | music_available_by_origin TRUE | music_complete_and_not_na TRUE | music_origins_match_frame TRUE | target_not_in_predictors TRUE
Boundary: 3423 2023-10-18, 3427 2023-11-10, 3431 2023-12-21; origin 2023-10-10: prior 10, target 1 (=3427); origin 2023-11-10: prior 11 (3427 excluded), target 1

## Fault tests
mutant (regional-es-weekly-2023-03-16.csv removed): 00 -> 108/109 weeks, issues 1 | 06 exit 0 | NA cells 3 (2023-03) | zero substituted FALSE | 07 common 19 | leakage PASSED
subst (rebuilt cis_vox_verified.csv swapped into full copy): knit stops at check 5: all(vapply(lock[, 1], sha, "") == lock[, 2]) is not TRUE

## Pre/post snapshot of the original project
245 files (excluding .Rproj.user, reports/audit/repro, .DS_Store): PRE/POST IDENTICAL
