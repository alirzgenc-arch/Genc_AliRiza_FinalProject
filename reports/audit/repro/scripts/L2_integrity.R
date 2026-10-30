# L2 - stored-artefact integrity and development-only model reproduction.
# Run from the copied project root. Read-only on frozen files; refit happens in tempdir().
# Predeclared tolerances: byte files -> exact SHA-256; numeric results -> abs diff < 1e-8.
suppressMessages({library(digest); library(glmnet)})
TOL <- 1e-8
sha <- function(f) if (file.exists(f)) digest(file = f, algo = "sha256") else NA_character_
res <- data.frame(id = character(), assertion = character(), expected = character(),
                  observed = character(), status = character(), stringsAsFactors = FALSE)
add <- function(id, a, e, o, ok) res[nrow(res) + 1, ] <<- list(id, a, e, o, if (isTRUE(ok)) "PASS" else "FAIL")

# Robust manifest parser: hash is the last whitespace-separated token; path is everything before it.
parse_manifest <- function(lines) {
  lines <- lines[grepl("[0-9a-f]{64}$", lines)]
  data.frame(path = sub("\\s+[0-9a-f]{64}$", "", lines), hash = sub("^.*\\s([0-9a-f]{64})$", "\\1", lines),
             stringsAsFactors = FALSE)
}
for (mf in c("reports/results/fit_freeze_manifest.txt", "reports/results/test2025_lock.txt")) {
  m <- parse_manifest(readLines(mf))
  now <- vapply(m$path, sha, "")
  add(paste0("L2-hash-", basename(mf)), paste("SHA-256 of every file listed in", mf),
      paste(nrow(m), "match"), paste(sum(now == m$hash, na.rm = TRUE), "match;", sum(is.na(now)), "missing"),
      all(now == m$hash))
  add(paste0("L2-paths-", basename(mf)), "Manifest paths are relative, no spaces, no user home",
      "relative", paste(sum(grepl("^/|^~|[A-Za-z]:\\\\|\\s", m$path)), "bad paths"),
      !any(grepl("^/|^~|[A-Za-z]:\\\\|\\s", m$path)))
}
# Space-in-filename parsing test (synthetic line, no file needed)
syn <- "data/raw/some folder/file name.csv 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
naive <- strsplit(syn, " ")[[1]]
add("L2-parse-space", "Rmd parser strsplit(' ') handles a path with spaces", "2 fields",
    paste(length(naive), "fields (naive); robust parser path =", shQuote(parse_manifest(syn)$path)),
    length(naive) == 2)

# Development refit in a temporary folder
tmp <- file.path(tempdir(), "l2_refit"); unlink(tmp, recursive = TRUE)
dir.create(file.path(tmp, "R"), recursive = TRUE); dir.create(file.path(tmp, "data/processed"), recursive = TRUE)
file.copy("R/08_fit_models.R", file.path(tmp, "R")); file.copy("data/processed/model_frame_monthly.csv", file.path(tmp, "data/processed"))
owd <- setwd(tmp); invisible(capture.output(source("R/08_fit_models.R", local = new.env()))); setwd(owd)
cmp_csv <- function(id, f, keys, nums) {
  a <- read.csv(f, stringsAsFactors = FALSE); b <- read.csv(file.path(tmp, f), stringsAsFactors = FALSE)
  k <- function(d) do.call(paste, c(d[keys], sep = "|"))
  same_keys <- setequal(k(a), k(b)) && nrow(a) == nrow(b) && !anyDuplicated(k(a))
  b <- b[match(k(a), k(b)), ]
  d <- max(abs(as.matrix(a[nums]) - as.matrix(b[nums])), na.rm = TRUE)
  ch <- setdiff(names(a), c(keys, nums)); same_other <- all(vapply(ch, function(cn) identical(as.character(a[[cn]]), as.character(b[[cn]])), TRUE))
  add(id, paste("Refit reproduces", f, "by keys", paste(keys, collapse = "+")),
      paste0(nrow(a), " rows; max diff < ", TOL), paste0(nrow(b), " rows; keys equal=", same_keys,
      "; max diff=", signif(d, 3), "; other cols identical=", same_other), same_keys && d < TOL && same_other)
}
cmp_csv("L2-refit-pred", "data/processed/forward_predictions.csv", c("design", "model", "fold", "origin"), c("observed", "n_train", "prediction"))
cmp_csv("L2-refit-lambda", "reports/results/selected_lambdas.csv", c("design", "model"), c("lambda", "grid_index"))
cmp_csv("L2-refit-metrics", "reports/results/model_metrics.csv", c("design", "model"), c("n", "MAE", "RMSE", "bias"))
cmp_csv("L2-refit-coef", "reports/results/final_coefficients.csv", c("design", "model", "term"), c("coef_standardized", "lambda"))
fz_a <- readRDS("data/processed/fit_freeze.rds"); fz_b <- readRDS(file.path(tmp, "data/processed/fit_freeze.rds"))
add("L2-refit-rds", "Refit final models equal frozen fit_freeze.rds (excluding creation time)", "all.equal TRUE",
    paste(isTRUE(all.equal(fz_a$finals, fz_b$finals, tolerance = TOL)), "| grid", isTRUE(all.equal(fz_a$grid, fz_b$grid))),
    isTRUE(all.equal(fz_a$finals, fz_b$finals, tolerance = TOL)) && isTRUE(all.equal(fz_a$grid, fz_b$grid)))
add("L2-refit-bytes", "Refit model_metrics.csv byte-identical to frozen (informative)", "same hash",
    if (sha("reports/results/model_metrics.csv") == sha(file.path(tmp, "reports/results/model_metrics.csv"))) "identical" else "differs (numeric check above decides)", TRUE)

# Metrics recomputed from stored predictions, keyed by design x model
metr <- function(p) do.call(rbind, lapply(split(p, list(p$design, p$model), drop = TRUE), function(d)
  data.frame(design = d$design[1], model = d$model[1], n = nrow(d), MAE = mean(abs(d$prediction - d$observed)),
             RMSE = sqrt(mean((d$prediction - d$observed)^2)), bias = mean(d$prediction - d$observed))))
chk_metrics <- function(id, p, f) {
  r <- metr(p); m <- read.csv(f); j <- merge(r, m, by = c("design", "model"))
  d <- max(abs(as.matrix(j[c("n.x", "MAE.x", "RMSE.x", "bias.x")]) - as.matrix(j[c("n.y", "MAE.y", "RMSE.y", "bias.y")])))
  same_cases <- length(unique(lapply(split(p$origin, list(p$design, p$model), drop = TRUE), sort))) == 1
  add(id, paste("MAE/RMSE/bias/n recomputed from stored predictions equal", f, "; identical cases across models"),
      paste0(nrow(m), " rows; diff < ", TOL), paste0(nrow(j), " matched; max diff=", signif(d, 3), "; same cases=", same_cases),
      nrow(j) == nrow(m) && d < TOL && same_cases)
}
chk_metrics("L2-metrics-2024", read.csv("data/processed/forward_predictions.csv"), "reports/results/model_metrics.csv")
# 2025: read-only, aggregates only (no per-case output)
chk_metrics("L2-metrics-2025", read.csv("data/quarantine/test_2025/work/test2025_predictions.csv"), "reports/results/test2025_metrics.csv")
add("L2-no-rescore", "No 2025 model scoring was run in this test", "R/10 not sourced", "R/10 not sourced; predictions only read", TRUE)
write.csv(res, "L2_results.csv", row.names = FALSE)
print(res[, c("id", "observed", "status")], right = FALSE)
