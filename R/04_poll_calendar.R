# Spain Track A - Stage R06/R07: CIS release calendar + poll-only feasibility
# Unified v4.1 - Roster locked to CIS only (D47); Nov/Dec 2022 CIS as prior inputs only (D49).
# Counts poll-only feasibility for (1) the primary WEEKLY design (Methods Sec. 3, Sec. 5)
# and (2) the pre-declared MONTHLY design FB-M (Methods Sec. 9). No music data used.
#
# Release date: official CIS "Advance date" if listed in
#   data/metadata/cis_release_dates.csv  (study_id, advance_date YYYY-MM-DD, evidence_url)
# otherwise the PDF creation date is used and marked PROVISIONAL (Methods Sec. 2:
# provisional dates cannot certify a record; they are only used to see whether
# feasibility is even reachable).
#
# Outputs
#   reports/qa/poll_feasibility_summary.txt   value-free (counts only)
#   reports/qa/poll_feasibility_origins.csv   value-free (eligibility flags)
#   data/interim/poll_calendar_monthly.csv    VALUES (git-ignored)
# Run from the project root in RStudio (Source button).

ver_path <- 'data/processed/cis_vox_verified.csv'
if (!file.exists(ver_path)) stop('Run R/03_verify_cis.R first.')
cis <- utils::read.csv(ver_path, colClasses = c(study_id = 'character'), stringsAsFactors = FALSE)
stopifnot(nrow(cis) == 24, all(cis$verified_by_eye))

# ---- 1. Release dates --------------------------------------------------------
cis$release_date <- as.Date(substr(cis$pdf_created, 1, 10))
cis$date_source <- 'PROVISIONAL_PDF_CREATED'
off_path <- 'data/metadata/cis_release_dates.csv'
if (file.exists(off_path)) {
  off <- utils::read.csv(off_path, colClasses = 'character')
  i <- match(cis$study_id, off$study_id)
  has <- !is.na(i) & nzchar(off$advance_date[i])
  cis$pdf_vs_official_days <- NA_integer_
  cis$pdf_vs_official_days[has] <- as.integer(cis$release_date[has] - as.Date(off$advance_date[i[has]]))
  cis$release_date[has] <- as.Date(off$advance_date[i[has]])
  cis$date_source[has] <- 'OFFICIAL_ADVANCE_DATE'
}
if (any(is.na(cis$release_date))) stop('Unknown release date for: ',
                                       paste(cis$study_id[is.na(cis$release_date)], collapse = ', '))
if (any(format(cis$release_date, '%Y') %in% c('2025', '2026'))) stop('Release date outside development period.')
cis <- cis[order(cis$release_date), ]
if (anyDuplicated(cis$release_date)) stop('Two CIS releases on the same date - check dedup rule.')
# Date-only precision: available from the next local midnight (Methods Sec. 3).
cis$available <- cis$release_date + 1

# ---- 2. Helpers --------------------------------------------------------------
add_months <- function(d, k) as.Date(vapply(d, function(x) {
  as.character(seq(x, by = paste(k, 'month'), length.out = 2)[2])
}, character(1)))

build <- function(origins, win_start, win_end, design) {
  rows <- lapply(seq_along(origins), function(j) {
    t <- origins[j]
    prior <- cis[cis$available <= t, ]                       # polling inputs known at t
    tgt <- cis[cis$release_date >= win_start[j] & cis$release_date < win_end[j], ]
    data.frame(
      design = design, origin = t, win_start = win_start[j], win_end = win_end[j],
      n_prior_releases = nrow(prior),
      poll_level = if (nrow(prior) >= 1) prior$vox_estimate_valid[nrow(prior)] else NA,
      poll_change = if (nrow(prior) >= 2) diff(utils::tail(prior$vox_estimate_valid, 2)) else NA,
      poll_age_days = if (nrow(prior) >= 1) as.integer(t - prior$release_date[nrow(prior)]) else NA,
      n_target_releases = nrow(tgt),
      target = if (nrow(tgt)) mean(tgt$vox_estimate_valid) else NA,
      target_mature_at = if (nrow(tgt)) max(win_end[j], max(tgt$available)) else win_end[j],
      provisional_dates_used = any(prior$date_source != 'OFFICIAL_ADVANCE_DATE') ||
                               any(tgt$date_source != 'OFFICIAL_ADVANCE_DATE'),
      stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, rows)
  out$origin <- as.Date(out$origin, origin = '1970-01-01')
  out$target_mature_at <- as.Date(out$target_mature_at, origin = '1970-01-01')
  out$features_ok <- out$n_prior_releases >= 2      # level, change, age all defined
  out$case_ok <- out$features_ok & out$n_target_releases >= 1
  q <- as.integer(format(out$origin, '%m'))
  y <- format(out$origin, '%Y')
  out$fold <- ifelse(y == '2024' & q <= 3, 'F1', ifelse(y == '2024' & q <= 6, 'F2',
              ifelse(y == '2024' & q <= 9, 'F3', ifelse(y == '2023', 'pre-F1', 'final-refit-only'))))
  out
}
dev_cutoff <- as.Date('2025-01-01')
f1_cutoff  <- as.Date('2024-01-01')

# ---- 3. Weekly design: Friday origins, target [t+28, t+35) -------------------
fridays <- seq(as.Date('2023-01-06'), as.Date('2024-12-27'), by = 'week')
wk <- build(fridays, fridays + 28, fridays + 35, 'weekly')
wk <- wk[wk$win_end <= dev_cutoff, ]
wk_train <- sum(wk$case_ok & wk$origin < f1_cutoff & wk$target_mature_at <= f1_cutoff)
wk_blocks <- sapply(c('F1', 'F2', 'F3'), function(f) sum(wk$case_ok & wk$fold == f &
                                                         wk$target_mature_at <= dev_cutoff))
wk_pass <- wk_train >= 30 && all(wk_blocks >= 8)

# ---- 4. Monthly FB-M: origin = 10th, target [t+1 month, t+2 months) ----------
tenths <- seq(as.Date('2023-01-10'), as.Date('2024-10-10'), by = 'month')
mo <- build(tenths, add_months(tenths, 1), add_months(tenths, 2), 'monthly_FBM')
mo <- mo[mo$win_end <= dev_cutoff, ]
mo_train <- sum(mo$case_ok & mo$origin < f1_cutoff & mo$target_mature_at <= f1_cutoff)
mo_blocks <- sapply(c('F1', 'F2', 'F3'), function(f) sum(mo$case_ok & mo$fold == f &
                                                         mo$target_mature_at <= dev_cutoff))
mo_pass <- mo_train >= 8 && all(mo_blocks >= 2) && sum(mo_blocks) >= 7

# Releases within 2 days of a monthly boundary (the 10th): official date decides.
day <- as.integer(format(cis$release_date, '%d'))
boundary <- cis$study_id[day >= 8 & day <= 12]

# ---- 5. Save -----------------------------------------------------------------
both <- rbind(wk, mo)
utils::write.csv(both[both$design == 'monthly_FBM', ], 'data/interim/poll_calendar_monthly.csv',
                 row.names = FALSE, na = '')
flags <- both[, c('design', 'origin', 'win_start', 'win_end', 'fold', 'n_prior_releases',
                  'n_target_releases', 'features_ok', 'case_ok', 'target_mature_at',
                  'provisional_dates_used')]
utils::write.csv(flags, 'reports/qa/poll_feasibility_origins.csv', row.names = FALSE, na = '')

missing_months <- setdiff(format(seq(as.Date('2023-01-01'), as.Date('2024-12-01'), by = 'month'), '%Y-%m'),
                          format(cis$release_date, '%Y-%m'))
summary_lines <- c(
  'Spain v4.1 - R06/R07 poll-only feasibility (roster: CIS only, D47). Counts only.',
  paste0('Release dates: ', sum(cis$date_source == 'OFFICIAL_ADVANCE_DATE'), ' official / ',
         sum(cis$date_source != 'OFFICIAL_ADVANCE_DATE'), ' provisional (PDF created)'),
  paste0('Months 2023-24 without a CIS release: ', paste(missing_months, collapse = ', ')),
  paste0('Releases within 2 days of the 10th (official date decides): ',
         if (length(boundary)) paste(boundary, collapse = ', ') else 'none'),
  '',
  paste0('WEEKLY  training pairs before F1: ', wk_train, ' (need >= 30) | blocks F1/F2/F3: ',
         paste(wk_blocks, collapse = '/'), ' (need >= 8 each) -> ', if (wk_pass) 'PASS' else 'FAIL'),
  paste0('MONTHLY training pairs before F1: ', mo_train, ' (need >= 8)  | blocks F1/F2/F3: ',
         paste(mo_blocks, collapse = '/'), ' (need >= 2 each, >= 7 total) -> ', if (mo_pass) 'PASS' else 'FAIL'),
  paste0('Monthly pre-F1 origins lost (no 2 prior releases or no target): ',
         paste(format(mo$origin[mo$fold == 'pre-F1' & !mo$case_ok], '%Y-%m-%d'), collapse = ', ')),
  '',
  paste0('Design per Methods Sec. 9 switch rule: ',
         if (wk_pass) 'WEEKLY (FB-M not used)'
         else if (mo_pass) 'FB-M MONTHLY (weekly failed; instructor confirmation of unit change required)'
         else 'STOP - both designs below floors on this roster (Sec. 8: report shortfall, no redesign)'),
  if (any(cis$date_source != 'OFFICIAL_ADVANCE_DATE'))
    'NOTE: provisional dates used - result is NOT final until official advance dates are filled in.'
)
writeLines(summary_lines, 'reports/qa/poll_feasibility_summary.txt', useBytes = TRUE)
cat('\n', paste(summary_lines, collapse = '\n'), '\n\n', sep = '')
cat('Saved: reports/qa/poll_feasibility_summary.txt, reports/qa/poll_feasibility_origins.csv,\n')
cat('       data/interim/poll_calendar_monthly.csv (values, local only)\n')
