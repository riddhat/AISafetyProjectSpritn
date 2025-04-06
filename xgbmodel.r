# Load required libraries
library(tidyverse)
library(caret)
library(xgboost)

# Read data
ai_jobs <- read.csv("ai_job_market_insights.csv")

# Convert Salary_USD based on the median value and change to factor
med_sal <- median(ai_jobs$Salary_USD, na.rm = TRUE)
ai_jobs$Salary_USD <- ifelse(ai_jobs$Salary_USD >= med_sal, ">= median($91k)", "< median ($91k)")
ai_jobs <- ai_jobs %>% mutate_all(as.factor)

# Split the data into training and testing sets (75/25 split)
set.seed(123)
split <- createDataPartition(ai_jobs$Salary_USD, p = 0.75, list = FALSE)
train <- ai_jobs[split, ]
test <- ai_jobs[-split, ]

# Use model.matrix to convert predictors to a numeric matrix.
# This will one-hot encode factor variables.
train_x <- model.matrix(~ . - Salary_USD, data = train)[, -1]
test_x <- model.matrix(~ . - Salary_USD, data = test)[, -1]

# For classification, use the factor vector for the response.
train_y <- train$Salary_USD
test_y <- test$Salary_USD

# For xgboost we need numeric labels: convert factor levels to numeric 0/1.
# Make sure that the first level corresponds to 0 and the second to 1.
train_label <- as.numeric(train_y) - 1
test_label <- as.numeric(test_y) - 1

# Create xgb.DMatrix objects for training and testing
dtrain <- xgb.DMatrix(data = train_x, label = train_label)
dtest  <- xgb.DMatrix(data = test_x, label = test_label)

# Set up parameters for XGBoost
params <- list(
  objective = "binary:logistic",  # binary classification
  eval_metric = "error",          # error rate 
  max_depth = 4,
  eta = 0.1,
  gamma = 0,
  colsample_bytree = 1,
  min_child_weight = 1,
  subsample = 1
)

# Perform cross-validation to determine the best number of rounds
cv_results <- xgb.cv(
  params = params,
  data = dtrain,
  nrounds = 1000,
  nfold = 5,
  early_stopping_rounds = 10,
  verbose = 1,
  maximize = FALSE
)

best_nrounds <- cv_results$best_iteration
cat("Best number of rounds:", best_nrounds, "\n")

# Train the final model using the best number of rounds from CV
watchlist <- list(train = dtrain, eval = dtest)
xgb_model <- xgb.train(
  params = params,
  data = dtrain,
  nrounds = best_nrounds,
  watchlist = watchlist,
  early_stopping_rounds = 10,
  print.every.n = 10
)

# Make predictions on the test set
xgb_pred <- predict(xgb_model, newdata = dtest)
# Convert probabilities to binary class labels (0/1) using 0.5 threshold
xgb_pred_class <- ifelse(xgb_pred > 0.5, 1, 0)

# Evaluate the model using confusionMatrix from caret
conf_mat <- confusionMatrix(
  factor(xgb_pred_class, levels = c(0,1)),
  factor(test_label, levels = c(0,1))
)

print(conf_mat)