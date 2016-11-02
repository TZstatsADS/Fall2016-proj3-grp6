#############################################
### Execution script to run testing set   ###
#############################################
### Author: Group 6
### Project 3
### ADS Fall 2016



# Trees 100
# CV 5
# Bins for colors 10, new features = 10*10*10=1000
# error rate 9%
# Time to train 17 minutes


### Specify directories

#############
list.of.packages <- c("EBImage", "base", "data.table", "caret")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
library(EBImage) # not available (for R version 3.3.1)
library(base)
library(data.table) # for fread
library(caret)

### Specify directories
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

##############

#load libraries
#source("https://bioconductor.org/biocLite.R")
#biocLite("EBImage")

### Training images class labels
num.chicken=1000
num.dog=1000
label_train=c(rep(1,num.chicken),rep(0,num.dog)) #length=2000

### Construct visual feature
source("./lib/feature.R")

tm_feature_train = system.time(dat_train <- feature(img_dir = "./data/images/",
                                                        img_name = c("chicken", "dog"),
                                                        sift_csv = "./data/sift_features.csv",
                                                        data_name = "train"))

tm_feature_train
### Train a classification model with training images
source("./lib/train.R")
source("./lib/test.R")

### Model selection with cross-validation
# Choosing between different values of interaction depth for GBM
#source("./lib/cross_validation.R")

#depth_values <- seq(3, 5, 8, 11)
#err_cv <- array(dim=c(length(depth_values), 2))
#K <- 5  # number of CV folds
#for(k in 1:length(depth_values)){
#  cat("k=", k, "\n")
#  err_cv[k,] <- cv.function(dat_train, label_train, depth_values[k], K)
#}
#save(err_cv, file="./output/err_cv.RData")
#err_cv

# Visualize CV results
#pdf("./figs/cv_results.pdf", width=7, height=5)
#plot(depth_values, err_cv[,1], xlab="Interaction Depth", ylab="CV Error",
#     main="Cross Validation Error", type="n", ylim=c(0, 0.15))
#points(depth_values, err_cv[,1], col="blue", pch=16)
#lines(depth_values, err_cv[,1], col="blue")
#arrows(depth_values, err_cv[,1]-err_cv[,2],depth_values, err_cv[,1]+err_cv[,2], 
#       length=0.1, angle=90, code=3)
#dev.off()

# Choose the best parameter value
#depth_best <- depth_values[which.min(err_cv[,1])]
#par_best <- list(depth=depth_best)par_best

#################
## Validation Framework
#################

#Split data
trainIndex <- createDataPartition(label_train, p=0.8, list = FALSE)
trainData <- dat_train[trainIndex,]
testData <- dat_train[-trainIndex,]
trainLabel <- label_train[trainIndex]
testLabel <- label_train[-trainIndex]

#Train Model
mod_train_validation <- train(trainData, trainLabel)
#Test Model
prediction_validation <- test(mod_train_validation, testData)

#Confusion Matrices
t <- table(prediction_validation$baseline, testLabel)
confusionMatrix(t)
adv.t <- table(prediction_validation$adv, testLabel)
confusionMatrix(adv.t)


###############
# Testing in Class
####################

# Train the model with the entire training set
tm_train <- system.time(mod_train <- train(dat_train, label_train))[1]
save(mod_train, file="./output/trained_model.RData")

image.dir <- "./data/Project3_poodleKFC_test/images_test/"

# Extract features from test set
tm_feature_test = system.time(feature_eval <- feature(img_dir = image.dir,
                                                    img_name = "image",
                                                    sift_csv = "./data/Project3_poodleKFC_test/sift features_test.csv",
                                                    data_name = "eval"))

# Predictions using all data
pred_test <- test(mod_train, feature_eval)
# Predictions using validation model
pred_test_using_validationModel <- test(mod_train_validation, feature_eval)

# Summaries
summary(as.factor(pred_test$baseline))
summary(as.factor(pred_test$adv))

summary(as.factor(pred_test_using_validationModel$baseline))
summary(as.factor(pred_test_using_validationModel$adv))

# Generate output CSV
a <- list.files(image.dir)
final.prediction <- cbind(pred_test$baseline, pred_test$adv)
final.prediction <- as.data.frame(final.prediction)
names(final.prediction) <- c("baseline", "advanced")
row.names(final.prediction) <- a 
write.csv(final.prediction, file = "./output/prediction.csv")


# Save results
save(pred_test, file="./output/pred_test.RData")
