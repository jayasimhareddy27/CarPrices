

metrics_lm <- calculate_metrics(ProcessedData_Valid$price, prices_xgb)
metrics_xgb <- calculate_metrics(ProcessedData_Valid$price, prices_lm)

metrics_comparison <- data.frame(
  Metric = c("RMSE", "MAE", "R2", "MAPE"),
  Linear_Regression = unlist(metrics_lm),
  XGBoost = unlist(metrics_xgb)
)

print(metrics_comparison)


alpha=0.1
d_mean <- 0
lm_residuals <- actual_prices - prices_lm
xgb_residuals <- actual_prices - prices_xgb
residual_differences <- lm_residuals - xgb_residuals
n <- length(residual_differences)
mean_diff <- mean(residual_differences)
std_error <- sd(residual_differences) / sqrt(n)


t_critical <- qt(p = alpha / 2, df = n - 1, lower.tail = FALSE)

CI <- c(mean_diff - t_critical * std_error, mean_diff + t_critical * std_error)
cat("Confidence Interval (CI): ", CI, "\n")

cat("Confidence Interval (CI): ", CI, "\n")

# Hypothesis testing
cat("H0: There is no significant difference between XGB and LM (mean difference = 0).\n")
cat("H1: There is a significant difference between XGB and LM (mean difference ≠ 0).\n")

if (CI[1] <= 0 && CI[2] >= 0) {
  cat("Conclusion: Fail to reject H0. The difference in predictions between XGB and LM is NOT statistically significant at 99% confidence.\n")
} else {
  cat("Conclusion: Reject H0. The difference in predictions between XGB and LM is statistically significant at 90% confidence.\n")
}





