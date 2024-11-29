library(reticulate)
#reticulate::py_install("pandas")
#reticulate::py_install("numpy")
#reticulate::py_install("pyreadr")
#reticulate::py_install("scipy")
#reticulate::py_install("scikit-learn")
py_config()




source_python("Models/ScratchXGBoost/Xgboost.py")
source_python("Models/ScratchXGBoost/SaveXGBoost.py")


source_python("Models/ScratchXGBoost/loadXGBoost_predict.py")
prices_xgb <- predict_car_prices_XGB(Records)

xgb_metrics <- extract_xgb_metrics(cv_results_xgb,5)
BestParamets_XGB<- xgb_metrics[15:20, ]

fold_summary_xgb <- xgb_metrics %>%
  group_by(Fold) %>%
  summarize(
    Avg_RMSE = mean(RMSE, na.rm = TRUE),
    Avg_MAE = mean(MAE, na.rm = TRUE),
    Avg_R2 = mean(R2, na.rm = TRUE),
)


fold_summary_xgb_long <- fold_summary_xgb %>%
  pivot_longer(cols = starts_with("Avg"), names_to = "Metric", values_to = "Value")

# Plot for XGBoost
ggplot(fold_summary_xgb_long, aes(x = Fold, y = Value, color = Metric, group = Metric)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  labs(
    title = "XGBoost Metrics Across Folds",
    x = "Fold",
    y = "Metric Value",
    color = "Metric"
  ) 


BestParamets_XGB_long <- BestParamets_XGB %>%
  pivot_longer(cols = c("RMSE", "MAE", "R2", "MAPE"), names_to = "Metric", values_to = "Value")

ggplot(BestParamets_XGB_long, aes(x = Fold, y = Value, color = Metric)) +
  geom_line(size = 1) + 
  geom_point(size = 2) +
  facet_wrap(~ Metric, scales = "free_y") + 
  labs(
    title = "XGB Metrics Across Folds",
    x = "Fold",
    y = "Metric Value"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none", 
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold")
  )




#Record1<- ProcessedData_Test %>% head(5) %>% select(-price)
#glimpse(Record1)



#predict_car_prices_XGB(Record1)
