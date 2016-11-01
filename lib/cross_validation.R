########################
### Cross Validation ###
########################

### Author: Yuting Ma
### Project 3
### ADS Spring 2016


cv.function.JG <- function(X.train, y.train, params, K){
  
  n <- length(y.train)
  n.fold <- floor(n/K)
  s <- sample(rep(1:K, c(rep(n.fold, K-1), n-(K-1)*n.fold)))  
  cv.error <- rep(NA, K)
  
  for (i in 1:K){
    cat("## Starting CV fold ", i, "## \n")
    train.data <- X.train[s != i,]
    train.label <- y.train[s != i]
    test.data <- X.train[s == i,]
    test.label <- y.train[s == i]
    
    trained.model <- train.JG(train.data, train.label, params)
    
    cat("Entering Prediction Block \n")
    
    pred.time <- proc.time()
    pred <- test.JG(trained.model, params, test.data)  
    pred.time <- proc.time() - pred.time

    pred <- pred - 1
    cv.error[i] <- mean(pred != test.label)
    print(table(pred, test.label))
     
  }			
  return(c(mean(cv.error),sd(cv.error)))
  
}

cv.function <- function(X.train, y.train, params, K){
  cat(params, "\n")
  cat("Parameters:", params, "\n")
  n <- length(y.train)
  n.fold <- floor(n/K)
  s <- sample(rep(1:K, c(rep(n.fold, K-1), n-(K-1)*n.fold)))  
  cv.error <- rep(NA, K)
  
  time.predAvg <- 0
  time.trainAvg <- 0
  for (i in 1:K){
    cat("## Starting CV fold ", i, "## \n")
    train.data <- X.train[s != i,]
    train.label <- y.train[s != i]
    test.data <- X.train[s == i,]
    test.label <- y.train[s == i]
    
    
    time.train <- system.time(
      trained.model <- train(train.data, train.label, params)
      )
    cat("Training Time: ", time.train, "\n")
    
    time.pred <- system.time(
      pred <- test(trained.model, test.data)
      )
    
    time.predAvg <- time.predAvg + time.pred[1]/K
    time.trainAvg <- time.trainAvg + time.train[1]/K
    
    cat("Prediction Time: ", time.pred, "\n")
    #    cat("Predictions: ",head(pred), " ", typeof(pred), "\n")
    #    cat("Test Labels: ",head(test.label), " ", typeof(test.label), "\n")

    cv.error[i] <- mean(pred != test.label)
    print(table(pred, test.label))
    
  }			
  time.predAvg.perPic <- time.predAvg / length(test.label)
  cat("Avg Training Time:", time.trainAvg, "\n")
  cat("Avg Prediction Time / Pic:", time.predAvg.perPic, "\n")
  return(c(mean(cv.error),sd(cv.error),time.trainAvg, time.predAvg.perPic))
  
}



