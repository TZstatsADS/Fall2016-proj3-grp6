# Load RGB features
load("/Users/senzhuang/Downloads/feature_RGB.RData")

######### SVM #########

library(caret)
library('e1071')
library(randomForest)

# Load SWIF features
md <- read.csv(file.choose())
md <- t(md)
md <- as.data.frame(md)

# Combind features
md <- cbind(md,dat)

y <- rep(c(0,1), each = 1000)
rownames(md) <- c()
md <- cbind(y,md)
md$y <- as.factor(md$y)
levels(md$y)[levels(md$y) == '0'] <- 'fc'
levels(md$y)[levels(md$y) == '1'] <- 'dog'
md <- na.omit(md)

set.seed(123)
# Split into training and testing
# Load the segmentation data set
trainIndex <- createDataPartition(md$y,p=1,list=FALSE)
trainData <- md[trainIndex,2:5013]
trainX <- trainData[,5001:5012]       # Pull out the variables for training
trainY <- md$y[trainIndex]

rf_tune <- tune.randomForest(x = trainX, y = trainY,ntree = 500)

# tuning svm model
svm_tune <- tune(svm, train.x = trainX, train.y = trainY,
                 kernel = 'radial', ranges = list(cost=10^(-1:2), gamma=c(.5,1,2)))

# fitting baseline svm model
system.time(svm.model <- svm(trainX, trainY, kernel = 'radial', cost = 10, gamma = 0.5))
pred <- predict(svm.model, testX)
tb <- table(pred, testY)
cm <- confusionMatrix(tb)

# Find the optimal number of PCs to use
trainIndex <- createDataPartition(md$y,p=.8,list=FALSE)
trainData <- md[trainIndex,2:5001]
testData  <- md[-trainIndex,2:5001]
system.time(trainData <- prcomp(trainData, center = T, scale = F))
system.time(testData <- prcomp(testData, center = T, scale = F))
accuracy.rate <- list()
for (i in 2:200){
        trainX <- trainData[,1:i]        # Pull out the variables for training
        trainY <- md$y[trainIndex]
        testX <- testData[,1:i]
        testY <- md$y[-trainIndex]
        system.time(svm.model <- svm(trainX, trainY, kernel = 'radial', cost = 1, gamma = 0.5))
        pred <- predict(svm.model, testX)
        tb <- table(pred, testY)
        cm <- confusionMatrix(tb)
        accuracy.rate[i] <- cm$overall['Accuracy']}
