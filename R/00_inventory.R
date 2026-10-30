# Spain Track A — Stage R02: safe development-file inventory
# Unified v4 · No extraction of Vox estimates, no artist features, no test access.
# Run from the Spain_TrackA.Rproj root in RStudio.
# v4.1 patch (29 Oct 2026): (1) 2025 check uses the full relative path for music
# files too, so a file inside a '2025/' folder is never opened; (2) UTF-8 BOM
# tolerated; (3) weekly chart date parsed from filename + missing-week report;
# (4) warning when the music folder is absent.

if (!file.exists('Spain_TrackA.Rproj')) {
  stop('Open Spain_TrackA.Rproj first; do not use setwd().')
}
if (!requireNamespace('digest', quietly = TRUE)) {
  stop("The digest package is missing. Install it once in RStudio's Console, then rerun.")
}

cis_dir <- 'data/raw/cis_2023_2024'
music_dir <- 'data/raw/music_dev/spotify_weekly_es'
qa_dir <- 'reports/qa'
if (!dir.exists(cis_dir)) stop('Missing directory: ', cis_dir)
if (!dir.exists(music_dir)) warning('Music folder not found (0 Spotify files will be listed): ', music_dir)
dir.create(qa_dir, recursive = TRUE, showWarnings = FALSE)

expected_2022 <- c('3384','3388')   # Nov + Dec 2022: prior inputs only (amendment D49)
expected_2023 <- c('3390','3395','3398','3403','3405','3410','3413',
                   '3420','3423','3427','3431')
expected_2024 <- c('3435','3441','3445','3450','3457','3463','3468',
                   '3474','3478','3485','3489')
expected_ids <- c(expected_2022, expected_2023, expected_2024)

# Only scan explicitly named development directories. Never recurse from data/.
find_files <- function(folder, extension) {
  if (!dir.exists(folder)) return(character())
  files <- list.files(folder, recursive = TRUE, full.names = TRUE,
                      all.files = FALSE, include.dirs = FALSE)
  files[grepl(paste0('\\.', extension, '$'), files, ignore.case = TRUE)]
}

# Reject symbolic links so a "development" path cannot point at test files.
# Note: on Windows Sys.readlink() cannot see shortcuts/junctions — copy real files, never link.
check_regular_file <- function(path) {
  link <- Sys.readlink(path)
  if (!is.na(link) && nzchar(link)) stop('Symbolic link prohibited: ', path)
  if (is.na(file.info(path)$size)) stop('Unreadable file: ', path)
}

# Filenames and folder names are merely hints: PDF content is NOT validated here.
get_expected_id <- function(path) {
  hits <- expected_ids[vapply(expected_ids, function(id) {
    grepl(paste0('(?<![0-9])', id, '(?![0-9])'), path, perl = TRUE)
  }, logical(1))]
  if (length(hits) == 1L) hits else NA_character_
}

# Never read/hash 2025-or-later research files, including misfiled files.
is_test_named <- function(path) grepl('20(25|26|27)', path)
sha_safe <- function(path) {
  if (is_test_named(path)) return(NA_character_)
  check_regular_file(path)
  digest::digest(file = path, algo = 'sha256')
}

cis_files <- find_files(cis_dir, 'pdf')
cis <- data.frame(
  relative_path = cis_files,
  original_filename = basename(cis_files),
  bytes = as.numeric(file.info(cis_files)$size),
  sha256 = vapply(cis_files, sha_safe, character(1)),
  expected_study_id = vapply(cis_files, get_expected_id, character(1)),
  stringsAsFactors = FALSE
)
cis$year_hint <- ifelse(cis$expected_study_id %in% expected_2022, '2022',
                 ifelse(cis$expected_study_id %in% expected_2023, '2023',
                        ifelse(cis$expected_study_id %in% expected_2024, '2024', 'UNKNOWN')))
cis$inventory_status <- ifelse(is_test_named(cis$relative_path), 'STOP_TEST_NAMED',
                        ifelse(is.na(cis$expected_study_id), 'REVIEW_ID_UNKNOWN', 'ID_FILENAME_HINT_ONLY'))
cis$duplicate_hash <- !is.na(cis$sha256) &
  (duplicated(cis$sha256) | duplicated(cis$sha256, fromLast = TRUE))

# Spotify: only dev files with identifiable 2023/2024 periods are opened.
# Reading the CSV to count rows does not derive streams or artist features.
music_files <- find_files(music_dir, 'csv')
inspect_music <- function(path) {
  check_regular_file(path)
  name <- basename(path)
  if (is_test_named(path)) {   # full relative path: catches '2025/' folders too
    return(list(status = 'STOP_TEST_NAMED', rows = NA_integer_, columns = NA_character_, sha = NA_character_))
  }
  if (!(grepl('2023|2024', name) || grepl('2022-12', name))) {
    return(list(status = 'REVIEW_DATE_UNKNOWN', rows = NA_integer_, columns = NA_character_, sha = NA_character_))
  }
  hash <- digest::digest(file = path, algo = 'sha256')
  dat <- tryCatch(utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE,
                                  fileEncoding = 'UTF-8-BOM'), error = function(e) e)
  if (inherits(dat, 'error')) {
    return(list(status = 'CSV_PARSE_ERROR', rows = NA_integer_, columns = NA_character_, sha = hash))
  }
  cols <- names(dat)
  plausible <- all(c('rank', 'streams') %in% tolower(cols))
  list(status = if (plausible && nrow(dat) == 200L) 'HEADER_AND_ROWCOUNT_OK'
                else 'REVIEW_HEADER_OR_ROWCOUNT',
       rows = as.integer(nrow(dat)), columns = paste(cols, collapse = ' | '), sha = hash)
}
meta <- lapply(music_files, inspect_music)
music <- data.frame(
  relative_path = music_files,
  original_filename = basename(music_files),
  bytes = as.numeric(file.info(music_files)$size),
  sha256 = vapply(meta, `[[`, character(1), 'sha'),
  row_count = vapply(meta, `[[`, integer(1), 'rows'),
  column_names = vapply(meta, `[[`, character(1), 'columns'),
  inventory_status = vapply(meta, `[[`, character(1), 'status'),
  stringsAsFactors = FALSE
)
music$duplicate_hash <- !is.na(music$sha256) &
  (duplicated(music$sha256) | duplicated(music$sha256, fromLast = TRUE))

# Chart date from the filename only (Spotify names weekly files by the week-end
# Thursday, e.g. regional-es-weekly-2023-01-05.csv). Filename = hint, not proof.
date_str <- regmatches(music$original_filename,
                       regexpr('20[0-9]{2}-[0-9]{2}-[0-9]{2}', music$original_filename))
music$filename_date <- rep(as.Date(NA), nrow(music))
has_date <- grepl('20[0-9]{2}-[0-9]{2}-[0-9]{2}', music$original_filename)
music$filename_date[has_date] <- as.Date(date_str, format = '%Y-%m-%d')
music$filename_weekday <- ifelse(is.na(music$filename_date), '',
                                 format(music$filename_date, '%u'))  # 4 = Thursday
music$date_status <- ifelse(is.na(music$filename_date), 'NO_DATE_IN_NAME',
                     ifelse(music$filename_weekday != '4', 'REVIEW_NOT_THURSDAY',
                     ifelse(duplicated(music$filename_date) |
                            duplicated(music$filename_date, fromLast = TRUE),
                            'REVIEW_SAME_WEEK_TWICE', 'OK')))
music$filename_date <- format(music$filename_date, '%Y-%m-%d')

# Expected Thursdays: 2022-12-01 ... 2024-12-26 (109 weeks; Dec 2022 per D49).
expected_weeks <- format(seq(as.Date('2022-12-01'), as.Date('2024-12-26'), by = 7), '%Y-%m-%d')
ok_weeks <- music$filename_date[music$inventory_status == 'HEADER_AND_ROWCOUNT_OK' &
                                music$date_status == 'OK']
missing_weeks <- setdiff(expected_weeks, ok_weeks)

missing_ids <- setdiff(expected_ids, unique(stats::na.omit(cis$expected_study_id)))
music_flag <- music$inventory_status != 'HEADER_AND_ROWCOUNT_OK' | music$duplicate_hash |
  music$date_status != 'OK'
issues <- data.frame(
  issue = c(rep('EXPECTED_ID_NOT_LOCATED', length(missing_ids)),
            rep('CIS_REVIEW_OR_DUPLICATE', sum(cis$inventory_status != 'ID_FILENAME_HINT_ONLY' | cis$duplicate_hash)),
            rep('MUSIC_REVIEW_OR_DUPLICATE', sum(music_flag)),
            rep('MUSIC_WEEK_NOT_COVERED', length(missing_weeks))),
  item = c(missing_ids,
           cis$relative_path[cis$inventory_status != 'ID_FILENAME_HINT_ONLY' | cis$duplicate_hash],
           music$relative_path[music_flag],
           missing_weeks),
  stringsAsFactors = FALSE
)

write.csv(cis, file.path(qa_dir, 'cis_raw_inventory.csv'), row.names = FALSE, na = '')
write.csv(music, file.path(qa_dir, 'music_file_inventory.csv'), row.names = FALSE, na = '')
write.csv(issues, file.path(qa_dir, 'missing_and_duplicates.csv'), row.names = FALSE, na = '')

cat('\nSpain v4 development inventory finished (NO poll values or artist features).\n')
cat('CIS PDFs:', nrow(cis), '| study IDs located:',
    length(unique(stats::na.omit(cis$expected_study_id))), '/', length(expected_ids), '\n')
cat('Missing/unrecognized IDs:', length(missing_ids), '\n')
cat('Spotify development CSVs listed:', nrow(music), '| Dec 2022-Dec 2024 weeks covered:',
    length(expected_weeks) - length(missing_weeks), '/', length(expected_weeks), '\n')
cat('Issues requiring manual review:', nrow(issues), '\n')
cat('QA files written to:', qa_dir, '\n')
cat('STOP: Review QA outputs before writing 01_pdf_structure.R.\n')
