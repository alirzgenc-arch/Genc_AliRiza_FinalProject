# Spain Track A - Stage R10/L02: FB-M model frame + feasibility floors on common cases
# Joins the monthly poll calendar (R/04) and music measure (R/06, K = 3, D51).
# Checks the pre-declared FB-M floors on ACTUAL common cases (Methods Sec. 9):
#   >= 8 mature training pairs before F1; F1-F3 >= 2 each and >= 7 total;
#   every artist measure nonconstant in the F1 training sample.
# Also asserts the leakage rules: features available at origin, targets mature
# before each training cutoff, nothing from 2025.
#
# Outputs
#   data/processed/model_frame_monthly.csv    VALUES (git-ignored)
#   reports/qa/model_frame_qa.txt             value-free (counts, TRUE/FALSE)
# Run from the project root in RStudio (Source button).

pc <- utils::read.csv('data/interim/poll_calendar_monthly.csv', stringsAsFactors = FALSE)
mu <- utils::read.csv('data/interim/music_monthly.csv', stringsAsFactors = FALSE)
keys <- c('morad', 'beny_jr', 'cyril_kamer')
stopifnot(setequal(unique(mu$artist_key), keys))

for (v in c('origin', 'win_start', 'win_end', 'target_mature_at')) pc[[v]] <- as.Date(pc[[v]])
mu$origin <- as.Date(mu$origin)

# Wide music table: one column per artist.
wide <- stats::reshape(mu[, c('origin', 'artist_key', 'x_log1p_mean_streams')],
                       idvar = 'origin', timevar = 'artist_key', direction = 'wide')
names(wide) <- sub('x_log1p_mean_streams\\.', 'music_', names(wide))
mf <- merge(pc, wide, by = 'origin', all.x = TRUE)
mf <- mf[order(mf$origin), ]
music_cols <- paste0('music_', keys)
poll_cols <- c('poll_level', 'poll_change', 'poll_age_days')

# ---- Leakage / boundary assertions (L02) ------------------------------------
stopifnot(all(mf$win_end <= as.Date('2025-01-01')),
          all(format(mf$origin, '%Y') %in% c('2023', '2024')),
          all(mf$poll_age_days[!is.na(mf$poll_age_days)] >= 1))   # latest poll strictly before origin
mf$common_case <- mf$case_ok & stats::complete.cases(mf[, c(poll_cols, music_cols, 'target')])

f1_cut <- as.Date('2024-01-01'); dev_cut <- as.Date('2025-01-01')
train_f1 <- mf$common_case & mf$origin < f1_cut & mf$target_mature_at <= f1_cut
blocks <- sapply(c('F1', 'F2', 'F3'), function(f) sum(mf$common_case & mf$fold == f &
                                                      mf$target_mature_at <= dev_cut))
nonconst <- sapply(music_cols, function(v) stats::sd(mf[[v]][train_f1]) > 0)
floor_ok <- sum(train_f1) >= 8 && all(blocks >= 2) && sum(blocks) >= 7 && all(nonconst)

dir.create('data/processed', showWarnings = FALSE)
utils::write.csv(mf, 'data/processed/model_frame_monthly.csv', row.names = FALSE, na = '')

lines <- c(
  'Spain v4.1 - FB-M model frame (K = 3, D51). Counts and flags only.',
  paste0('Origins: ', nrow(mf), ' (', format(min(mf$origin)), ' .. ', format(max(mf$origin)), ')'),
  paste0('Common cases (polls + 3 music + target): ', sum(mf$common_case)),
  paste0('F1 training pairs (mature before 2024-01-01): ', sum(train_f1), ' (need >= 8)'),
  paste0('Validation blocks F1/F2/F3: ', paste(blocks, collapse = '/'), ' (need >= 2 each, >= 7 total)'),
  paste0('Music nonconstant in F1 training: ',
         paste(sub('music_', '', names(nonconst)), nonconst, sep = '=', collapse = ', ')),
  paste0('Leakage assertions: PASSED'),
  paste0('FB-M floors on common cases: ', if (floor_ok) 'PASS' else 'FAIL -> STOP (Sec. 8)')
)
writeLines(lines, 'reports/qa/model_frame_qa.txt')
cat('\n', paste(lines, collapse = '\n'), '\n\n', sep = '')
cat('Saved: data/processed/model_frame_monthly.csv (local), reports/qa/model_frame_qa.txt\n')
