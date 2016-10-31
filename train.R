#########################################################
### Train a classification model with training images ###
#########################################################

### Author: Yuting Ma
### Project 3
### ADS Spring 2016

train <- function(whole_train,label_train,co){
  
  ### load libraries
  library("e1071")
  
  ### Train with SVM
  fit_svm<-svm(label_train~.,data=whole_train,kernel="linear",cost=co)
  
#set.seed(1)
#train.row<-sample(dim(dat_train)[1],dim(dat_train)[1]*0.8)
#train<-dat_train[train.row,]
#validation<-dat_train[-train.row,]
#dim(train) # 1600*5000
#dim(validation) # 400*5000
#train_label<-label_train[train.row]
#validation_label<-label_train[-train.row]
#whole<-data.frame(train,train_label)  
  
#  system.time(fit_svm<-svm(train_label~.,data=whole,kernel="linear",cost=100))
#  system.time(pr<-predict(fit_svm,newdata=validation))
  
#  table(pr,validation_label)
  
  return(fit_svm)
}


#train <- function(dat_train,label_train,lap){
  
  ### load libraries
#  library("e1071")
  
  ### Train with NB
  
#  fit_nb <- naiveBayes(dat_train,label_train,laplace=lap)
#  return(fit_nb)
#}
