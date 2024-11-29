#install.packages("splitTools")

#install.packages("xgboost")
library(DT)
library(shiny)
library(bslib)
library(tidyverse)
library(bsicons)
library(purrr)
library(splitTools)
library(xgboost)
library(caret)


## Dataset variables and column names
Cars_Kaggle<- read.csv("Datasets/train.csv") 

grouping_levels <- list(
  c("brand", "model", "model_year"),
  c("brand", "model"),
  c("brand")
)

columns_to_impute <- c("ext_col", "int_col", "engine", "transmission")

NumericMutate_miss<- c("engine_horsepower","cylinder_number","engine_displacement","engine_valves")

ToFactors <- c("brand","model","fuel_type","transmission","ext_col","int_col","accident",
               "engine_configuration","engine_technology","engine_special")

 