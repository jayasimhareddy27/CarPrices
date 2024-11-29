#install.packages("DT")
#install.packages("bsicons")

library(DT)
library(shiny)
library(bslib)
library(sodium)
library(tidyverse)
library(bsicons)
library(reticulate)
reticulate::py_install("pandas")
reticulate::py_install("numpy")
reticulate::py_install("pyreadr")
reticulate::py_install("scipy")
reticulate::py_install("scikit-learn")
py_config()


source("Vars/Globalvars.R")
