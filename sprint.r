library(tidyverse)
library(caret)
library(xgboost)

ai_jobs <- read.csv("ai_job_market_insights.csv")

# Convert Salary_USD based on the median value
med_sal <- median(ai_jobs$Salary_USD, na.rm = TRUE)
ai_jobs$Salary_USD <- ifelse(ai_jobs$Salary_USD >= med_sal, ">= median($91k)", "< median ($91k)")
ai_jobs <- ai_jobs %>% mutate_all(as.factor)

# Split the data into training and testing sets
set.seed(123)
split <- createDataPartition(ai_jobs$Salary_USD, p = 0.75, list = FALSE)
train <- ai_jobs[split, ]
test <- ai_jobs[-split, ]

# Use model.matrix to convert predictors to numeric matrix
train_x <- model.matrix(~ . - Salary_USD, data = train)[, -1]
test_x <- model.matrix(~ . - Salary_USD, data = test)[, -1]

# For classification, use the factor vector directly
train_y <- train$Salary_USD
test_y <- test$Salary_USD

# Define grid for tuning
grid_tune <- expand.grid(
  nrounds = c(500, 1000, 1500),
  max_depth = c(2, 3, 4),
  eta = 0.3,
  gamma = 0,
  colsample_bytree = 1,
  min_child_weight = 1,
  subsample = 1
)

# Set up trainControl
train_control <- trainControl(
  method = "cv", #cross validation
  number = 3, #3 folds
  verboseIter = TRUE,
  allowParallel = TRUE
)

# Run the tuning process using caret's train function
xgb_tune <- train(
  x = train_x,
  y = train_y,
  trControl = train_control,
  tuneGrid = grid_tune,
  method = "xgbTree",
  verbose = TRUE
)

# Inspect the tuned model
print(xgb_tune)

xgb_tune$bestTune

train_control <- trainControl(
  method = "none",
  verboseIter = TRUE,
  allowParallel = TRUE
)

final_grid <- expand.grid(
  nrounds = xgb_tune$bestTune$nrounds,
  max_depth = xgb_tune$bestTune$max_depth,
  eta =  xgb_tune$bestTune$eta,
  gamma = xgb_tune$bestTune$gamma,
  colsample_bytree = xgb_tune$bestTune$colsample_bytree,
  min_child_weight = xgb_tune$bestTune$min_child_weight,
  subsample = xgb_tune$bestTune$subsample
)

xgb_model <- train(
    x = train_x,
    y = train_y,
    trControl = train_control,
    tuneGrid = final_grid,
    method = "xgbTree",
    verbose = TRUE
)

xgb.pred <- predict(xgb_model, test_x)

confusionMatrix(xgb.pred, test_y)
