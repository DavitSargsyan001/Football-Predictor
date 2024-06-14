setwd("C:/Users/NA Jaber Mazari/OneDrive/Desktop/Comp541")

library(dplyr)
library(tibble)
library(corrr)
library(corrplot)
library(ggcorrplot)
library(ggplot2)
library(caret)

#Get Data
data <- read.csv("CleanData.csv")
data <- data[2:485]
#Split Data into training and testing 
sample <- sample(c(TRUE,FALSE), nrow(data),  
                 replace=TRUE, prob=c(0.8,0.2)) 

# creating training dataset 
train_data  <- data[sample, ] 
test_data <-data[!sample, ]

#Isolate training attributes from target
train_attributes <- subset(train_data, select = -c(Team1Score, Team2Score, Outcome))
train_target <- train_data[, 5]

#Isolate test attributes from target
test_attributes <- subset(test_data, select = -c(Team1Score,Team2Score,Outcome))
test_target <- test_data[, 5]

#Fit data to random forest, 
rfFit <- train(train_attributes, as.factor(train_target), method = "rf", metric = "Accuracy")
print(rfFit)

#Make predictions on non-labeled test data and fit to confusion matrix
rfprediction <- predict(rfFit, newdata = test_attributes)
confusionMatrix(rfprediction, as.factor(test_target))

#Create a cross validator
cv3 <- trainControl(method = "repeatedcv", number = 7, search = "random")
#Create a rf model with repeated cross-validation with 7 folds, will run with
#500 decision trees
rfcvFit <- train(train_attributes, as.factor(train_target), method = "rf", metric = "Accuracy", trControl = cv3)
print(rfcvFit)


#Make predictions with cross-validated model, then make a confusion matrix
rfcvprediction <- predict(rfcvFit, newdata= test_attributes)
confusionMatrix(rfcvprediction, as.factor(test_target))

plot(rfcvFit)
