options(max.print = 1e6)  

output_file <- "console_output.txt"
sink(output_file)
source("Global Variables.R")
source("./Functions/Core.R")
source("./Functions/Caller.R")

## clean Duplicate values
DealWith_Duplicates(Cars_Kaggle)

## clean missing values
ImputedData <- DealWith_MissingValues(Cars_Kaggle)

## Adding New column for category type of car



## outliers
ImputedData <- DealWith_Outliers(ImputedData,Cars_Kaggle)


## extracting engine features
Engine_Featured_Data <- DealWith_ExtractingEngineFeatures(ImputedData)



## final iteration of missing values
Engine_Featured_Data <- DealWith_MissingValuesFinal(Engine_Featured_Data)


#Engine_Featured_Data_Scaled <- Engine_Featured_Data %>% mutate(price = log(price))

##  Conversions
ProcessedData <- DealWith_Converstions(Engine_Featured_Data)






inds <- Splitter(ProcessedData)
Web_Purpose_ProcessedData <- ProcessedData 
write.csv(Web_Purpose_ProcessedData, file = "Datasets/Web_Purpose_ProcessedData.csv")
write.csv(Web_Purpose_ProcessedData, file = "../FrontEnd/DATASETS/Web_Purpose_ProcessedData.csv")

## Feature selection using backward elimination is done already and these are main features obtained, 
#The code for this is commented since this is not required to run everytime
## Backward Eliminator
#options(max.print = 1e6)  
#source("./Models/BackwardEliminator.R")



## Scaling Data
#ProcessedData <- Scaler_R(ProcessedData)



ProcessedData <- ProcessedData %>% select(c(price,
                                            brand,
                                            ModelYear=model_year,Milage=milage,EngineHorsepower=engine_horsepower,
                                            FuelType=fuel_type,Transmission=transmission,Accident=accident,
                                            EngineTechnology=engine_technology,EngineSpecial=engine_special,EngineConfiguration=engine_configuration)) 
# Dimensionality reduction
# reason for linear model: 
# feature selection has already been applied to remove unnecessary features, ensuring that the dataset retains only the most relevant ones, 
# It is not necessarily a condition to avoid dimension reduction technique if we apply feature selection but
# applying further Dimensionality reduction could risk removing valuable information. since the model is able to take less time after all the optimizations
# we concluded to not use Dimensionalityreduction

# reason for XGBoost: 
# XGBoost is designed to efficiently handle large feature sets and can automatically assess feature importance during training. 
# Due to its robust ability to capture complex relationships, Dimensionality reduction is not necessary. 
# In fact, reducing the feature set might remove important interactions that XGBoost could otherwise leverage for better predictions.



# split data

ProcessedData_Train <- ProcessedData[inds$train, ]
ProcessedData_Valid <- ProcessedData[inds$valid, ] 
ProcessedData_Test <- ProcessedData[inds$test, ] 

write.csv(ProcessedData, file = "Datasets/ProcessedData.csv")
write.csv(ProcessedData, file = "../FrontEnd/DATASETS/ProcessedData.csv")

write.csv(ProcessedData_Train, file = "Datasets/ProcessedData_Train.csv")
write.csv(ProcessedData_Train, file = "../FrontEnd/DATASETS/ProcessedData_Train.csv")


write.csv(ProcessedData_Test, file = "Datasets/ProcessedData_Test.csv")
write.csv(ProcessedData_Test, file = "../FrontEnd/DATASETS/ProcessedData_Test.csv")

write.csv(ProcessedData_Valid, file = "Datasets/ProcessedData_Valid.csv")
write.csv(ProcessedData_Valid, file = "../FrontEnd/DATASETS/ProcessedData_Valid.csv")



## Onehot encoded DATA
OnehotencodedData <- OneHotEncoder_R(ProcessedData)
write.csv(OnehotencodedData, file = "Datasets/OnehotencodedData.csv")
write.csv(OnehotencodedData, file = "../FrontEnd/DATASETS/OnehotencodedData.csv")


OnehotencodedData_Train <- OnehotencodedData[inds$train, ]
write.csv(OnehotencodedData_Train, file = "Datasets/OnehotencodedData_Train.csv")
write.csv(OnehotencodedData_Train, file = "../FrontEnd/DATASETS/OnehotencodedData_Train.csv")

OnehotencodedData_Valid <- OnehotencodedData[inds$valid, ] 
write.csv(OnehotencodedData_Valid, file = "Datasets/OnehotencodedData_Valid.csv")
write.csv(OnehotencodedData_Valid, file = "../FrontEnd/DATASETS/OnehotencodedData_Valid.csv")

OnehotencodedData_Test <- OnehotencodedData[inds$test, ] 
write.csv(OnehotencodedData_Test, file = "Datasets/OnehotencodedData_Test.csv")
write.csv(OnehotencodedData_Test, file = "../FrontEnd/DATASETS/OnehotencodedData_Test.csv")



#Train data
library(dplyr)
Records<- ProcessedData_Valid %>% select(-price)
actual_prices <- ProcessedData_Valid$price

source("./Models/Linearmodel.R")
source("./Models/XGBoost.R")





best_alpha <- 41     # 1.623776739188721
best_depth <- 16     # 6
source("Model_Comparision.R")





