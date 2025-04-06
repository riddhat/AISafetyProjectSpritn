library(tidyverse)
library(caret) #maching learning library
library(xgboost) #XGBoost library
library(mltools)
library(ggplot2)


ai_jobs <- read.csv("ai_job_market_insights.csv")

head(ai_jobs)

# Get column names
col_names <- colnames(ai_jobs)
print(col_names)
