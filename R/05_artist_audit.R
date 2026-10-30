# Spain Track A - Stage A02-A05: artist-name audit in the Spotify weekly charts
# Unified v4.1 - VALUE-FREE: lists every credited-artist spelling that looks like
# one of the five fixed artists, with the number of chart weeks it appears in.
# No stream numbers are read into the output. The student then confirms the
# exact spellings in data/metadata/artist_aliases.csv (decision recorded BEFORE
# any music feature is computed; never chosen by relation to Vox).
#
# Output: reports/qa/artist_name_audit.csv  (git-safe)
#         data/metadata/artist_aliases_TEMPLATE.csv  (for the student to confirm)
# Run from the project root in RStudio (Source button).

music_dir <- 'data/raw/music_dev/spotify_weekly_es'
files <- list.files(music_dir, pattern = '\\.csv$', recursive = TRUE, full.names = TRUE)
files <- files[!grepl('20(25|26|27)', files)]                 # never open 2025+
week_end <- regmatches(basename(files), regexpr('20[0-9]{2}-[0-9]{2}-[0-9]{2}', basename(files)))
stopifnot(length(week_end) == length(files))
keep <- as.Date(week_end) >= as.Date('2022-12-01') & as.Date(week_end) <= as.Date('2024-12-26')
files <- files[keep]; week_end <- week_end[keep]
cat('Weekly chart files read:', length(files), '(expected 109)\n')

# Fixed sample (Methods, D-lock #3). Search keys are deliberately broad so that
# variants show up; the student decides which spellings are the same artist.
artists <- c(morad = 'morad', beny_jr = 'beny|benny', delarue = 'delarue',
             moha_the_b = 'moha', cyril_kamer = 'cyril|kamer')
norm <- function(x) {
  x <- iconv(x, from = 'UTF-8', to = 'ASCII//TRANSLIT', sub = '')
  gsub('[^a-z0-9]', '', tolower(x))
}

rows <- list()
for (i in seq_along(files)) {
  d <- utils::read.csv(files[i], stringsAsFactors = FALSE, check.names = FALSE,
                       fileEncoding = 'UTF-8-BOM')
  names(d) <- tolower(names(d))
  if (!'artist_names' %in% names(d)) stop('No artist_names column in ', files[i])
  credited <- unlist(strsplit(d$artist_names, ', ', fixed = TRUE))
  credited <- unique(trimws(credited))
  for (a in names(artists)) {
    hit <- credited[grepl(artists[[a]], norm(credited))]
    if (length(hit)) rows[[length(rows) + 1]] <- data.frame(artist_key = a, spelling = hit,
                                                            week_end = week_end[i], stringsAsFactors = FALSE)
  }
}
hits <- if (length(rows)) do.call(rbind, rows) else
  data.frame(artist_key = character(), spelling = character(), week_end = character())

audit <- if (nrow(hits)) {
  agg <- stats::aggregate(week_end ~ artist_key + spelling, data = hits,
                          FUN = function(w) c(n = length(unique(w)), first = min(w), last = max(w)))
  data.frame(artist_key = agg$artist_key, spelling = agg$spelling,
             weeks_in_top200 = as.integer(agg$week_end[, 'n']),
             first_week = agg$week_end[, 'first'], last_week = agg$week_end[, 'last'],
             stringsAsFactors = FALSE)
} else data.frame()
audit <- audit[order(audit$artist_key, -audit$weeks_in_top200), ]
utils::write.csv(audit, 'reports/qa/artist_name_audit.csv', row.names = FALSE, fileEncoding = 'UTF-8')

# Template: student keeps the rows that ARE the artist, sets include = yes.
tmpl <- data.frame(artist_key = audit$artist_key, exact_spelling = audit$spelling,
                   include = '', reason = '', stringsAsFactors = FALSE)
dir.create('data/metadata', showWarnings = FALSE)
utils::write.csv(tmpl, 'data/metadata/artist_aliases_TEMPLATE.csv', row.names = FALSE,
                 fileEncoding = 'UTF-8')

cat('\nSpain v4.1 - artist-name audit (names and week counts only, no streams)\n\n')
print(audit, row.names = FALSE)
missing <- setdiff(names(artists), audit$artist_key)
if (length(missing)) cat('\nNo spelling found at all for:', paste(missing, collapse = ', '), '\n')
cat('\nSaved: reports/qa/artist_name_audit.csv and data/metadata/artist_aliases_TEMPLATE.csv\n')
cat('NEXT: send me this table; we confirm spellings -> data/metadata/artist_aliases.csv\n')
