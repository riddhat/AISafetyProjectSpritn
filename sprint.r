library(tidyverse)
library(caret) #maching learning library
library(xgboost) #XGBoost library
library(mltools)
library(ggplot2)

ai_jobs <- read.csv("ai_job_market_insights.csv")

head(ai_jobs)

med_sal <- median(ai_jobs$Salary_USD)

ai_jobs$Salary_USD <- ifelse(ai_jobs$Salary_USD >= med_sal, 1, 0)

split <- createDataPartition(ai_jobs$Salary_USD, p = 0.75, list = FALSE)
train <- ai_jobs[split, ]
test <- ai_jobs[-split, ]

train_x <- data.matrix(select(train, -Salary_USD))
train_y <- data.matrix(select(train, Salary_USD))


# Get column names
col_names <- colnames(ai_jobs)
print(col_names)

summary(ai_jobs)

med_sal <- median(ai_jobs$Salary_USD, na.rm=TRUE)

ai_jobs$Salary_USD <- ifelse(ai_jobs$Salary_USD >= med_sal, 1, 0)

