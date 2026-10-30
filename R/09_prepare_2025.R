# Spain Track A - Stage F03/R14: prepare the segregated 2025 evaluation data
# Amendment D52: 2025 opened by the student's release instruction, after
# FIT_AND_CODE_FREEZE, as a DISCLOSED EXPLORATORY out-of-time evaluation.
# This script does NOT score anything. It:
#   1. verifies the freeze manifest (frozen model and code unchanged);
#   2. inventories the 2025 CIS PDFs and Spotify weekly charts (hash, rows, weeks);
#   3. extracts the 2025 CIS Vox estimates with the SAME rule as R/02
#      (3rd number of the VOX row: % voto valido) and writes a manual check sheet.
# Outputs (all inside the quarantine folder, git-ignored, except value-free QA):
#   data/quarantine/test_2025/work/cis2025_extracted.csv
#   data/quarantine/test_2025/work/cis2025_manual_check.csv   <- type OK after checking
#   reports/qa/test2025_prep_qa.txt                           value-free
# Run from the project root in RStudio (Source button).

for (p in c('pdftools', 'digest')) {
  if (!requireNamespace(p, quietly = TRUE)) stop("Package '", p, "' is missing.")
}
q <- 'data/quarantine/test_2025'
work <- file.path(q, 'work'); dir.create(work, showWarnings = FALSE, recursive = TRUE)
hash <- function(f) digest::digest(file = f, algo = 'sha256')

# ---- 1. Freeze check --------------------------------------------------------------
man <- readLines('reports/results/fit_freeze_manifest.txt')[-(1:2)]
parts <- do.call(rbind, strsplit(man, ' '))
now <- vapply(parts[, 1], hash, character(1))
if (!all(now == parts[, 2])) stop('FREEZE BROKEN: changed since the freeze: ',
                                 paste(parts[now != parts[, 2], 1], collapse = ', '))

# ---- 2a. CIS 2025 PDFs ------------------------------------------------------------
pdfs <- list.files(file.path(q, 'cis'), pattern = '\\.pdf$', full.names = TRUE, ignore.case = TRUE)
if (!length(pdfs)) stop('No PDFs in ', file.path(q, 'cis'))
ids <- regmatches(basename(pdfs), regexpr('(?<![0-9])3[0-9]{3}(?![0-9])', basename(pdfs), perl = TRUE))
if (length(ids) != length(pdfs) || anyDuplicated(ids)) stop('Each 2025 PDF name must contain one unique 4-digit CIS study number.')

num_re <- '[\\x{00B1}+-]?\\s?[0-9]{1,3}(?:,[0-9]{1,2})?(?![0-9])'
to_num <- function(x) as.numeric(sub(',', '.', gsub('[\\x{00B1}+\\s]', '', x, perl = TRUE), fixed = TRUE))
extract <- function(f) {                       # identical rule to R/02_extract_cis.R
  pages <- pdftools::pdf_text(f)
  hdr <- grepl('voto v.{1,2}lido', pages, ignore.case = TRUE) &
         grepl('voto directo', pages, ignore.case = TRUE) & grepl('margen', pages, ignore.case = TRUE)
  if (!any(hdr)) return(list(status = 'REVIEW_HEADER_NOT_FOUND', page = NA, line = NA, value = NA))
  pg <- max(which(hdr)); lines <- strsplit(pages[pg], '\n', fixed = TRUE)[[1]]
  i <- which(grepl('^\\s*VOX\\b', lines))
  if (length(i) != 1) return(list(status = 'REVIEW_VOX_ROW', page = pg, line = NA, value = NA))
  tok <- regmatches(lines[i], gregexpr(num_re, lines[i], perl = TRUE))[[1]]
  if (length(tok) != 3 || !grepl('^[\\x{00B1}+-]', tok[2], perl = TRUE) ||
      grepl('^[\\x{00B1}+-]', tok[3], perl = TRUE))
    return(list(status = 'REVIEW_ROW_LAYOUT', page = pg, line = i, value = NA))
  v <- to_num(tok[3])
  list(status = if (v > 0 && v < 50) 'EXTRACTED_UNVERIFIED' else 'REVIEW_IMPLAUSIBLE_VALUE',
       page = pg, line = i, value = v)
}
ex <- do.call(rbind, lapply(seq_along(pdfs), function(j) {
  e <- extract(pdfs[j])
  data.frame(study_id = ids[j], file = basename(pdfs[j]), sha256 = hash(pdfs[j]),
             page = e$page, line = e$line, vox_estimate_valid = e$value, status = e$status,
             stringsAsFactors = FALSE)
}))
ex <- ex[order(ex$study_id), ]
utils::write.csv(ex, file.path(work, 'cis2025_extracted.csv'), row.names = FALSE, na = '')

chk_path <- file.path(work, 'cis2025_manual_check.csv')
chk <- data.frame(study_id = ex$study_id, file = ex$file, page = ex$page, line = ex$line,
                  vox_estimate_valid = ex$vox_estimate_valid, check = '', note = '')
if (file.exists(chk_path)) {                    # keep earlier OKs only if nothing changed
  old <- utils::read.csv(chk_path, colClasses = 'character')
  key <- function(d) paste(d$study_id, d$file, d$page, d$line, as.numeric(d$vox_estimate_valid))
  j <- match(key(chk), key(old))
  chk$check[!is.na(j)] <- old$check[j[!is.na(j)]]; chk$note[!is.na(j)] <- old$note[j[!is.na(j)]]
}
utils::write.csv(chk, chk_path, row.names = FALSE, na = '')

# ---- 2b. Spotify 2025 weekly charts ------------------------------------------------
csvs <- list.files(file.path(q, 'spotify'), pattern = '\\.csv$', full.names = TRUE)
we <- regmatches(basename(csvs), regexpr('20[0-9]{2}-[0-9]{2}-[0-9]{2}', basename(csvs)))
expected <- format(seq(as.Date('2025-01-02'), as.Date('2025-09-25'), by = 7), '%Y-%m-%d')
mus <- do.call(rbind, lapply(seq_along(csvs), function(j) {
  d <- tryCatch(utils::read.csv(csvs[j], check.names = FALSE, fileEncoding = 'UTF-8-BOM'),
                error = function(e) NULL)
  ok <- !is.null(d) && all(c('rank', 'streams', 'artist_names') %in% tolower(names(d))) && nrow(d) == 200
  data.frame(file = basename(csvs[j]), week_end = we[j], sha256 = hash(csvs[j]),
             status = if (ok) 'HEADER_AND_ROWCOUNT_OK' else 'REVIEW', stringsAsFactors = FALSE)
}))
utils::write.csv(mus, file.path(work, 'spotify2025_inventory.csv'), row.names = FALSE)
missing_weeks <- setdiff(expected, mus$week_end[mus$status == 'HEADER_AND_ROWCOUNT_OK'])

dates_ok <- file.exists('data/metadata/cis_release_dates_2025.csv')
lines <- c(
  'Spain v4.1 - 2025 preparation (exploratory evaluation, D52). Counts only, nothing scored.',
  'Freeze manifest: VERIFIED (model and code unchanged since FIT_AND_CODE_FREEZE)',
  paste0('CIS 2025 PDFs: ', nrow(ex), ' | studies: ', paste(ex$study_id, collapse = ', ')),
  paste0('CIS extraction status: ', paste(names(table(ex$status)), table(ex$status), sep = '=', collapse = ', ')),
  paste0('Spotify 2025 weekly files OK: ', sum(mus$status == 'HEADER_AND_ROWCOUNT_OK'), ' / 39 expected',
         if (length(missing_weeks)) paste0(' | missing/bad: ', paste(missing_weeks, collapse = ', ')) else ''),
  paste0('Official 2025 release dates file present: ', dates_ok),
  'NEXT: verify each 2025 value by eye (cis2025_manual_check.csv -> OK), then run R/10_score_2025.R'
)
writeLines(lines, 'reports/qa/test2025_prep_qa.txt')
cat('\n', paste(lines, collapse = '\n'), '\n', sep = '')
