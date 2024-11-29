library(reticulate)
#reticulate::py_install("pandas")
#reticulate::py_install("numpy")
#reticulate::py_install("pyreadr")
#reticulate::py_install("scipy")
#reticulate::py_install("scikit-learn")
py_config()




#Simple_LinearModel <- lm(price~.,data=ProcessedData_Train)




source_python("Models/ScratchLM/multiple_linear_regression.py")
source_python("Models/ScratchLM/SaveLM.py")



#Record1<- ProcessedData_Test %>% head(2) %>% select(-price)
#glimpse(Record1)

source_python("Models/ScratchLM/loadLM_Predict.py")
prices_lm <- predict_car_prices_LM(Records)

#price<- predict_car_prices_LM(Record1)
#price
#ProcessedData_Test %>% head(2)

lr_metrics <- extract_lm_metrics(cv_results_lr,5) 
BestParamets_LM<- lr_metrics[41:45, ]


fold_summary_lm <- lr_metrics %>%
  group_by(Fold) %>%
  summarize(
    Avg_RMSE = mean(RMSE, na.rm = TRUE),
    Avg_MAE = mean(MAE, na.rm = TRUE),
    Avg_R2 = mean(R2, na.rm = TRUE),
)
fold_summary_lm_long <- fold_summary_lm %>%
  pivot_longer(cols = starts_with("Avg"), names_to = "Metric", values_to = "Value")

ggplot(fold_summary_lm_long, aes(x = Fold, y = Value, color = Metric, group = Metric)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  labs(
    title = "XGBoost Metrics Across Folds",
    x = "Fold",
    y = "Metric Value",
    color = "Metric"
  ) 

BestParamets_LM_long <- BestParamets_LM %>%
  pivot_longer(cols = c("RMSE", "MAE", "R2", "MAPE"), names_to = "Metric", values_to = "Value")

ggplot(BestParamets_LM_long, aes(x = Fold, y = Value, color = Metric)) +
  geom_line(size = 1) + 
  geom_point(size = 2) +
  facet_wrap(~ Metric, scales = "free_y") + 
  labs(
    title = "Linear Regression Metrics Across Folds",
    x = "Fold",
    y = "Metric Value"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none", 
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold")
  )
