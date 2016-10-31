#############################################
### Main execution script for experiments ###
#############################################

### Author: Yuting Ma
### Project 3
### ADS Spring 2016

setwd("C:/Users/user/Desktop/Statistics/3rd semester/ADS/Project3/Fall2016-proj3-grp6")


tm_feature_train <- system.time(dat_train <- t(read.csv("./data/Project3_poodleKFC_train/sift_features.csv",header=TRUE)))
# 2000(images) * 5000(sift features)
save(dat_train, file="./output/feature_train.RData")
label_train <- factor(c(rep(0,1000), rep(1,1000)))
whole_train<-data.frame(dat_train,label_train)
### Train a classification model with training images
source("./lib/train.R")
source("./lib/test.R")

### Model selection with cross-validation ----
# Choosing between different values of interaction depth for GBM
source("./lib/cross_validation.R")
#tune1 <- seq(0, 1, 0.2)
co<-c(2^5,2^6,2^7,2^8)
err_cv <- array(dim=c(length(co), 2))
K <- 5  # number of CV folds
for(k in 1:length(co)){
  cat("k=", k, "\n")
  err_cv[k,] <- cv.function(dat_train, label_train,co,  K)
}
  

  save(err_cv, file="./output/err_cv4.RData")

# Visualize CV results
jpeg(file = "./figs/cv_results3.jpg")
plot(tune1, err_cv[,1], xlab="laplace smoothing", ylab="CV Error",
     main="Cross Validation Error", type="n", ylim=c(0, 0.5))
points(tune1, err_cv[,1], col="blue", pch=16)
lines(tune1, err_cv[,1], col="blue")
arrows(tune1, err_cv[,1]-err_cv[,2],tune1, err_cv[,1]+err_cv[,2], 
      length=0.1, angle=90, code=3)
dev.off()


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
