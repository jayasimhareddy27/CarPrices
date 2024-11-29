backwardElimination <- function(x, sl) {
  # Ensure 'price' is not treated as a removable column
  if ("price" %in% names(x)) {
    predictors = x[, !names(x) %in% "price"]  # Extract independent variables
    x = cbind(price = x$price, predictors)    # Ensure 'price' remains as the dependent variable
  }
  
  numVars = ncol(x) - 1  # Exclude 'price' column from count of independent variables
  step = 1
  
  cat("Starting Backward Elimination...\n")
  
  for (i in seq_len(numVars)) {
    cat(sprintf("Step %d: Fitting regression model...\n", step))
    regressor = lm(formula = price ~ ., data = x)
    summary_reg = summary(regressor)
    
    # Identify the variable with the highest p-value among predictors
    p_values = coef(summary_reg)[-1, "Pr(>|t|)"]  # Exclude intercept
    maxVar = max(p_values)
    
    if (maxVar > sl) {
      # Find the variable to remove
      j = which(p_values == maxVar)
      var_to_remove = names(p_values)[j]
      cat(sprintf("Variable '%s' has p-value %f, exceeding the significance level %f.\n", 
                  var_to_remove, maxVar, sl))
      cat(sprintf("Removing variable '%s'...\n", var_to_remove))
      
      # Remove the variable from the dataset
      x = x[, !names(x) %in% var_to_remove]
    } else {
      cat("All remaining variables are significant. Stopping elimination.\n")
      break
    }
    
    numVars = ncol(x) - 1  # Update the number of independent variables
    print_model_summary(regressor,step)  # Save full and short summaries of the model
    step = step + 1
    cat("Model updated. Continuing...\n")
    cat("---------------------------------------------------\n")
  }
  
  cat("Backward Elimination completed.\n")
  #return(summary(regressor))
}

#using backwardElimination techinique with significance level==0.05 i.e with confidence 95%
#we found out the following features as the significant features to impact the model:
#price,model,brand,milage,fuel_type,transmission,accident, engine_technology,engine_special,engine_configuration,engine_horsepower

SL = 0.05  # significance level
options(max.print = 1e6)  
DATA_BACKELE<- Web_Purpose_ProcessedData[inds$train, ] %>% select(-engine_valves,-clean_title,-engine_displacement)
backwardElimination(DATA_BACKELE, SL)
