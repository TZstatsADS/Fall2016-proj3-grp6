#############################################
### Main execution script for experiments ###
#############################################
### Author: Chenxi Huang
### Project 3
### ADS Fall 2016

### Specify directories
setwd('C:/Users/celia/Desktop/Project 3')

#load libraries
#source("https://bioconductor.org/biocLite.R")
#biocLite("EBImage")
library(EBImage) # not available (for R version 3.3.1)
library(base)
library(data.table) # for fread


img_train_dir <- "./data/zipcode_train/"
img_test_dir <- "./data/zipcode_test/"

### Import training images class labels
########### my change #################
#label_train <- read.table("./data/zip_train_label.txt", header=F)
#label_train <- as.numeric(unlist(label_train) == "9")
num.chicken=1000
num.dog=1000
label_train=c(rep(1,num.chicken),rep(0,num.dog)) #length=2000

### Construct visual feature
source("./lib/feature.R")

#tm_feature_train <- system.time(dat_train <- feature(img_train_dir, "img_zip_train"))
#tm_feature_test <- system.time(dat_test <- feature(img_test_dir, "img_zip_test"))
########### my change #################
# feature base
# for train feature
tm_feature_train_base=system.time(dat_train_base <- feature_base('sift_features.csv'));dim(dat_train_base)
# feature RGB
tm_feature_train_RGB.dog=system.time(dat_train_RGB.dog <- feature_RGB(img_train_dir, "dog"));dim(dat_train_RGB.dog);tm_feature_train_RGB.dog
tm_feature_train_RGB.chic=system.time(dat_train_RGB.chic <- feature_RGB(img_train_dir, "chicken"));dim(dat_train_RGB.chic);tm_feature_train_RGB.chic
#tm_feature_train_RGB=system.time(dat_train_RGB <- feature_RGB(img_train_dir, c('chicken','dog')));dim(dat_train_RGB);tm_feature_train_RGB
dat_train_RGB=rbind(dat_train_RGB.chic,dat_train_RGB.dog)
dat_train=cbind(dat_train_base,dat_train_RGB);dim(dat_train)
tm_feature_train = tm_feature_train_base+tm_feature_train_RGB.chic+tm_feature_train_RGB.dog;tm_feature_train


# for test feature
#tm_feature_train_base=system.time(dat_train_base <- feature_base(''));dim(dat_train_base)
tm_feature_test_RGB <- system.time(dat_test_RGB <- feature_RGB(img_test_dir, "image"))

save(dat_train, file="./output/feature_train.RData")
save(dat_test, file="./output/feature_test.RData")

### Train a classification model with training images
source("./lib/train.R")
source("./lib/test.R")

### Model selection with cross-validation
# Choosing between different values of interaction depth for GBM
source("./lib/cross_validation.R")
depth_values <- seq(3, 11, 2)
err_cv <- array(dim=c(length(depth_values), 2))
K <- 3  # number of CV folds
# create timer 
tm_err_cv=rep(0,length(depth_values))
for(k in 1:length(depth_values)){
  cat("k=", k, "\n")
  err_cv[k,] <- cv.function(dat_train, label_train, depth_values[k], K)
  tm_err_cv[k]=system.time(err_cv[k,])
}
save(err_cv, file="./output/err_cv.RData")
err_cv;tm_err_cv # how long for each cv?

# Visualize CV results
pdf("./figs/cv_results.pdf", width=7, height=5)
plot(depth_values, err_cv[,1], xlab="Interaction Depth", ylab="CV Error",
     main="Cross Validation Error", type="n", ylim=c(0, 0.15))
points(depth_values, err_cv[,1], col="blue", pch=16)
lines(depth_values, err_cv[,1], col="blue")
arrows(depth_values, err_cv[,1]-err_cv[,2],depth_values, err_cv[,1]+err_cv[,2], 
       length=0.1, angle=90, code=3)
dev.off()

# Choose the best parameter value
depth_best <- depth_values[which.min(err_cv[,1])]
par_best <- list(depth=depth_best)

# train the model with the entire training set
tm_train <- system.time(fit_train <- train(dat_train, label_train, par_best))
save(fit_train, file="./output/fit_train.RData")

### Make prediction 
tm_test <- system.time(pred_test <- test(fit_train, dat_test))
save(pred_test, file="./output/pred_test.RData")

### Summarize Running Time
cat("Time for constructing training features=", tm_feature_train[1], "s \n")
cat("Time for constructing testing features=", tm_feature_test[1], "s \n")
cat("Time for training model=", tm_train[1], "s \n")
cat("Time for making prediction=", tm_test[1], "s \n")

