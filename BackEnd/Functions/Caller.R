DealWith_Duplicates <- function(df){
  ## Duplicate values
  print("1)Dealing with Duplicate values.... ")
  Is_duplicate <- df %>% distinct() %>% count() == Cars_Kaggle %>% nrow()
  ifelse(Is_duplicate,print("No Duplicates"),print("Duplicates Exists"))
  print("1)Done with Duplicate values.... ")
}

DealWith_MissingValues <- function(df){
  print("2)Dealing with missing values.... ")
  ImputedData <- reduce(grouping_levels, 
                        ~ impute_missing_values(.x, .y, columns_to_impute), 
                        .init = df
                        )
  ImputedData %>% select(-clean_title)
  print("2)Done with missing values: ")
  return(ImputedData)
}

DealWith_Outliers <- function(df1,df2){
  print("3)Dealing with Outlier values.... ")
  df1 <- df1 %>% group_by(brand, model,model_year,engine) %>%
    group_modify(~ Remove_outliers(.x)) %>%
    ungroup()
  
  Outliers_Checking<- df2 %>% filter(!id %in% df1$id)
  print(paste("No of Outliers removed: ", Outliers_Checking %>% nrow()))
  return(df1)
}

DealWith_ExtractingEngineFeatures <- function(df){
  print("3)Dealing with extracting engine features values.... ")
  Engine_Featured_Data<- df  %>% extract_engine_features()
  print("3)Done with extracting engine features values.... ")
  return(Engine_Featured_Data)
}


DealWith_MissingValuesFinal <- function(df){
  print("4)Dealing with missing values for the last time.... ")
  df <- df %>%
    mutate(
      fuel_type = if_else(is.na(fuel_type) |  fuel_type== "–"|  fuel_type== "","Electric/Hybrid", fuel_type),
      accident = if_else(is.na(accident) |  accident== "–"|  accident== "","Didnt report", accident),
    ) 
  df <- reduce(grouping_levels, ~ impute_missing_values(.x, .y, NumericMutate_miss),.init = df)
  df <- df %>%
    mutate(across(NumericMutate_miss, ~ ifelse(is.na(.) | . == "–" | . =="MISSING", Common_Imputer_GroupMode(.), .)))
  
  print(df %>% summarise(across(everything(), ~ sum(is.na(.)))))
  print("4)Done with missing values for the last time...")
  
#temp <- Engine_Featured_Data %>% group_by(cylinder_number) %>% count()
#temp <- Engine_Featured_Data %>% group_by(engine_displacement) %>% count()
#temp <- Engine_Featured_Data %>% group_by(engine_valves) %>% count()
#df <-  df %>% select(c(-engine_valves,engine_displacement,cylinder_number))

  return(df)
}

DealWith_Converstions <- function(df){
  print("5)Dealing with Converstion of data for easy modeling")
  df <- df %>%
    mutate(across(all_of(ToFactors), ~ as.factor(.))) %>%
    mutate(across(all_of(NumericMutate_miss), ~ as.numeric(.)))
  ProcessedData <- df%>% select(c(-engine,-id))
  print("5)Done with Converstion of data for easy modeling")
  return(ProcessedData)
}


OneHotEncoder_R <- function(Data){
  print("6)Dealing with Onehot encoding")
  dummies <- dummyVars("~ .", data = Data, fullRank = TRUE,sep = "_") 
  Data_encoded <- predict(dummies, newdata = Data)
  Data_encoded <- as.data.frame(Data_encoded)  
  print("6)Done with Onehot encoding")
  return(Data_encoded)
}


Scaler_R <- function(Data) {
  print("7)Dealing with Normalisation of data")
  columns_to_scale <- c("model_year", "milage", "engine_horsepower")
  
  scaler <- preProcess(Data[, columns_to_scale], method = c("center", "scale"))
  Data_scaled <- Data  # Create a copy to maintain the original data
  Data_scaled[, columns_to_scale] <- predict(scaler, newdata = Data[, columns_to_scale])
  
  print("7)Done with Dealing Normalisation of data")
  return(as.data.frame(Data_scaled))  # Return scaled data as a data frame
}

