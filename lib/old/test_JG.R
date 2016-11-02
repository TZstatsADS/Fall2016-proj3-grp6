######################################################
### Fit the classification model with testing data ###
######################################################

### Author: Yuting Ma
### Project 3
### ADS Spring 2016

test <- function(fit_train, dat_test){
  
  cat("Entering Prediction Block \n")
  ### Fit the classfication model with testing data
  
  ### Input: 
  ###  - the fitted classification model using training data
  ###  -  processed features from testing images 
  ### Output: training model specification
  
  ### load libraries
  library("gbm")
  
  if(!is.null(fit_train$pca.data)){
    dat_test <- dat_test %*% fit_train$pca.data$rotation
    dat_test <- dat_test[,1:500]
  }
  
  pred <- predict(fit_train$fit, newdata=dat_test, 
                  n.trees=fit_train$iter, type="response")
  
  return(as.numeric(pred> 0.5))
}

test.JG <- function(trained.model, params, dat.test){

  # Extract relevant values
  model <- trained.model$model
  use.columns <- trained.model$use.columns
  transf.matrix <- trained.model$transformation.matrix
  dimZ <- params[[1]][3]
  
  
  dat.test.columns <- dat.test[,use.columns]
  
#  cat("Dimensions of dat.test.columns: ",dim.data.frame(dat.test.columns), "\n")
#  cat("Dimensions of T: ",dim(transf.matrix), "\n")
  
  dat.test.z <- as.matrix(dat.test.columns) %*% transf.matrix
  
#  cat("Number of columns in test.columns:", ncol(dat.test.columns), "\n")
#  cat("Dimensions of dat.test.z:", dim(dat.test.z), "\n")
  
  ## Only the two first columns
  dat.test.z <- dat.test.z[,1:dimZ]
  
  
  pred <- predict(model, newdata = dat.test.z)
  
  pred.out <- as.array(as.numeric(pred))
  
  cat("Pred.out: ", head(pred.out), " ", typeof(pred.out), "\n")
#  pred.out <- pred.out - 1
#  cat("Pred.out - 1 : ", head(pred.out), " ", typeof(pred.out), "\n")
#  pred.out <- factor(x = pred.out, levels = c(0,1))
#  cat("Pred.out factor : ", pred.out, " ", typeof(pred.out), "\n")
  
  cat("DONE Prediction \n")
  
  return(pred.out)
}

