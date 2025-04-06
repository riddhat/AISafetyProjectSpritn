library(tidymodels)
library(tidyverse)
library(shapviz)

shap_obj <- shapviz(fitted_model, X_pred = data.matrix(test_x), X = test_x)

shap_obj <- shapviz(xgb_model, X_pred = test_x)

# Two types of Visualizations
sv_waterfall(shap_obj, row_id = 1)
sv_force(shap_obj, row_id = 1)

# Three types of variable importance plots
sv_importance(shap_obj)
sv_importance(shap_obj, kind = "bar")
sv_importance(shap_obj, kind = "both", alpha = 0.2, width = 0.2)