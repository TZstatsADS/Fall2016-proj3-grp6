########################
### Cross Validation ###
########################

### Author: Yuting Ma
### Project 3
### ADS Spring 2016


cv.function <- function(X.train, y.train, kernel, K){
  
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
    
    trained.model <- train.JG(train.data, train.label, kernel)
    
    cat("Entering Prediction Block \n")
    pred <- test.JG(trained.model$model, trained.model$use.columns, trained.model$transformation.matrix, test.data)  
    
#    cat("Predictions: ",head(pred), " ", typeof(pred), "\n")
#    cat("Test Labels: ",head(test.label), " ", typeof(test.label), "\n")
    pred <- pred - 1
    cv.error[i] <- mean(pred != test.label)
    print(table(pred, test.label))
      
  }			
  return(c(mean(cv.error),sd(cv.error)))
  
}
