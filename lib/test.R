######################################################
### Fit the classification model with testing data ###
######################################################

### Author: Yuting Ma
### Project 3
### ADS Spring 2016

test <- function(trained_model, dat_test){
  
  ### Fit the classfication model with testing data
  
  ### Input: 
  ###  - the fitted classification model using training data
  ###  -  processed features from testing images 
  ### Output: training model specification
  
  ### load libraries
  library("gbm")
  
  pred_base <- predict(trained_model$base_model, newdata=dat_test, 
                  n.trees=trained_model$iter_base, type="response")

  pred_improved <- predict(trained_model$improved_model, newdata=dat_test, 
                           n.trees=trained_model$iter_improved, type="response")
  
  answers_base <- as.numeric(pred_base> 0.5)
  answers_improved <- as.numeric(pred_improved> 0.5)
  
  return(list(baseline=answers_base, adv=answers_improved))
}


