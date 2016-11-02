#### SVM ####

library(caret)
library('e1071')

# Load SWIF features
md <- read.csv(file.choose())
md <- t(md)
md <- as.data.frame(md)
y <- rep(c(0,1), each = 1000)
rownames(md) <- c()
md <- cbind(y,md)
md$y <- as.factor(md$y)
levels(md$y)[levels(md$y) == '0'] <- 'fc'
levels(md$y)[levels(md$y) == '1'] <- 'dog'

################### PCA #################################
pc <- prcomp(md[,2:5001], center = T, scale = F)

set.seed(123)
# Split into training and testing
# Load the segmentation data set
trainIndex <- createDataPartition(md$y,p=.8,list=FALSE)
trainData <- pc$x[trainIndex,]
testData  <- pc$x[-trainIndex,]
trainX <-trainData[,1:20]        # Pull out the variables for training
trainY <- md$y[trainIndex]
testX <- testData[,1:20]
testY <- md$y[-trainIndex]


# tuning svm model
svm_tune <- tune(svm, train.x = trainX, train.y = trainY,
                 kernel = 'radial', ranges = list(cost=10^(-1:2), gamma=c(.5,1,2)))

# fitting baseline svm model
svm.model <- svm(trainX, trainY, kernel = 'radial', cost = 1, gamma = 0.5)
pred <- predict(svm.model, testX)
table(pred, testY)
