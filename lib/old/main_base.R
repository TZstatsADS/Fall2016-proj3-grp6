#############################################
### Main execution script for experiments ###
#############################################

### Author: Yuting Ma
### Project 3
### ADS Spring 2016

### Specify directories
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(caret)

img_train_dir <- "./data/images/"
#img_test_dir <- "./data/zipcode_test/"

### Import training images class labels ----
#label_train <- read.table("./data/zip_train_label.txt", header=F)
#label_train <- as.numeric(unlist(label_train) == "9")
num_chicken <- 1000
num_dog <- 1000
label_train <- c(rep(0, num_chicken), rep(1, num_dog))


### Construct visual feature ----
source("./lib/feature.R")
tm_feature_train_RGB <- system.time(dat_train_RGB <- feature_RGB("./data/images/", "RGB"))
tm_feature_train <- system.time(dat_train <- feature_base("sift_features.csv"))
dat_train_RGB[is.na(dat_train_RGB)] <- 0

## Merge both training data
#dat_train <- cbind(dat_train, dat_train_RGB)
save(dat_train, file="./output/feature_train.RData")

source("./lib/train_JG.R")
source("./lib/test_JG.R")
source("./lib/cross_validation_JG.R")

plot.errors <- function(err_cv, params, txt){
  #jpeg(file = "./figs/cv_results_SIFT+RGB.jpg")
  x.axis <- 1:nrow(params)
  plot(x.axis, err_cv[,1], xlab="Interaction Depth", ylab="CV Error",
       main=paste0("Cross Validation Error | Multiple depths Base Model | ", txt), 
       type="n", ylim=c(0, 0.5), xaxt="n")
  axis(1, at = x.axis)
  points(x.axis, err_cv[,1], col="blue", pch=16)
  lines(x.axis, err_cv[,1], col="blue")
  arrows(x.axis, err_cv[,1]-err_cv[,2],x.axis, err_cv[,1]+err_cv[,2], 
         length=0.1, angle=90, code=3)
  #dev.off()
}

tryGBM <- function(data.train, label.train, params, K, suffix){
  cv.errors <- apply(params, 1, function(x){
    cv.function(data.train, label.train, x, K)
  })
  cv.errors.mat <- matrix(unlist(cv.errors), ncol = 4, byrow = TRUE)
  save(cv.errors.mat, file=paste0("./output/err_cv_", suffix, ".RData"))
#  plot.errors(cv.errors.mat, depth_values, suffix)
  return(cv.errors.mat)
}

dat_train <- feature_base("sift_features.csv")
depth_values <- data.frame(depth=c(1,2,3), numtrees=c(100,100,100), pca=c(1,1,1)) # depth of trees in boosted decision trees
K <- 2  # number of CV folds
suffix <- "GBM_base_test"
GBM.base.test <- tryGBM(dat_train, label_train, depth_values, K, suffix)
plot.errors(GBM.base.test, depth_values, "Testing PCA")


dat_train <- cbind(dat_train, dat_train_RGB)
depth_values <- data.frame(depth=c(1,2,3), numtrees=c(2000,2000,2000), pca=c(1,1,1)) # depth of trees in boosted decision trees
K <- 5  # number of CV folds
suffix <- "GBM_base_RGB"
GBM.base.RGB <- tryGBM(dat_train, label_train, depth_values, K, suffix)

GBM.param <- data.frame(depth=c(3,4,4), numtrees=c(500, 500, 1000)) # depth of trees in boosted decision trees
K <- 5  # number of CV folds
suffix <- "GBM_base_RGB_1"
GBM.base.RGB.1 <- tryGBM(dat_train, label_train, GBM.param, K, suffix)
plot.errors(GBM.base.RGB.1, GBM.param, "GBM_base_RGB_1")


GBM.param <- data.frame(depth=c(3,3,3), numtrees=c(1000, 2000, 2500), pca=c(1,1,1)) # depth of trees in boosted decision trees
K <- 5  # number of CV folds
suffix <- "GBM_base_RGB_PCA500"
GBM.base.RGB.PCA <- tryGBM(dat_train, label_train, GBM.param[2:3,], K, suffix)
plot.errors(GBM.base.RGB.1, GBM.param, "GBM_base_RGB_PCA500")

GBM.base.RGB.PCA



# Choose the best parameter value
depth_best <- depth_values[which.min(err_cv[,1])]
par_best <- list(depth=depth_best)

# train the model with the entire training set
tm_train <- system.time(fit_train <- train(dat_train, label_train, par_best))
#save(fit_train, file="./output/fit_train.RData")

### Make prediction 
#tm_test <- system.time(pred_test <- test(fit_train, dat_test))
#save(pred_test, file="./output/pred_test.RData")

### Summarize Running Time
cat("Time for constructing training features=", tm_feature_train[1], "s \n")
#cat("Time for constructing testing features=", tm_feature_test[1], "s \n")
cat("Time for training model=", tm_train[1], "s \n")
#cat("Time for making prediction=", tm_test[1], "s \n")

