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

#We set the seed so the randomization can be reproducible
set.seed(123)

#Split the data to testing and training sets
split_ai_job <- initial_split(data= ai_jobs, prop = 0.75, strata = Salary_USD)
ai_job_training <- training(split_ai_job)
ai_job_testing <- testing(split_ai_job)