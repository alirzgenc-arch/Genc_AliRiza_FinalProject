# Spain Track A - Stage R12: ONE combined scoring batch on 2025 (exploratory, D52)
# Frozen models from data/processed/fit_freeze.rds are applied unchanged.
# Nothing is re-fitted, re-tuned or re-scaled. 2025 polls enter only as later-origin
# history inputs and as targets (Methods Sec. 7).
#   Origins: 10th of Jan ... Oct 2025; target window [t + 1 month, t + 2 months);
#   no window crosses into 2026.
# Re-running is allowed only as exact reproduction: if results exist and any input
# changed, the script stops (no iterative improvement against 2025 scores).
# Outputs
#   reports/results/test2025_metrics.csv            MAE / RMSE / bias (pp)
#   data/quarantine/test_2025/work/test2025_predictions.csv   (values)
#   reports/results/test2025_lock.txt               input hashes of the scoring batch
# Run from the project root in RStudio (Source button).

for (p in c('digest')) if (!requireNamespace(p, quietly = TRUE)) stop("Package '", p, "' missing.")
q <- 'data/quarantine/test_2025'; work <- file.path(q, 'work')
hash <- function(f) digest::digest(file = f, algo = 'sha256')

# ---- 0. Freeze + label verification -------------------------------------------
man <- readLines('reports/results/fit_freeze_manifest.txt')[-(1:2)]
parts <- do.call(rbind, strsplit(man, ' '))
if (!all(vapply(parts[, 1], hash, character(1)) == parts[, 2])) stop('FREEZE BROKEN - do not score.')
ex  <- utils::read.csv(file.path(work, 'cis2025_extracted.csv'), colClasses = c(study_id = 'character'))
chk <- utils::read.csv(file.path(work, 'cis2025_manual_check.csv'), colClasses = 'character')
if (any(toupper(trimws(chk$check)) != 'OK')) stop('2025 values not all verified (check = OK).')
if (any(abs(as.numeric(chk$vox_estimate_valid) - ex$vox_estimate_valid[match(chk$study_id, ex$study_id)]) > 1e-9))
  stop('Check sheet values differ from extraction.')
if (!all(grepl('^EXTRACTED_UNVERIFIED', ex$status))) stop('2025 extraction has REVIEW rows.')
rd_path <- 'data/metadata/cis_release_dates_2025.csv'
if (!file.exists(rd_path)) stop('Missing official 2025 release dates: ', rd_path)

# ---- 1. Combined CIS series (dev verified + 2025 verified), official dates -------------
dev <- utils::read.csv('data/processed/cis_vox_verified.csv', colClasses = c(study_id = 'character'))
rd_dev <- utils::read.csv('data/metadata/cis_release_dates.csv', colClasses = 'character')
rd_25  <- utils::read.csv(rd_path, colClasses = 'character')
dev$release_date <- as.Date(rd_dev$advance_date[match(dev$study_id, rd_dev$study_id)])
ex$release_date  <- as.Date(rd_25$advance_date[match(ex$study_id, rd_25$study_id)])
if (any(is.na(dev$release_date)) || any(is.na(ex$release_date))) stop('Missing official release date(s).')
cis <- rbind(dev[, c('study_id', 'release_date', 'vox_estimate_valid')],
             ex[, c('study_id', 'release_date', 'vox_estimate_valid')])
cis <- cis[order(cis$release_date), ]
if (anyDuplicated(cis$release_date)) stop('Two releases on one date.')
cis$available <- cis$release_date + 1

origins <- seq(as.Date('2025-01-10'), as.Date('2025-10-10'), by = 'month')
nextm <- function(d, k) as.Date(vapply(d, function(x) as.character(seq(x, by = paste(k, 'month'), length.out = 2)[2]), ''))
ev <- data.frame(origin = origins, win_start = nextm(origins, 1), win_end = nextm(origins, 2))
stopifnot(all(ev$win_end <= as.Date('2026-01-01')))
for (j in seq_len(nrow(ev))) {
  t <- ev$origin[j]; prior <- cis[cis$available <= t, ]
  tgt <- cis[cis$release_date >= ev$win_start[j] & cis$release_date < ev$win_end[j], ]
  ev$poll_level[j]    <- utils::tail(prior$vox_estimate_valid, 1)
  ev$poll_change[j]   <- diff(utils::tail(prior$vox_estimate_valid, 2))
  ev$poll_age_days[j] <- as.integer(t - utils::tail(prior$release_date, 1))   # same as R/04
  ev$n_target[j]      <- nrow(tgt)
  ev$target[j]        <- if (nrow(tgt)) mean(tgt$vox_estimate_valid) else NA
}

# ---- 2. Music measure (c), identical rule to R/06 -------------------------------------
al <- utils::read.csv('data/metadata/artist_aliases.csv', stringsAsFactors = FALSE, fileEncoding = 'UTF-8')
al <- al[tolower(trimws(al$include)) == 'yes', ]
keys <- c('morad', 'beny_jr', 'cyril_kamer')
dev_files <- list.files('data/raw/music_dev/spotify_weekly_es', pattern = '\\.csv$', recursive = TRUE, full.names = TRUE)
dev_files <- dev_files[grepl('2024-12-', basename(dev_files))]                      # Dec 2024 for the Jan origin
files <- c(dev_files, list.files(file.path(q, 'spotify'), pattern = '\\.csv$', full.names = TRUE))
wk_end <- as.Date(regmatches(basename(files), regexpr('20[0-9]{2}-[0-9]{2}-[0-9]{2}', basename(files))))
inv25 <- utils::read.csv(file.path(work, 'spotify2025_inventory.csv'), stringsAsFactors = FALSE)
weekly <- do.call(rbind, lapply(seq_along(files), function(i) {
  ok <- grepl('music_dev', files[i]) ||
        isTRUE(inv25$status[match(basename(files[i]), inv25$file)] == 'HEADER_AND_ROWCOUNT_OK' &&
               inv25$sha256[match(basename(files[i]), inv25$file)] == hash(files[i]))
  if (!ok) return(data.frame(week_end = wk_end[i], artist_key = keys, streams = NA_real_, file_ok = FALSE))
  d <- utils::read.csv(files[i], stringsAsFactors = FALSE, check.names = FALSE, fileEncoding = 'UTF-8-BOM')
  names(d) <- tolower(names(d)); d$streams <- as.numeric(gsub('[^0-9]', '', d$streams))
  cr <- strsplit(d$artist_names, ', ', fixed = TRUE)
  s <- vapply(keys, function(k) {
    sp <- tolower(al$exact_spelling[al$artist_key == k])
    sum(d$streams[vapply(cr, function(x) any(tolower(trimws(x)) %in% sp), logical(1))])
  }, numeric(1))
  data.frame(week_end = wk_end[i], artist_key = keys, streams = s, file_ok = TRUE)
}))
weekly$month <- format(weekly$week_end, '%Y-%m')
for (k in keys) ev[[paste0('music_', k)]] <- NA_real_
for (j in seq_len(nrow(ev))) {
  m1 <- seq(ev$origin[j] - 9, by = '-1 month', length.out = 2)[2]               # 1st of month m-1
  mm <- format(m1, '%Y-%m')
  days <- seq(m1, by = 'day', length.out = 31)
  n_exp <- sum(format(days, '%Y-%m') == mm & format(days, '%u') == '4')
  for (k in keys) {
    w <- weekly[weekly$month == mm & weekly$artist_key == k, ]
    if (nrow(w) == n_exp && all(w$file_ok) && max(w$week_end) + 8 <= ev$origin[j])
      ev[j, paste0('music_', k)] <- log1p(mean(w$streams))
  }
}

# ---- 3. Score once with the frozen models ------------------------------------------
fz <- readRDS('data/processed/fit_freeze.rds')
music_x <- paste0('music_', keys)
ev$common_case <- stats::complete.cases(ev[, c('poll_level', 'poll_change', 'poll_age_days', music_x, 'target')])
cs <- ev[ev$common_case, ]
pred_frozen <- function(f, d) {
  m <- f$model; idx <- which(fz$grid == f$lambda); stopifnot(length(idx) == 1)
  X <- scale(as.matrix(d[m$use]), center = m$s$xm[m$use], scale = m$s$xs[m$use])
  as.vector(cbind(1, X) %*% m$B[, idx]) * m$s$ys + m$s$ym
}
pr <- list(data.frame(design = 'Baseline', model = 'M0', origin = cs$origin, observed = cs$target,
                      prediction = cs$poll_level))
for (nm in names(fz$finals)) {
  sp <- strsplit(nm, ' ')[[1]]
  pr[[length(pr) + 1]] <- data.frame(design = sp[1], model = sp[2], origin = cs$origin,
                                     observed = cs$target, prediction = pred_frozen(fz$finals[[nm]], cs))
}
pr <- do.call(rbind, pr)
score <- function(d) data.frame(design = d$design[1], model = d$model[1], n = nrow(d),
  MAE = mean(abs(d$prediction - d$observed)), RMSE = sqrt(mean((d$prediction - d$observed)^2)),
  bias = mean(d$prediction - d$observed))
met <- do.call(rbind, lapply(split(pr, list(pr$design, pr$model), drop = TRUE), score))
met <- met[order(met$design, met$model), ]
dmae <- function(dn) met$MAE[met$design == dn & met$model == 'M2'] - met$MAE[met$design == dn & met$model == 'M1']

# ---- 4. Single-batch lock -------------------------------------------------------------
inputs <- c(parts[, 1], 'data/processed/cis_vox_verified.csv', file.path(work, 'cis2025_extracted.csv'),
            rd_path, 'data/metadata/artist_aliases.csv', file.path(work, 'spotify2025_inventory.csv'),
            'R/10_score_2025.R')
lock <- paste(inputs, vapply(inputs, hash, character(1)))
lock_path <- 'reports/results/test2025_lock.txt'
if (file.exists(lock_path) && !identical(readLines(lock_path)[-1], lock))
  stop('2025 was already scored with different inputs/code. Re-scoring after changes is not allowed (Sec. 7).')
if (!file.exists(lock_path)) writeLines(c(paste('2025 scoring batch -', format(Sys.time(), '%Y-%m-%d %H:%M %Z')), lock), lock_path)

utils::write.csv(met, 'reports/results/test2025_metrics.csv', row.names = FALSE)
utils::write.csv(pr, file.path(work, 'test2025_predictions.csv'), row.names = FALSE)
utils::write.csv(ev[, c('origin', 'n_target', 'common_case')], 'reports/qa/test2025_cases.csv', row.names = FALSE)

cat('\nSpain v4.1 - 2025 EXPLORATORY out-of-time evaluation (frozen models, one batch)\n')
cat('Origins 2025:', nrow(ev), '| scored common cases:', nrow(cs),
    '| lost (no target / missing input):', paste(format(ev$origin[!ev$common_case], '%Y-%m'), collapse = ', '), '\n\n')
print(met, row.names = FALSE, digits = 3)
cat('\nDelta MAE (M2 - M1), Ridge:           ', round(dmae('Ridge'), 3), ' (negative favors music)\n')
cat('Delta MAE (M2 - M1), Elastic Net check:', round(dmae('ElasticNet_check'), 3), '\n')
cat('Out-of-range predictions:', sum(pr$prediction < 0 | pr$prediction > 100), '\n')
