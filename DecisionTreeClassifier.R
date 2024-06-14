install.packages("caret")
install.packages("rpart.plot")
library(dplyr)
library(caret)
library(rpart)
library(rpart.plot)

data <- read.csv("CleanData.csv")

data <- data %>%
  select(-c(Team1Score, Team2Score, Team1Name, Team2Name, Team1_goals, Team2_goals, Team1_draws)) %>%
  select(1:250) %>%
  mutate(Outcome = factor(Outcome)) 

set.seed(123) 
index <- createDataPartition(data$Outcome, p = 0.80, list = FALSE)
train_data <- data[index, ]
test_data <- data[-index, ]

tree_model <- rpart(Outcome ~ ., data = train_data, method = "class" )

predictions <- predict(tree_model, test_data, type = "class")
confusionMatrix(predictions, test_data$Outcome)

rpart.plot(tree_model, main="Decision Tree", extra=104)  # extra=104 shows split labels

predictions <- factor(predictions, levels = levels(test_data$Outcome))
test_data$Outcome <- factor(test_data$Outcome)

confusion_matrix <- confusionMatrix(predictions, test_data$Outcome)


print(confusion_matrix)

accuracy <- confusion_matrix$overall['Accuracy']
print(paste("Accuracy: ", accuracy * 100, "%", sep=""))