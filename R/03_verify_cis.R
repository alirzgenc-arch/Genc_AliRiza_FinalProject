# Spain Track A - Stage R05 close-out: lock the verified CIS Vox series
# Unified v4.1 - Reads the student's manual check sheet, asserts that every
# value was verified (check == "OK") and is unchanged since extraction, that the
# raw PDFs are still byte-identical, then writes the verified series.
#
# Outputs
#   data/processed/cis_vox_verified.csv   VALUES (24 rows: 2 x 2022 prior-input + 22 x 2023-24) - input for R06/R07
#   reports/qa/cis_verification_qa.csv    value-free - git-safe
# Run from the project root in RStudio (Source button).

for (p in c('digest')) {
  if (!requireNamespace(p, quietly = TRUE)) stop("Package '", p, "' is missing.")
}
paths <- c(inv = 'reports/qa/cis_raw_inventory.csv',
           ext = 'data/interim/cis_vox_extracted.csv',
           chk = 'data/interim/cis_vox_manual_check.csv')
miss <- paths[!file.exists(paths)]
if (length(miss)) stop('Missing: ', paste(miss, collapse = ', '), ' - run 00 and 02 first.')

inv <- utils::read.csv(paths[['inv']], colClasses = 'character')
ext <- utils::read.csv(paths[['ext']], colClasses = 'character')
chk <- utils::read.csv(paths[['chk']], colClasses = 'character')

expected_ids <- c('3384','3388','3390','3395','3398','3403','3405','3410','3413','3420','3423','3427','3431',
                  '3435','3441','3445','3450','3457','3463','3468','3474','3478','3485','3489')
problems <- character()
add <- function(cond, msg) if (!cond) problems <<- c(problems, msg)

# 1) Coverage: exactly the 24 expected studies, once each, in both files.
add(setequal(chk$study_id, expected_ids) && !anyDuplicated(chk$study_id),
    'Check sheet does not contain exactly the 24 expected study IDs once each.')
add(setequal(ext$study_id, expected_ids) && !anyDuplicated(ext$study_id),
    'Extraction file does not contain exactly the 24 expected study IDs once each.')

# 2) Every row verified by eye.
chk$check <- toupper(trimws(chk$check))
not_ok <- chk$study_id[chk$check != 'OK']
add(length(not_ok) == 0, paste0('Not marked OK: ', paste(not_ok, collapse = ', ')))

# 3) Values / page / line in the check sheet were not altered after extraction.
m <- merge(ext, chk, by = 'study_id', suffixes = c('.ext', '.chk'))
same_val <- abs(as.numeric(m$vox_estimate_valid.ext) - as.numeric(m$vox_estimate_valid.chk)) < 1e-9
same_loc <- m$page.ext == m$page.chk & m$line.ext == m$line.chk
add(all(same_val %in% TRUE), paste0('Value differs from extraction for: ',
                                   paste(m$study_id[!(same_val %in% TRUE)], collapse = ', ')))
add(all(same_loc), paste0('Page/line differs for: ', paste(m$study_id[!same_loc], collapse = ', ')))
add(all(grepl('^EXTRACTED_UNVERIFIED', ext$status)), 'Extraction file contains REVIEW/STOP rows.')

# 4) Raw PDFs unchanged since inventory and extraction.
ext$sha_now <- vapply(ext$relative_path, function(f) {
  if (!file.exists(f)) return(NA_character_)
  digest::digest(file = f, algo = 'sha256')
}, character(1))
inv_sha <- inv$sha256[match(ext$relative_path, inv$relative_path)]
sha_ok <- !is.na(ext$sha_now) & ext$sha_now == ext$sha256 & ext$sha_now == inv_sha
add(all(sha_ok), paste0('Raw PDF changed/missing for: ', paste(ext$study_id[!sha_ok], collapse = ', ')))

# 5) Lock or stop.
qa <- data.frame(study_id = m$study_id, sha_unchanged = sha_ok[match(m$study_id, ext$study_id)],
                 value_unchanged = same_val, location_unchanged = same_loc,
                 manual_check = m$check, note = m$note, stringsAsFactors = FALSE)
utils::write.csv(qa, 'reports/qa/cis_verification_qa.csv', row.names = FALSE, na = '')

if (length(problems)) {
  cat('\nR05 verification FAILED - nothing written to data/processed/:\n')
  cat(paste0(' - ', problems), sep = '\n')
  stop('Fix the problems above and re-run.', call. = FALSE)
}

dir.create('data/processed', recursive = TRUE, showWarnings = FALSE)
verified <- data.frame(
  study_id = ext$study_id,
  year = ext$year_hint,
  source = 'CIS',
  file = basename(ext$relative_path),
  sha256 = ext$sha256,
  pdf_created = ext$pdf_created,          # vintage evidence (PDF creation time)
  page = as.integer(ext$page),
  line = as.integer(ext$line),
  vox_estimate_valid = as.numeric(ext$vox_estimate_valid),  # % of valid vote
  printed_as_integer = ext$status == 'EXTRACTED_UNVERIFIED_INTEGER',
  verified_by_eye = TRUE,
  verified_check_sheet_mtime = format(file.info(paths[['chk']])$mtime, '%Y-%m-%d %H:%M'),
  stringsAsFactors = FALSE
)
verified <- verified[order(verified$study_id), ]
utils::write.csv(verified, 'data/processed/cis_vox_verified.csv', row.names = FALSE)

cat('\nSpain v4.1 - R05 verification PASSED (values not printed).\n')
cat('Studies verified:', nrow(verified), '/ 24 | raw PDFs unchanged:', sum(sha_ok), '/ 24\n')
cat('By year:', paste(names(table(verified$year)), table(verified$year), sep = '=', collapse = ', '), '\n')
cat('Written: data/processed/cis_vox_verified.csv and reports/qa/cis_verification_qa.csv\n')
cat('NEXT: knit Genc_AliRiza_FinalProject.Rmd once (skeleton), then R06/R07 calendar.\n')
