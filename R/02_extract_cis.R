# Spain Track A - Stage R04: extract the CIS Vox estimate from the 24 dev PDFs (22 + Nov/Dec 2022, D49)
# Unified v4.1 (patch 2: integer 3rd column accepted, flagged) - Decision D45 (provisional): automatic extraction + manual
# verification of EVERY value against the original page (R05).
#
# Column layout confirmed visually by the student on 3463 (June 2024), last page:
#   col 1 = "Voto directo en la encuesta (en % sobre censo)"      -> NOT the target
#   col 2 = "Margen teorico de error"                             -> +/- value
#   col 3 = "Estimacion de voto CIS (en % sobre el voto valido)"  -> TARGET
# The script takes the 3rd number of the VOX row and refuses any row that does
# not have exactly 3 numbers with the +/- value in the middle.
#
# Outputs
#   data/interim/cis_vox_extracted.csv     VALUES - local only (git-ignored)
#   data/interim/cis_vox_manual_check.csv  VALUES + empty 'check' column for you
#   reports/qa/cis_extraction_qa.csv       value-free (digits masked) - git-safe
# Run from the Spain_TrackA.Rproj root in RStudio (Source button).

if (!file.exists('Spain_TrackA.Rproj')) stop('Open Spain_TrackA.Rproj first; do not use setwd().')
for (p in c('pdftools', 'digest')) {
  if (!requireNamespace(p, quietly = TRUE)) stop("Package '", p, "' missing: install.packages('", p, "')")
}
inv_path <- 'reports/qa/cis_raw_inventory.csv'
if (!file.exists(inv_path)) stop('Run R/00_inventory.R first.')
dir.create('data/interim', recursive = TRUE, showWarnings = FALSE)

inv <- utils::read.csv(inv_path, stringsAsFactors = FALSE, colClasses = 'character')
inv <- inv[inv$inventory_status == 'ID_FILENAME_HINT_ONLY' & inv$duplicate_hash != 'TRUE', ]
if (any(grepl('20(25|26|27)', inv$relative_path))) stop('2025+ file in development inventory.')
if (nrow(inv) != 24L) warning('Expected 24 CIS PDFs, inventory has ', nrow(inv))

mask <- function(x) gsub('[0-9]', '#', x)
num_re <- '[\\x{00B1}+-]?\\s?[0-9]{1,3}(?:,[0-9]{1,2})?(?![0-9])'   # 12,3 / +-1,2 / 12 (integer)

extract_one <- function(r) {
  out <- list(study_id = r$expected_study_id, year_hint = r$year_hint,
              relative_path = r$relative_path, sha256 = r$sha256,
              pdf_created = NA_character_, page = NA_integer_, line = NA_integer_,
              n_numbers = NA_integer_, masked_row = NA_character_,
              voto_directo_censo = NA_real_, margen_error = NA_real_,
              vox_estimate_valid = NA_real_, status = NA_character_)
  sha_now <- digest::digest(file = r$relative_path, algo = 'sha256')
  if (!identical(sha_now, r$sha256)) { out$status <- 'STOP_SHA_CHANGED'; return(out) }

  info <- pdftools::pdf_info(r$relative_path)
  out$pdf_created <- if (is.null(info$created)) NA_character_ else format(info$created, '%Y-%m-%d %H:%M')
  pages <- pdftools::pdf_text(r$relative_path)

  # The estimate table page must contain all three column headers.
  hdr_ok <- grepl('voto v.{1,2}lido', pages, ignore.case = TRUE) &
            grepl('voto directo', pages, ignore.case = TRUE) &
            grepl('margen', pages, ignore.case = TRUE)
  if (!any(hdr_ok)) { out$status <- 'REVIEW_HEADER_NOT_FOUND'; return(out) }
  pg <- max(which(hdr_ok))
  out$page <- pg

  lines <- strsplit(pages[pg], '\n', fixed = TRUE)[[1]]
  vox_i <- which(grepl('^\\s*VOX\\b', lines))
  if (length(vox_i) != 1L) {
    out$status <- if (length(vox_i) == 0L) 'REVIEW_NO_VOX_ROW' else 'REVIEW_MULTIPLE_VOX_ROWS'
    return(out)
  }
  out$line <- vox_i
  row <- lines[vox_i]
  out$masked_row <- mask(trimws(row))
  tok <- regmatches(row, gregexpr(num_re, row, perl = TRUE))[[1]]
  out$n_numbers <- length(tok)
  if (length(tok) != 3L || !grepl('^[\\x{00B1}+-]', tok[2], perl = TRUE) || grepl('^[\\x{00B1}+-]', tok[3], perl = TRUE)) {
    out$status <- 'REVIEW_ROW_LAYOUT'; return(out)
  }
  to_num <- function(x) as.numeric(sub(',', '.', gsub('[\\x{00B1}+\\s]', '', x, perl = TRUE), fixed = TRUE))
  out$voto_directo_censo <- to_num(tok[1])
  out$margen_error <- to_num(tok[2])
  out$vox_estimate_valid <- to_num(tok[3])
  out$status <- if (is.na(out$vox_estimate_valid) || out$vox_estimate_valid <= 0 ||
                    out$vox_estimate_valid >= 50) 'REVIEW_IMPLAUSIBLE_VALUE'
                 else if (!grepl(',', tok[3])) 'EXTRACTED_UNVERIFIED_INTEGER'  # printed without decimals: check by eye
                 else 'EXTRACTED_UNVERIFIED'
  out
}

res <- do.call(rbind, lapply(seq_len(nrow(inv)), function(i) {
  as.data.frame(extract_one(inv[i, ]), stringsAsFactors = FALSE)
}))
res <- res[order(res$study_id), ]

# 1) Values: local interim file (git-ignored).
utils::write.csv(res, 'data/interim/cis_vox_extracted.csv', row.names = FALSE, na = '')

# 2) Manual check sheet - never overwrite one you have started filling in.
chk <- data.frame(study_id = res$study_id, file = basename(res$relative_path),
                  page = res$page, line = res$line,
                  vox_estimate_valid = res$vox_estimate_valid, check = '', note = '',
                  stringsAsFactors = FALSE)
chk_path <- 'data/interim/cis_vox_manual_check.csv'
if (file.exists(chk_path)) {
  # Keep an earlier OK/WRONG only where file, page, line AND value are unchanged;
  # anything new or different gets an empty check and must be verified again.
  old <- utils::read.csv(chk_path, colClasses = 'character')
  key <- function(d) paste(d$study_id, d$file, d$page, d$line, as.numeric(d$vox_estimate_valid))
  j <- match(key(chk), key(old))
  chk$check[!is.na(j)] <- old$check[j[!is.na(j)]]
  chk$note[!is.na(j)]  <- old$note[j[!is.na(j)]]
  file.copy(chk_path, sub('\\.csv$', '_backup.csv', chk_path), overwrite = TRUE)
  message('Check sheet updated: ', sum(!is.na(j)), ' earlier checks kept, ',
          sum(is.na(j)), ' rows need checking (backup: *_backup.csv).')
}
utils::write.csv(chk, chk_path, row.names = FALSE, na = '')

# 3) Value-free QA (safe for GitHub and for the chat).
qa <- res[, c('study_id', 'year_hint', 'sha256', 'pdf_created', 'page', 'line',
              'n_numbers', 'masked_row', 'status')]
utils::write.csv(qa, 'reports/qa/cis_extraction_qa.csv', row.names = FALSE, na = '',
                 fileEncoding = 'UTF-8')

cat('\nSpain v4.1 - R04 CIS extraction finished (values saved locally, NOT printed).\n')
print(table(status = res$status))
ok <- grepl('^EXTRACTED_UNVERIFIED', res$status)
cat('Extracted (unverified):', sum(ok), '/', nrow(res), '\n')
if (any(!ok)) {
  cat('Needs review:', paste(res$study_id[!ok], collapse = ', '), '\n')
}
cat('Files: data/interim/cis_vox_extracted.csv (local),', chk_path, '(local),\n')
cat('       reports/qa/cis_extraction_qa.csv (value-free)\n')
cat('NEXT (R05): verify every value by eye in Preview, type OK in the check column.\n')
