# Spain Track A - dated amendments (Methods Sec. 8 format)

## D47 - Source roster locked to CIS only
- Date/time: 2026-10-29 16:30 Europe/Amsterdam (= Madrid time)
- Approved by: student (Ali Riza Genc), in chat with Claude
- Previous rule: roster to be locked after screening the D40 universe (12 pollsters + ElectoPanel), Methods Sec. 2.
- New rule: `source_roster_lock` = {CIS}. No other pollster is screened or admitted for this submission.
- Reason / evidence: course deadline (Guide: 30 Oct 2026 17:00) leaves no time for first-release/vintage and permission audits of 12 sources; CIS PDFs are already inventoried, hash-locked and verified (22/22, R05).
- Exposure: no other pollster's 2023-24 values were inspected; no 2025 values inspected.
- Outcomes/scores already inspected: CIS Vox values were seen only during extraction/verification (R04-R05); no feasibility count, music feature or model output existed when this was decided.
- Consequence: weekly design is expected to fail the poll-only floors (one release per month); Methods Sec. 9 switch rule then applies. Instructor confirmation of a monthly unit is requested.
- Affected artifacts: R/04_poll_calendar.R, Rmd Sec. 1 (data), "What I do not trust".

## D48 - Monthly music measure (c) built from weekly charts (only used if FB-M applies)
- Date/time: 2026-10-29 16:30 Europe/Amsterdam
- Approved by: student
- Previous rule: FB-M allows only (a) daily Spotify Spain Top 200 summed over month m-1, or (b) a documented Spotify monthly figure.
- New rule: measure (c). For an origin on the 10th of month m and artist a:
  `x_a = log1p( mean over all weekly Spotify Spain Top 200 charts whose week-end date (Thursday, from the file name) falls in calendar month m-1 of the summed streams of every charted track whose artist_names list contains a )`.
  - Mean, not sum, so 4- and 5-week months are comparable.
  - Full track streams are credited to each credited artist (same credit rule as measure (a)).
  - Artist matching: exact name after splitting `artist_names` on ", " (case-insensitive); aliases only after the A02-A05 artist-ID review.
  - Artist not in a week's Top 200 = 0 charted streams that week (construct is *charted* streams); a missing or failed chart file = NA for that month (no fill).
  - Availability: last qualifying week ends <= last day of m-1; with the D42 d+8 convention it is available by the 8th of m, before the origin on the 10th.
- Reason / evidence: daily charts are not held; the 104 weekly files for 2023-24 are inventoried and complete (R02, 104/104 weeks).
- Exposure: chart files were opened only for header/row-count checks; no artist rows or stream values have been looked at or computed.
- Recorded before any music feature was computed, as Methods Sec. 9 requires.
- Affected artifacts: future R/05_music_features.R, Rmd Sec. 1-2.

## D49 - Nov and Dec 2022 data added as prior inputs only
- Date/time: 2026-10-29 16:40 Europe/Amsterdam
- Approved by: student
- Previous rule: development CIS corpus = 22 barometers 2023-24; Spotify files 2023-24.
- New rule: add CIS barometers 3384 (Nov 2022) and 3388 (Dec 2022), Estimacion PDFs, and the five Spotify Spain weekly charts ending 2022-12-01 ... 2022-12-29. They are used ONLY as information available at the first origins (polling level/change/age; December 2022 music for the 10 Jan 2023 origin). They are never targets; origins still start 10 Jan 2023; folds, floors and the 2025 boundary are unchanged.
- Reason / evidence: Methods Sec. 9 already states that the 10 Jan 2023 origin "needs December 2022 music and two prior poll groups". Without them the Jan and Feb 2023 origins cannot have polling inputs.
- Timing: decided BEFORE R/04_poll_calendar.R was run on the real data, i.e. before any feasibility count, music feature or model output was seen. Not chosen to make a floor pass.
- Exposure: pre-2025 public material only; no 2025 values inspected.
- Possible objection (reported in "What I do not trust"): Methods Sec. 5 forbids "extending years to pass"; this adds no target years, only the prior inputs the contract itself requires.
- Affected artifacts: R/00_inventory.R, R/02_extract_cis.R, R/03_verify_cis.R, R/04_poll_calendar.R, Rmd load-data chunk.

## D50 - Proceed with FB-M without waiting for instructor confirmation
- Date/time: 2026-10-29 17:02 Europe/Amsterdam
- Approved by: student
- Previous rule: Methods Sec. 8/9 request instructor confirmation of the monthly unit change.
- New rule: the student decides to proceed without that confirmation. The switch itself follows the pre-declared rule (R07 poll-only counts: weekly 10 < 30 FAIL; FB-M 9 >= 8, blocks 3/3/2 PASS, all 24 release dates official).
- Risk: the instructor may not accept the monthly unit; disclosed in the report.
- Outcomes/scores inspected: none (no music feature or model output existed).

## D51 - Artist set reduced from K = 5 to K = 3
- Date/time: 2026-10-29 17:08 Europe/Amsterdam
- Approved by: student
- Previous rule: K = 5 fixed (Morad, Beny Jr, Delarue, Moha The B, Cyril Kamer); Methods Sec. 8: "no smaller artist set" if floors fail.
- New rule: K = 3 (Morad, Beny Jr, Cyril Kamer). M2 = 3 polling + 3 music inputs = 6.
- Evidence: R/05_artist_audit.R (reports/qa/artist_name_audit.csv): Delarue and Moha The B appear in 0 of 109 weekly Spain Top 200 charts (Dec 2022 - Dec 2024). Under measure (c) their value is 0 in every month, so the floor "all artist measures nonconstant in F1 training" cannot hold for them.
- Spelling decisions (data/metadata/artist_aliases.csv): "benny blanco" and "CYRIL" excluded as different artists, by identity only.
- Basis: chart presence only. No music value was computed, no model was fitted, and no relation between any artist and Vox was looked at.
- Disclosure: this departs from the student's own pre-registered stop rule; reported in "What I do not trust" (the question is narrower than planned: three of five scene artists, the two smallest dropped because they are not measurable with charted streams).

## D52 - 2025 opened as a disclosed exploratory out-of-time evaluation
- Date/time: 2026-10-29 17:49 Europe/Amsterdam
- Approved by: student (explicit release instruction)
- Previous rule: Methods Sec. 7 - 2025 stays segregated until DESIGN_FREEZE and FIT_AND_CODE_FREEZE, plus documented rights, isolation QA, student release instruction and instructor guidance.
- New rule: 2025 opened after FIT_AND_CODE_FREEZE (reports/results/fit_freeze_manifest.txt) on the student's instruction, WITHOUT instructor guidance (see D50). Reported as "disclosed exploratory out-of-time evaluation". Prior Italian/Spanish 2025 textual exposure is disclosed; no pristine-holdout claim.
- Procedure: R/09_prepare_2025.R verifies the freeze, inventories 2025 files and extracts CIS values with the same rule; every 2025 value is verified by eye; R/10_score_2025.R applies the frozen models once (lock file prevents re-scoring after any change). Origins 10 Jan - 10 Oct 2025; no window crosses into 2026.
- 2025 release dates: official CIS notices (data/metadata/cis_release_dates_2025.csv). Dec 2025 barometer (3536) released 12 Dec 2025 (press), after the last window closes on 10 Dec, so not needed.
- Outcomes/scores inspected before this decision: development forward-validation metrics only; no 2025 value.

## D53 - Historical record: Italy-to-Spain restart (recorded 29 Oct 2026, ~20:20; NOT a backdated decision)
- Recorded by: Claude, from the student's account and existing project records; student confirmation of details pending.
- What the records show:
  - 14 Oct 2026 (course design-settlement date): the student's hand-written in-class Assignment 4 (graded) states an **Italy** design: streaming trends of migration-origin Italian rappers to improve four-week-ahead forecasts of Fratelli d'Italia's national polling support, test period 2025.
  - Later (exact date not recorded in any project file): the student reports accidentally giving an AI tool access to Italian material intended for training and testing. Project records (`FINAL_RISK_AND_EXPOSURE.md`, ID IT-LEGACY) note "prior 2025 outcome exposure in the Italy project; details not reconstructed". The student's account that at least one late-2025 Italian Spotify chart was exposed is **not independently documented** in the files available.
  - No Italian model had been fitted according to the records. The student abandoned the Italy design as a precaution and restarted with Spain; the Spain five-artist roster is dated 28 Oct 2026 (decision D13).
- Consequences: the 14 Oct design-lock requirement was not met for the Spain design; no instructor approval of the late change is on file. The Italy incident is researcher/AI exposure for the Italian project, not demonstrated machine-learning leakage, and it does not make later Spain work pristine.

## E06 - AI-side search-result exposure during this R session (recorded 29 Oct 2026, ~20:20)
- While collecting official CIS release dates (≈16:45–17:00, before any model fit) and 2025 release dates (≈17:50–18:05, after the 17:38 freeze and before the 18:10 scoring lock), web-search result **titles** shown to the assistant included Spanish political headlines dated 2025–2026 (mostly PSOE–PP margins; at least one 2026 headline about Vox's level). Page fetches were restricted to release dates; no Vox value was requested, copied or used for any decision.
- Risk class: researcher/AI test exposure (low). No design, roster, feature, tuning or scoring change followed.

## D54 - Spotify permission status corrected (recorded 29 Oct 2026, ~20:40; NOT backdated)
- The instructor advised that no permission was needed to use the Spotify weekly charts for this course project, so no permission document is archived.
- This supersedes D37 ("rights also solved, I got an email"); no such email exists.
- The protocol (contract §8) asked for an archived permission before music features were built (17:10); that step was not done and is made unnecessary by the instructor's advice. The report's data statement was updated.

## D55 - Raw data published with the code (recorded 30 Oct 2026, ~15:35; NOT backdated)
- Student decision: the complete project, including the raw Spotify weekly chart CSVs (development and 2025 quarantine) and all derived files, is published in a public GitHub repository so that the report can be reproduced from raw inputs, following the instructor's advice (D54).
- Report text updated accordingly (data statement, Limitation 3, reproducibility note). No data, model or result changed.
