#############################################
### Main execution script for experiments ###
#############################################

### Author: Jaime Gacitua (credits to Yuting Ma)
### Project 3
### ADS Spring 2016


rm(list = ls())

# Install missing packages
list.of.packages <- c("lfda", "plotly", "MASS", "matrixStats", "caret", "e1071")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(lfda)
library(plotly)
library(MASS)
library(matrixStats)
library(caret)
library(e1071)

### Specify directories
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

img_train_dir <- "./data/images/"
#img_test_dir <- "./data/zipcode_test/"

### Import training images class labels ----
#label_train <- read.table("./data/zip_train_label.txt", header=F)
#label_train <- as.numeric(unlist(label_train) == "9")
num.chicken <- 1000
num.dog <- 1000
label.train <- c(rep(0, num.chicken), rep(1, num.dog))
label.train <- as.data.frame(label.train)
names(label.train) <- c("val")
label.train$val <- factor(label.train$val)

### Construct visual feature ----
source("./lib/feature_JG.R")
tm_feature_train <- system.time(dat.train <- feature.JG("sift_features.csv"))
# Columns are images. Rows are SIFT features. Got to transpose.

#----
# Randomize the order of the input data
## 1. Merge data and labels
dat.train.labeled <- cbind(dat.train, label.train)
## 2. Randomize
dat.train.labeled <- dat.train.labeled[sample(1:nrow(dat.train.labeled)),]
## 3. Separate them
dat.train <- dat.train.labeled[,1:ncol(dat.train)]
label.train.use <- dat.train.labeled$val

save(dat.train, file="./output/feature_train.RData")

### Train a classification model with training images
source("./lib/train_JG.R")
source("./lib/test_JG.R")


### Model selection with cross-validation ----
# Choosing between different values of interaction depth for GBM
source("./lib/cross_validation_JG.R")
#depth_values <- seq(3, 11, 2)

params <- list(c("linear", 1, 2)
               ,c("linear", 1, 5)
               ,c("linear", 1, 10)
               ,c("linear", 1, 15)
)
ntests <- length(params)

err_cv <- array(dim=c(length(params), 2))
K <- 10  # number of CV folds
for(k in 1:length(params)){
  cat("== kernel: ", params[[k]][1], " degree: ", params[[k]][2], "dimZ: ", params[[k]][3], "== \n")
  err_cv[k,] <- cv.function(dat.train, label.train.use, params[k], K)
}
save(err_cv, file="./output/err_cv.RData")

# Visualize CV results
jpeg(file = "./figs/cv_results_zDimensions.jpg")
plot(x = 1:ntests, y = err_cv[,1], xlab="Parameter Tuning #", ylab="CV Error",
     main="Cross Validation Error", ylim=c(0, 1))
points(1:ntests, err_cv[,1], col="blue", pch=16)
lines(1:ntests, err_cv[,1], col="blue")
arrows(1:ntests, err_cv[,1]-err_cv[,2],1:ntests, err_cv[,1]+err_cv[,2], 
      length=0.1, angle=90, code=3)
dev.off()


# Choose the best parameter value
#depth_best <- depth_values[which.min(err_cv[,1])]
#par_best <- list(depth=depth_best)

# train the model with the entire training set
#tm_train <- system.time(fit_train <- train(dat.train, label.train, par_best))
#save(fit_train, file="./output/fit_train.RData")

### Make prediction 
#tm_test <- system.time(pred_test <- test(fit_train, dat_test))
#save(pred_test, file="./output/pred_test.RData")

### Summarize Running Time
#cat("Time for constructing training features=", tm_feature_train[1], "s \n")
#cat("Time for constructing testing features=", tm_feature_test[1], "s \n")
#cat("Time for training model=", tm_train[1], "s \n")
#cat("Time for making prediction=", tm_test[1], "s \n")



