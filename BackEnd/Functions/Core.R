##FUNCTIONS
impute_missing_values <- function(data, group_vars, cols_to_impute) {
  data %>%
    group_by(across(all_of(group_vars))) %>%
    mutate(across(
      all_of(cols_to_impute),
      ~ if_else(. %in% c("–", "", "MISSING") | is.na(.), Common_Imputer_GroupMode(.), .)
    )) %>%
    ungroup()
}


#Imputing missing values of ext_col , int_col
Common_Imputer_GroupMode <- function(v) {
  v <- v[!is.na(v) & v != "–"]
  if (length(v) == 0) {
    return("MISSING")
  } else {
    value_counts <- table(v)
    return(names(value_counts)[which.max(value_counts)])
  }
}    

#divide test and train dataset without replacement by ratio (80:20 , train:test) data to avoid overfitting of model
Splitter<- function(df) {
  inds <- partition(df$brand,
                    type = c("stratified"),seed = 123, 
                    p = c(train = 0.8, valid = 0.1, test = 0.1))
  return(inds)
}

#remove outliers
Remove_outliers <- function(df) {
  Q1 <- quantile(df$price, 0.25, na.rm = TRUE)
  Q3 <- quantile(df$price, 0.75, na.rm = TRUE)
  IQR_value <- IQR(df$price, na.rm = TRUE)
  lower_bound <- Q1 - 1.5 * IQR_value
  upper_bound <- Q3 + 1.5 * IQR_value
  df<- df %>%filter(price >= lower_bound & price <= upper_bound)
  return(df)
}


 
extract_engine_features <- function(df) {
  df <- df %>% mutate(engine=str_to_lower(str_squish(engine)))
  
  HorsePower <- data.frame(df %>% pull(engine) %>% str_match(".*([0-9]+)(?=hp)")) %>% select(X1)%>% pull()
  
  engine_displacement <- data.frame( df %>%pull(engine) %>% str_match("([0-9].[0-9])(?=(?:l|.liter|liter))") )%>% select(X1) %>% pull()
  cylinder_Number <- data.frame(
    df %>% pull(engine) %>% 
      str_match("(.([0-9]+)(?=.cylinder engine))|(v([0-9]+))|(i([0-9]+))|(v-([0-9]+))|(h([0-9]+))|(w([0-9]+))")
  ) %>% 
    select(X3,X5,X7,X9,X11,X13) %>%   
    mutate(cylinder_filled = coalesce(X3, X5, X7, X9, X11, X13))%>% 
    select(cylinder_filled) %>% pull()
  engine_valves <- data.frame( df %>%pull(engine) %>% str_match(".([0-9]+)(?=v)")) %>% select(X1) %>% pull()
  
  df<- df %>% mutate(
    engine_technology = str_extract_all(engine, "\\b(pdi|dohc|sohc|gdi|mpi|mpfi|pfi|tsi)\\b") %>%
      sapply(function(x) if(length(x) > 0) paste(unique(x), collapse = ", ") else "None"),
    
    engine_special = case_when(
      str_detect(engine, "twin turbo") ~ "Twin Turbo",
      str_detect(engine, "turbocharged|turbo") ~ "Turbocharged",
      str_detect(engine, "supercharged") ~ "Supercharged",
      TRUE ~ "None"
    ),
    engine_configuration = case_when(
      str_detect(engine, "v[0-9]+") ~ "V",
      str_detect(engine, "w[0-9]") ~ "W",
      str_detect(engine, "h[0-9]") ~ "Flat",
      str_detect(engine, "i[0-9]+") ~ "Inline",
      str_detect(engine, "flat") ~ "Flat",
      str_detect(engine, "cylinder") ~ "straight",
      str_detect(engine, "straight") ~ "Straight",
      str_detect(engine, "rotary") ~ "Rotary",
      TRUE ~ "Inline"
    )
  )
  df$engine_horsepower <- HorsePower
  df$engine_displacement <- engine_displacement
  df$cylinder_number <- cylinder_Number
  df$engine_valves <- engine_valves
  
  return(df)
}

print_model_summary <- function(model, step) {
  # Define folder paths
  full_folder <- "Save/fullsummary/"
  short_folder <- "Save/shortsummary/"
  
  # Create file paths dynamically using the step number
  full_file_path <- paste0(full_folder, "Step_", step, ".txt")
  short_file_path <- paste0(short_folder, "Step_", step, ".txt")
  
  # Save full summary
  full_summary_text <- capture.output(summary(model))
  writeLines(full_summary_text, full_file_path)
  
  # Save short summary
  model_summary <- summary(model)
  r_squared_text <- sprintf("Step %d:\nMultiple R-squared:  %.4f,\tAdjusted R-squared:  %.4f \n", 
                            step, model_summary$r.squared, model_summary$adj.r.squared)
  
  f_statistic_text <- sprintf("F-statistic: %.2f on %d and %d DF,  p-value: %s\n", 
                              model_summary$fstatistic[1], 
                              model_summary$fstatistic[2], 
                              model_summary$fstatistic[3],
                              ifelse(pf(model_summary$fstatistic[1], 
                                        model_summary$fstatistic[2], 
                                        model_summary$fstatistic[3], 
                                        lower.tail = FALSE) < 2.2e-16, "< 2.2e-16", 
                                     format(pf(model_summary$fstatistic[1], 
                                               model_summary$fstatistic[2], 
                                               model_summary$fstatistic[3], 
                                               lower.tail = FALSE), scientific = TRUE)))
  
  short_file_conn <- file(short_file_path, "w")
  cat(r_squared_text, file = short_file_conn)
  cat(f_statistic_text, file = short_file_conn)
  close(short_file_conn)
}




calculate_rmse <- function(actual, predicted) {
  sqrt(mean((actual - predicted)^2))
}

calculate_metrics <- function(actual, predicted) {
  rmse <- sqrt(mean((actual - predicted)^2))  # Root Mean Squared Error
  mae <- mean(abs(actual - predicted))       # Mean Absolute Error
  r2 <- 1 - (sum((actual - predicted)^2) / sum((actual - mean(actual))^2))  # R-squared
  mape <- mean(abs((actual - predicted) / actual)) * 100  # Mean Absolute Percentage Error
  
  return(list(RMSE = rmse, MAE = mae, R2 = r2, MAPE = mape))
}

extract_lm_metrics <- function(cv_results, num_folds=5) {
  Df_cv_results_LM <- data.frame()
  fold_index <- 1
  
  for (variable in cv_results$fold_results) {
    for (fold_metric in variable$fold_metrics) {
      # Extract metrics for each CV
      fold_metrics <- c(
        Fold = fold_index,
        RMSE = fold_metric$rmse,
        MAE = fold_metric$mae,
        R2 = fold_metric$r2,
        MAPE = fold_metric$mape
      )
      
      Df_cv_results_LM <- rbind(Df_cv_results_LM, fold_metrics)
      
      fold_index <- ifelse(fold_index == num_folds, 1, fold_index + 1)
    }
  }
  
  colnames(Df_cv_results_LM) <- c("Fold", "RMSE", "MAE", "R2", "MAPE")
  
  return(Df_cv_results_LM)
}
extract_xgb_metrics <- function(cv_results, num_folds=5) {
  Df_cv_results_Xgb <- data.frame()
  fold_index <- 1
  
  for (variable in cv_results$fold_results) {
      # Extract metrics for each CV
      fold_metrics <- c(
        Fold = fold_index,
        RMSE = variable$rmse,
        MAE = variable$mae,
        R2 = variable$r2,
        MAPE = variable$mape
      )
      
      Df_cv_results_Xgb <- rbind(Df_cv_results_Xgb, fold_metrics)
      
      fold_index <- ifelse(fold_index == num_folds, 1, fold_index + 1)
    
  }
  
  colnames(Df_cv_results_Xgb) <- c("Fold", "RMSE", "MAE", "R2", "MAPE")
  
  return(Df_cv_results_Xgb)
}

