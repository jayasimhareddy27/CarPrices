#VARIABLES FOR ANAYTLCIS ON SHINYR

#load("DATASETS/ProcessedData.RData")
#load("DATASETS/inds.RData")


ProcessedData <- read.csv(file = "DATASETS/Web_Purpose_ProcessedData.csv") %>% select(-1)
ModelPurposeData <- read.csv(file = "DATASETS/ProcessedData.csv") %>% select(-1)




BrandType <- c("Bentley","Maserati","Lamborghini","Rolls-Royce","Ferrari","McLaren","Aston","Maybach")
top_10_br <-c("Tesla","Toyota","BYD","Ferrari","Mercedes-Benz","Porsche","BMW","Xiaomi","Volkswagen","Honda")
CarDistribution_BY_year <- ProcessedData %>% group_by(model_year) %>% summarise(Count=n())
CarBrands_year <- ProcessedData %>% group_by(brand,model_year) %>% summarise(Count=n())




Unique_Brands <- ProcessedData %>% select(brand) %>%  unique() %>% arrange(brand) 
Unique_model <- ProcessedData %>% select(model) %>%  unique() %>% arrange(model) 
Brands_years <- ProcessedData %>% select(model_year) %>%  unique() %>% arrange(model_year) 
Unique_fuel_type <- ProcessedData %>% select(fuel_type) %>%  unique() %>% arrange(fuel_type)
Unique_transmission <- ProcessedData %>% select(transmission) %>%  unique() %>% arrange(transmission) 
Unique_ext_col <- ProcessedData %>% select(ext_col) %>% unique() %>% arrange(ext_col) 
Unique_int_col <- ProcessedData %>% select(int_col) %>%  unique() %>%  arrange(int_col) 
Unique_accident <- ProcessedData %>%  select(accident) %>%  unique() %>%  arrange(accident) 
Unique_clean_title <- ProcessedData %>% select(clean_title) %>%  unique() %>%  arrange(clean_title) 
Unique_engine_horsepower <- ProcessedData %>% select(engine_horsepower) %>%  unique() %>%  arrange(engine_horsepower) 
Unique_engine_displacement <- ProcessedData %>% select(engine_displacement) %>%  unique() %>%  arrange(engine_displacement)
Unique_engine_configuration <- ProcessedData %>%  select(engine_configuration) %>%  unique() %>%  arrange(engine_configuration)
Unique_cylinder_number <- ProcessedData %>% select(cylinder_number) %>%  unique() %>%  arrange(cylinder_number)
Unique_engine_valves <- ProcessedData %>% select(engine_valves) %>%  unique() %>%  arrange(engine_valves) 
Unique_engine_technology <- ProcessedData %>% select(engine_technology) %>% unique() %>% arrange(engine_technology) 
Unique_engine_special <- ProcessedData %>%  select(engine_special) %>%  unique() %>%  arrange(engine_special) 


 
ToFactors <- c("brand","FuelType","Transmission","Accident",
               "EngineConfiguration","EngineTechnology","EngineSpecial")

DealWith_Converstions <- function(df){
  print("5)Dealing with Converstion of data for easy modeling")
  df <- df %>%
    mutate(across(all_of(ToFactors), ~ as.factor(.))) 
  print("5)Done with Converstion of data for easy modeling")
  return(df)
}

ModelPurposeData <- ModelPurposeData %>% DealWith_Converstions()







ModelPurposeDataColnames <- ModelPurposeData %>% select(-price) %>% colnames()


numeric_data <- ModelPurposeData %>%
  select(where(is.numeric)) %>%
  mutate(log_price = log(price + 1)) %>%  # Add log-transformed price
  select(-price) 
