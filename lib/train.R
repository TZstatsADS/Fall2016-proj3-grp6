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
  
  ### Train with gradient boosting model
  if(is.null(par)){
    depth <- 3
  } else {
    depth <- par$depth
  }
  fit_gbm <- gbm.fit(x=dat_train, y=label_train,
                     n.trees= 2000,
                     distribution="bernoulli",
                     interaction.depth=depth, 
                     bag.fraction = 0.5,
                     verbose=FALSE)
  best_iter <- gbm.perf(fit_gbm, method="OOB")

  return(list(fit=fit_gbm, iter=best_iter))
}

train.JG <- function(dat.train, label.train, par=NULL){
  
  # 1. Create FDA dimensions
  ## First filter out columns with zero and low variance.
  lowVariance <- nearZeroVar(dat.train)
  dat.train.variance <- dat.train[,-lowVariance]
  good.variance.ncol <- ncol(dat.train.variance)
  numcol.to.use <- ceiling(min(good.variance.ncol, nrow(dat.train.variance))*0.95)
  
  ## Run FDA and extract transformed data  
  fda.model <- lfda(x = dat.train[,1:numcol.to.use], y = label.train, r = numcol.to.use, metric="plain")
  z <- as.data.frame(fda.model$Z)
  
  # 2. Run SVM
  ## Filter a reduced subset of the columns
  z.fewCols <- z[,1:2]
  ## Run and return
  svm.model <- svm(x = z.fewCols, 
                   y = label.train)
  return(svm.model)
}



