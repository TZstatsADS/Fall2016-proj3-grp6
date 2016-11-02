#########################################################
### Train a classification model with training images ###
#########################################################

### Author: Yuting Ma
### Project 3
### ADS Spring 2016


train <- function(dat_train, label_train, par=NULL){
  
  ### Train a Gradient Boosting Model (GBM) using processed features from training images
  
  ### Input: 
  ###  -  processed features from images (rows are images, columns are features)
  ###  -  class labels for training images
  ### Output: training model specification
  
  ### load libraries
  library("gbm")
  
  # For the baseline model, we only use the SIFT features and decision stubs (depth = 1)
  cat("Starting Baseline model Training \n")
  depth_base = 1
  dat_train_base = dat_train[,1:5000]
#  dat_train_base = dat_train
  fit_gbm_base <- gbm.fit(x=dat_train_base, y=label_train,
                     n.trees= 2000,
                     distribution="bernoulli",
                     interaction.depth=depth_base, 
                     bag.fraction = 0.5,
                     verbose=FALSE)
  cat("Done training baseline, Moving to finding best performance param \n")
  best_iter_base <- gbm.perf(fit_gbm_base, method="OOB")
  
  cat("Starting improved model Training \n")  
  depth_improved = 11
  fit_gbm_improved <- gbm.fit(x=dat_train, y=label_train,
                          n.trees= 100,
                          distribution="bernoulli",
                          interaction.depth=depth_improved, 
                          bag.fraction = 0.5,
                          verbose=FALSE)
  cat("Done training improved, Moving to finding best performance param \n")
  best_iter_improved <- gbm.perf(fit_gbm_improved, method="OOB")
    
  return(list(base_model=fit_gbm_base, iter_base=best_iter_base, 
              improved_model=fit_gbm_improved, iter_improved=best_iter_improved))

}


