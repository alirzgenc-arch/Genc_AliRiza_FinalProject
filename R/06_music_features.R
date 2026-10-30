# Spain Track A - Stage R10/A06: monthly music measure (c), amendment D48
# For origin = 10th of month m and artist a:
#   x_a = log1p( mean over weekly Spain Top 200 charts whose week-end date falls in
#                month m-1 of the summed streams of every charted track crediting a )
# - full track streams credited to each credited artist
# - artist absent from a week's chart = 0 charted streams that week
# - missing chart file in month m-1 = NA for that month (no fill)
# - availability: week end + 8 days (D42) must be <= origin
# Spellings come ONLY from data/metadata/artist_aliases.csv (include == yes),
# confirmed by the student before this script is run.
#
# Outputs
#   data/interim/music_monthly.csv            VALUES (git-ignored)
#   reports/qa/music_feature_qa.csv           value-free: weeks used, zero weeks, NA flags
# Run from the project root in RStudio (Source button).

alias_path <- 'data/metadata/artist_aliases.csv'
if (!file.exists(alias_path)) stop('Confirm spellings first: create ', alias_path,
                                   ' from artist_aliases_TEMPLATE.csv (include = yes).')
al <- utils::read.csv(alias_path, stringsAsFactors = FALSE, fileEncoding = 'UTF-8')
al <- al[tolower(trimws(al$include)) == 'yes', ]
# D51: Delarue and Moha The B never entered the Spain weekly Top 200 (0/109 weeks);
# the measure cannot vary for them, so K = 3.
keys <- c('morad', 'beny_jr', 'cyril_kamer')
if (!all(keys %in% al$artist_key)) stop('No confirmed spelling for: ',
                                        paste(setdiff(keys, al$artist_key), collapse = ', '))
if (anyDuplicated(tolower(al$exact_spelling))) stop('A spelling is assigned to two artists.')

music_dir <- 'data/raw/music_dev/spotify_weekly_es'
files <- list.files(music_dir, pattern = '\\.csv$', recursive = TRUE, full.names = TRUE)
files <- files[!grepl('20(25|26|27)', files)]
week_end <- as.Date(regmatches(basename(files), regexpr('20[0-9]{2}-[0-9]{2}-[0-9]{2}', basename(files))))
ok <- week_end >= as.Date('2022-12-01') & week_end <= as.Date('2024-12-26')
files <- files[ok]; week_end <- week_end[ok]
inv <- utils::read.csv('reports/qa/music_file_inventory.csv', stringsAsFactors = FALSE)

# Weekly charted streams per artist (one row per file x artist).
weekly <- do.call(rbind, lapply(seq_along(files), function(i) {
  rec <- inv[inv$relative_path == files[i], ]
  sha <- digest::digest(file = files[i], algo = 'sha256')
  if (nrow(rec) != 1 || !identical(sha, rec$sha256) || rec$inventory_status != 'HEADER_AND_ROWCOUNT_OK') {
    return(data.frame(week_end = week_end[i], artist_key = keys, streams = NA_real_, file_ok = FALSE))
  }
  d <- utils::read.csv(files[i], stringsAsFactors = FALSE, check.names = FALSE, fileEncoding = 'UTF-8-BOM')
  names(d) <- tolower(names(d))
  d$streams <- as.numeric(gsub('[^0-9]', '', d$streams))
  credited <- strsplit(d$artist_names, ', ', fixed = TRUE)
  s <- vapply(keys, function(k) {
    sp <- tolower(al$exact_spelling[al$artist_key == k])
    hit <- vapply(credited, function(cr) any(tolower(trimws(cr)) %in% sp), logical(1))
    sum(d$streams[hit])                       # 0 if not charted this week
  }, numeric(1))
  data.frame(week_end = week_end[i], artist_key = keys, streams = s, file_ok = TRUE)
}))

# Monthly measure for months m-1 = Dec 2022 ... Sep 2024 (origins 10 Jan 2023 ... 10 Oct 2024).
months <- seq(as.Date('2022-12-01'), as.Date('2024-09-01'), by = 'month')
weekly$month <- format(weekly$week_end, '%Y-%m')
res <- do.call(rbind, lapply(months, function(m1) {
  mm <- format(m1, '%Y-%m')
  origin <- seq(m1, by = '1 month', length.out = 2)[2] + 9          # 10th of month m
  w <- weekly[weekly$month == mm, ]
  expected_weeks <- sum(format(seq(m1, by = 'day', length.out = 31), '%Y-%m') == mm &
                        format(seq(m1, by = 'day', length.out = 31), '%u') == '4')
  do.call(rbind, lapply(keys, function(k) {
    wk <- w[w$artist_key == k, ]
    complete <- nrow(wk) == expected_weeks && all(wk$file_ok)
    avail_ok <- nrow(wk) > 0 && max(wk$week_end) + 8 <= origin
    data.frame(month_m1 = mm, origin = origin, artist_key = k,
               weeks_expected = expected_weeks, weeks_used = nrow(wk),
               weeks_zero = sum(wk$streams == 0, na.rm = TRUE),
               complete = complete, available_by_origin = avail_ok,
               x_log1p_mean_streams = if (complete && avail_ok) log1p(mean(wk$streams)) else NA_real_,
               stringsAsFactors = FALSE)
  }))
}))
if (any(!res$available_by_origin)) stop('A music value would be unavailable at its origin.')

utils::write.csv(res, 'data/interim/music_monthly.csv', row.names = FALSE, na = '')
qa <- res[, c('month_m1', 'origin', 'artist_key', 'weeks_expected', 'weeks_used',
              'weeks_zero', 'complete', 'available_by_origin')]
qa$value_is_na <- is.na(res$x_log1p_mean_streams)
utils::write.csv(qa, 'reports/qa/music_feature_qa.csv', row.names = FALSE)

cat('\nSpain v4.1 - music measure (c) built (values saved locally, NOT printed).\n')
cat('Months:', length(months), '| artists:', length(keys), '| NA values:', sum(qa$value_is_na), '\n')
tab <- tapply(qa$weeks_zero == qa$weeks_used, qa$artist_key, sum)
cat('Months with the artist absent from every weekly chart (value = log1p(0) = 0):\n')
print(tab)
cat('Saved: data/interim/music_monthly.csv (local), reports/qa/music_feature_qa.csv (value-free)\n')
