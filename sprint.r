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


# Get column names
col_names <- colnames(ai_jobs)
print(col_names)

summary(ai_jobs)


med_sal <- median(ai_jobs$Salary_USD, na.rm = TRUE)

ai_jobs$Salary_USD <- ifelse(ai_jobs$Salary_USD >= med_sal, ">= median($91k)", "< median ($91k)")

ai_jobs <- ai_jobs %>% mutate_all(as.factor)

#We set the seed so the randomization can be reproducible
set.seed(123)

#Split the data to testing and training sets
split <- createDataPartition(ai_jobs$Salary_USD, p = 0.75, list = FALSE)
train <- ai_jobs[split, ]
test <- ai_jobs[-split, ]

train_x <- as.matrix(select(train, -Salary_USD)) #train on every other variable except Salary
train_y <- as.matrix(select(train, Salary_USD))  #response variable matrix

test_x <- as.matrix(select(test, -Salary_USD))
test_y <- as.matrix(select(test, Salary_USD))

xgb_train <- xgb.DMatrix(data = train_x, label = train_y)
xgb_test <- xgb.DMatrix(data = test_x, label = test_y)

head(ai_jobs)
head(train_x)

