#VIZUALIZATION
library(tidyverse)
library(dplyr)
library(tidyr)
library(purrr)
library(corrplot)
library(ggplot2)
library(reshape2)


#*********************************************************************************************************#
#Distribution of match outcomes
data <- read.csv("CleanData.csv")

outcome_counts <- data %>%
  group_by(Outcome) %>%
  summarise(count = n())

print(outcome_counts)
#Draw 250
#Team 1 Wins 494 (Played home and won)
#Team 2 Wins 343 (Played away and won)

ggplot(outcome_counts, aes(x = Outcome, y = count, fill = Outcome)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Distribution of Match Outcomes", x = "Outcome", y = "Number of Matches")


#*********************************************************************************************************#
#Team Performance Over Seasons
data <- read.csv("updated_data_with_outcomes.csv")


team_performance <- data %>%
  mutate(match_id = row_number()) %>%
  select(match_id, CompetitionSeason, Team1Name, Team2Name, Outcome) %>%
  pivot_longer(cols = c(Team1Name, Team2Name), names_to = "HomeAway", values_to = "Team") %>%
  mutate(Win = if_else(HomeAway == "Team1Name" & Outcome == "Team1 Wins" |
                         HomeAway == "Team2Name" & Outcome == "Team2 Wins", 1, 0),
         Loss = if_else(HomeAway == "Team1Name" & Outcome == "Team2 Wins" |
                          HomeAway == "Team2Name" & Outcome == "Team1 Wins", 1, 0),
         Draw = if_else(Outcome == "Draw", 1, 0)) %>%
  group_by(CompetitionSeason, Team) %>%
  summarise(Wins = sum(Win), Losses = sum(Loss), Draws = sum(Draw), .groups = "drop")



ggplot(team_performance, aes(x = CompetitionSeason)) +
  geom_line(aes(y = Wins, color = "Wins"), linewidth = 1.2) +
  geom_line(aes(y = Losses, color = "Losses"), linewidth = 1.2) +
  geom_line(aes(y = Draws, color = "Draws"), linewidth = 1.2) +
  facet_wrap(~Team, scales = "free_y", ncol = 2) +
  scale_color_manual(values = c("Wins" = "green", "Losses" = "red", "Draws" = "blue")) +
  labs(title = "Team Performance Over Competition Seasons", x = "Competition Season", y = "Match Outcomes") +
  theme_minimal() +
  theme(legend.position = "bottom")


# Creating a data frame of all combinations of teams and seasons
all_teams_seasons <- expand.grid(Team = unique(team_performance$Team),
                                 CompetitionSeason = unique(team_performance$CompetitionSeason))

# Left join this with our existing team_performance data
complete_team_performance <- left_join(all_teams_seasons, team_performance, by = c("Team", "CompetitionSeason"))

# Replacing NAs with zeros since NA would mean no games played or no data recorded
complete_team_performance[is.na(complete_team_performance)] <- 0

ggplot(complete_team_performance, aes(x = CompetitionSeason)) +
  geom_line(aes(y = Wins, color = "Wins"), size = 1.2) +
  geom_line(aes(y = Losses, color = "Losses"), size = 1.2) +
  geom_line(aes(y = Draws, color = "Draws"), size = 1.2) +
  facet_wrap(~Team, scales = "free_y", ncol = 2) +
  scale_color_manual(values = c("Wins" = "green", "Losses" = "red", "Draws" = "blue")) +
  labs(title = "Complete Team Performance Over Competition Seasons", x = "Competition Season", y = "Match Outcomes") +
  theme_minimal() +
  theme(legend.position = "bottom")

#*********************************************************************************************************#
# Heatmap
data <- read.csv("updated_data_with_outcomes.csv")

# Summarize match outcomes between teams to find the most frequent result

# Aggregating to find the most frequent outcome between each pair of teams
match_outcomes <- data %>%
  group_by(Team1Name, Team2Name) %>%
  summarise(Outcome = names(which.max(table(Outcome))), .groups = 'drop')  # Most common outcome

# Pivot the data
match_matrix <- pivot_wider(match_outcomes,
                            names_from = Team2Name,
                            values_from = Outcome,
                            values_fill = list(Outcome = "No Data"))

# Replace NA after pivoting, if any exist
match_matrix[is.na(match_matrix)] <- "No Data"

#***********

# Flatten each list to the most frequent outcome
match_matrix <- match_matrix %>%
  mutate(across(-Team1Name, ~map_chr(.x, ~{
    if (is.null(.x)) return("No Data")
    else {
      freq <- table(.x)
      return(names(freq[which.max(freq)]))
    }
  }), .names = "{.col}_flat"))

# Select only the flattened columns
flat_columns <- grep("_flat$", names(match_matrix), value = TRUE)
match_matrix_flat <- match_matrix %>%
  select(Team1Name, all_of(flat_columns))

# Rename flattened columns to original team names
names(match_matrix_flat)[-1] <- gsub("_flat", "", names(match_matrix_flat)[-1])


# Melt the data for ggplot
match_matrix_melted <- melt(match_matrix_flat, id.vars = "Team1Name")

ggplot(match_matrix_melted, aes(x = Team1Name, y = variable, fill = value)) +
  geom_tile(color = "white") +
  scale_fill_manual(values = c("Team1 Wins" = "blue", "Team2 Wins" = "red", "Draw" = "grey", "No Data" = "white")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1), 
        axis.text.y = element_text(angle = 0),  
        axis.title = element_text(size = 12)) +  
  labs(
    title = "Heatmap of Team Interactions",
    x = "Team 1 (Playing Home)",  
    y = "Team 2 (Playing Away)",    
    fill = "Match Outcome"          
  )

#*********************************************************************************************************#
data <- read.csv("updated_data_with_outcomes.csv")

n_cols <- ncol(data)
col_chunks <- split.default(data, ceiling(seq(1, n_cols)/50))

#change the number in col_chunks[[from 1 to 10]]
data_summary <- col_chunks[[1]] %>%
  summarise(across(where(is.numeric), ~sum(!is.na(.))))  # Sum the non-NA values across numeric columns

# Converting to a more usable format for visualization
data_summary_long <- pivot_longer(data_summary, everything())

# Bar plot of the non-missing counts
ggplot(data_summary_long, aes(x = name, y = value, fill = name)) +
  geom_col() +
  labs(title = "Count of Non-Missing Values for Each Statistic",
       x = "Statistic", y = "Count of Non-Missing Values") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))  # Rotate x labels for readability



































