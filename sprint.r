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

summary(ai_jobs)

med_sal <- median(ai_jobs$Salary_USD, na.rm=TRUE)

ai_jobs$Salary_USD <- ifelse(ai_jobs$Salary_USD >= med_sal, 1, 0)

