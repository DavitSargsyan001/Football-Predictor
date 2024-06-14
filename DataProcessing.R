library(dplyr)
library(tibble)
library(corrr)
library(corrplot)
library(ggcorrplot)
library(ggplot2)
library(caret)

#Get Data
data <- read.csv("all_matches_data.csv")

#Most NA's in dataset are a result of data not recorded because such statistics
#are not recorded since they did not occur, so we replace NA's with 0
data[is.na(data)] <- 0

#Removing MatchID, GameweekID, Competition Season and MatchDate features
drops <- c("MatchID","GameweekID", 
           "CompetitionSeason", "MatchDate")
data <- data[ , !(names(data) %in% drops)]

#Create a new column to highlight the outcome of a match
Outcome = "Outcome"
data <- add_column(data, Outcome, .after = "Team2Score")



#Decide on the match outcome based on score
d = "Draw"
t1 = "Team1 Wins"
t2 = "Team2 Wins"
data <- transform(data, Outcome = ifelse(Team1Score == Team2Score, d, 
                    ifelse(Team1Score > Team2Score, t1, t2)))

#Encode Team Names into integers
data$Team1Name <- as.integer(factor(data$Team1Name))
data$Team2Name <- as.integer(factor(data$Team2Name))

#Encode Team formations into integers
data$Team1_formation_used <- as.integer(factor(data$Team1_formation_used))
data$Team2_formation_used <- as.integer(factor(data$Team2_formation_used))

#Write the table into a csv file
write.csv(data, file = "CleanData.csv")



