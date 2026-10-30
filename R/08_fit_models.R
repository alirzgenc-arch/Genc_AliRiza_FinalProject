# Spain Track A - Stage R11: fit and evaluate (FB-M monthly, K = 3)
# Implements Methods Sec. 6-7 exactly:
#   M0 persistence | M1 Ridge (3 polling inputs) | M2 Ridge (M1 + 3 music inputs)
#   Gaussian, alpha = 0, unpenalized intercept, standardize = FALSE with explicit
#   training-only x/y scaling (sample SD, n-1); predictions back-transformed.
#   Forward folds by origin quarter: F1 2024Q1 (cutoff 2024-01-01), F2 2024Q2
#   (2024-04-01), F3 2024Q3 (2024-07-01); no refit within a block.
#   Lambda grid: 80 log-spaced values 10^3 .. 10^-4, identical for all models;
#   each model's lambda = min pooled forward-validation MAE (pp); ties within
#   1e-8 -> larger lambda; boundary optimum -> recorded warning.
#   THE CHECK: both Ridge models replaced by Elastic Net alpha = 0.5, all else equal.
#   Final refit on all mature 2023-24 common cases with a new training-only scaler.
# 2025 is NOT touched. Validation losses were used for tuning (not an independent claim).
#
# Outputs
#   reports/results/model_metrics.csv        MAE / RMSE / bias per model (pp)
#   reports/results/selected_lambdas.csv
#   reports/results/final_coefficients.csv   standardized-scale coefficients of the refit
#   data/processed/forward_predictions.csv   per-case predictions (values)
#   data/processed/fit_freeze.rds + reports/results/fit_freeze_manifest.txt (hashes)
# Run from the project root in RStudio (Source button).

for (p in c('glmnet', 'digest')) {
  if (!requireNamespace(p, quietly = TRUE)) stop("Package '", p, "' is missing.")
}
set.seed(2026)   # glmnet is deterministic here; seed kept for the template's rule

mf <- utils::read.csv('data/processed/model_frame_monthly.csv', stringsAsFactors = FALSE)
for (v in c('origin', 'target_mature_at')) mf[[v]] <- as.Date(mf[[v]])
mf <- mf[mf$common_case, ]
poll_x  <- c('poll_level', 'poll_change', 'poll_age_days')
music_x <- c('music_morad', 'music_beny_jr', 'music_cyril_kamer')
specs <- list(M1 = poll_x, M2 = c(poll_x, music_x))
grid <- 10^seq(3, -4, length.out = 80)          # decreasing, as glmnet expects
dev_cut <- as.Date('2025-01-01')
folds <- data.frame(fold = c('F1', 'F2', 'F3'),
                    cutoff = as.Date(c('2024-01-01', '2024-04-01', '2024-07-01')))

# ---- helpers -------------------------------------------------------------
scaler <- function(d, xs) {
  list(xm = sapply(d[xs], mean), xs = sapply(d[xs], stats::sd),
       ym = mean(d$target), ys = stats::sd(d$target))
}
fit_path <- function(train, xs, alpha) {
  s <- scaler(train, xs)
  if (!is.finite(s$ys) || s$ys == 0) stop('Constant training y - fitting stops (Sec. 6).')
  const <- names(s$xs)[!is.finite(s$xs) | s$xs == 0]
  if (any(const %in% music_x)) stop('Artist constant in training: ', paste(const, collapse = ', '),
                                    ' - review required, not a new subset (Sec. 6).')
  use <- setdiff(xs, const)                      # technical constant polling column: logged
  X <- scale(as.matrix(train[use]), center = s$xm[use], scale = s$xs[use])
  y <- (train$target - s$ym) / s$ys
  f <- withCallingHandlers(
    glmnet::glmnet(X, y, family = 'gaussian', alpha = alpha, lambda = grid,
                   standardize = FALSE, intercept = TRUE,
                   maxit = 1e7),   # raised from 1e5 default: small-lambda ridge on n ~ 9 converges slowly (logged)
    warning = function(w) {
      fit_warnings <<- c(fit_warnings, conditionMessage(w)); invokeRestart('muffleWarning')
    })
  if (length(f$lambda) != length(grid) || any(abs(f$lambda - grid) > 1e-12 * grid))
    stop('Lambda path differs from the grid (truncated/non-converged) - technical failure (Sec. 6).')
  B <- as.matrix(stats::coef(f))                  # (1 + p) x 80, column j = grid[j]
  list(fit = f, B = B, s = s, use = use, dropped = const)
}
predict_path <- function(m, new) {
  X <- scale(as.matrix(new[m$use]), center = m$s$xm[m$use], scale = m$s$xs[m$use])
  P <- cbind(1, X) %*% m$B                        # exact grid lambdas, no interpolation
  P <- P * m$s$ys + m$s$ym                        # back to percentage points
  colnames(P) <- paste0('L', seq_along(grid)); P
}
fit_warnings <- character()

# ---- forward validation ----------------------------------------------------
run_design <- function(alpha, label) {
  preds <- list(); dropped <- list()
  for (k in seq_len(nrow(folds))) {
    cut <- folds$cutoff[k]
    train <- mf[mf$origin < cut & mf$target_mature_at <= cut, ]
    val <- mf[mf$fold == folds$fold[k] & mf$target_mature_at <= dev_cut, ]
    for (sp in names(specs)) {
      m <- fit_path(train, specs[[sp]], alpha)
      dropped[[paste(sp, folds$fold[k])]] <- m$dropped
      P <- predict_path(m, val)
      preds[[length(preds) + 1]] <- data.frame(design = label, model = sp, fold = folds$fold[k],
        origin = val$origin, observed = val$target, n_train = nrow(train),
        P, check.names = FALSE)
    }
  }
  do.call(rbind, preds)
}
pick_lambda <- function(pr, sp) {
  d <- pr[pr$model == sp, ]
  P <- as.matrix(d[, grep('^L[0-9]+$', names(d))])
  mae <- colMeans(abs(P - d$observed))
  best <- min(which(mae <= min(mae) + 1e-8))      # grid is decreasing: first index = larger lambda
  list(index = best, lambda = grid[best], boundary = best %in% c(1, length(grid)),
       pred = P[, best], mae_curve = mae)
}

designs <- list(Ridge = 0, ElasticNet_check = 0.5)
metrics <- list(); lambdas <- list(); allpred <- list(); sel <- list()
for (dn in names(designs)) {
  pr <- run_design(designs[[dn]], dn)
  for (sp in names(specs)) {
    pk <- pick_lambda(pr, sp)
    sel[[paste(dn, sp)]] <- pk
    d <- pr[pr$model == sp, c('design', 'model', 'fold', 'origin', 'observed', 'n_train')]
    d$prediction <- pk$pred
    allpred[[length(allpred) + 1]] <- d
    lambdas[[length(lambdas) + 1]] <- data.frame(design = dn, model = sp, lambda = pk$lambda,
                                                 grid_index = pk$index, boundary_warning = pk$boundary)
  }
}
# M0 persistence on the same cases
base <- allpred[[1]]
m0 <- data.frame(design = 'Baseline', model = 'M0', fold = base$fold, origin = base$origin,
                 observed = base$observed, n_train = base$n_train,
                 prediction = mf$poll_level[match(base$origin, mf$origin)])
allpred <- do.call(rbind, c(list(m0), allpred))

score <- function(d) data.frame(n = nrow(d), MAE = mean(abs(d$prediction - d$observed)),
                                RMSE = sqrt(mean((d$prediction - d$observed)^2)),
                                bias = mean(d$prediction - d$observed))
metrics <- do.call(rbind, lapply(split(allpred, list(allpred$design, allpred$model), drop = TRUE),
                                 function(d) cbind(design = d$design[1], model = d$model[1], score(d))))
metrics <- metrics[order(metrics$design, metrics$model), ]
delta <- function(dn) metrics$MAE[metrics$design == dn & metrics$model == 'M2'] -
                      metrics$MAE[metrics$design == dn & metrics$model == 'M1']
out_of_range <- sum(allpred$prediction < 0 | allpred$prediction > 100)

# ---- final refit on all mature development common cases -------------------
final_train <- mf[mf$target_mature_at <= dev_cut, ]
coefs <- list(); finals <- list()
for (dn in names(designs)) for (sp in names(specs)) {
  m <- fit_path(final_train, specs[[sp]], designs[[dn]])
  lam <- sel[[paste(dn, sp)]]$lambda
  b <- m$B[, sel[[paste(dn, sp)]]$index]
  coefs[[length(coefs) + 1]] <- data.frame(design = dn, model = sp, term = names(b),
                                           coef_standardized = unname(b), lambda = lam)
  finals[[paste(dn, sp)]] <- list(model = m, lambda = lam)
}
coefs <- do.call(rbind, coefs)

# ---- save + freeze manifest ---------------------------------------------------
dir.create('reports/results', recursive = TRUE, showWarnings = FALSE)
utils::write.csv(metrics, 'reports/results/model_metrics.csv', row.names = FALSE)
utils::write.csv(do.call(rbind, lambdas), 'reports/results/selected_lambdas.csv', row.names = FALSE)
utils::write.csv(coefs, 'reports/results/final_coefficients.csv', row.names = FALSE)
utils::write.csv(allpred, 'data/processed/forward_predictions.csv', row.names = FALSE)
saveRDS(list(finals = finals, grid = grid, specs = specs, created = Sys.time(),
             glmnet_version = as.character(utils::packageVersion('glmnet'))),
        'data/processed/fit_freeze.rds')
hash <- function(f) digest::digest(file = f, algo = 'sha256')
man <- c(paste('FIT_AND_CODE_FREEZE manifest -', format(Sys.time(), '%Y-%m-%d %H:%M %Z')),
         paste('glmnet', utils::packageVersion('glmnet'), '| R', getRversion()),
         paste(c('R/08_fit_models.R', 'data/processed/model_frame_monthly.csv',
                 'data/processed/fit_freeze.rds', 'reports/results/model_metrics.csv'),
               vapply(c('R/08_fit_models.R', 'data/processed/model_frame_monthly.csv',
                        'data/processed/fit_freeze.rds', 'reports/results/model_metrics.csv'),
                      hash, character(1))))
writeLines(man, 'reports/results/fit_freeze_manifest.txt')

cat('\nSpain v4.1 - R11 forward validation, 2024 Q1-Q3 (pp; lambdas tuned on these folds)\n\n')
print(metrics[, c('design', 'model', 'n', 'MAE', 'RMSE', 'bias')], row.names = FALSE, digits = 3)
cat('\nDelta MAE (M2 - M1), Ridge:           ', round(delta('Ridge'), 3), ' (negative favors music)\n')
cat('Delta MAE (M2 - M1), Elastic Net check:', round(delta('ElasticNet_check'), 3), '\n')
lam <- do.call(rbind, lambdas)
if (any(lam$boundary_warning)) cat('WARNING: grid-boundary lambda for:',
  paste(lam$design[lam$boundary_warning], lam$model[lam$boundary_warning], collapse = '; '), '\n')
cat('Out-of-range predictions (<0 or >100):', out_of_range, '\n')
cat('Training sizes per fold:', paste(unique(allpred[allpred$model == 'M1', c('fold', 'n_train')])$n_train,
                                      collapse = '/'), '| final refit n =', nrow(final_train), '\n')
if (length(fit_warnings)) { cat('glmnet warnings (', length(fit_warnings), '):\n'); print(table(fit_warnings)) }
cat('Saved: reports/results/*, data/processed/forward_predictions.csv, fit_freeze.rds + manifest\n')
