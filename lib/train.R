#########################################################
### Train a classification model with training images ###
#########################################################

### Author: Yuting Ma
### Project 3
### ADS Spring 2016


train <- function(dat_train, label_train, par=NULL){
  
  cat("## Entering training block \n")
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
    depth <- par
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

train.JG <- function(dat.train, label.train, params){
  
  # 1. Create FDA dimensions
  ## First filter out columns with zero and low variance.
  lowVariance <- nearZeroVar(dat.train)
  dat.train.variance <- dat.train[,-lowVariance]
  good.variance.ncol <- ncol(dat.train.variance)
  numcol.to.use <- ceiling(min(good.variance.ncol, nrow(dat.train.variance))*0.95)

  cat("Number of colums: ",numcol.to.use, "\n")
  cat("SumAll:", sum(dat.train.variance), "\n")
  
  ## Run FDA and extract transformed data  
  fda.model <- lfda(x = dat.train.variance[,1:numcol.to.use], y = label.train, r = numcol.to.use, metric="plain")
  z <- as.data.frame(fda.model$Z)
  t <- fda.model$T
  #write.csv(t, "./output/t.csv")

  cat("Dimensions of T: ", dim(t), " ", typeof(t), "\n")  
  cat("DONE FDA \n")
  
  
  # 2. Run SVM
  ## Filter a reduced subset of the columns
  z.fewCols <- z[,1:params[[1]][3]]
  ## Run and return

  svm.model <- svm(x = z.fewCols, 
                   y = label.train,
                   kernel = params[[1]][1],
                   degree = params[[1]][2])

  cat("DONE SVM \n")
  return(list(model = svm.model, 
              use.columns = names(dat.train.variance[,1:numcol.to.use]),
              transformation.matrix = t ))
}



