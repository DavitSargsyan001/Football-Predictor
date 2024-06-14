library(httr)
library(jsonlite)
library(dplyr)
library(purrr)
library(tidyr)

# Ranges of match IDs
# We got ranges by looking into last and first matches of that seasons and basically noticed that these numbers change for each match in order
match_id_ranges <- list(
  seq(93669, 93321, by = -1), #Ranges of 2023/2024 season(Current)
  seq(75281, 74911, by = -1), #Ranges of 2022/2023 season
  seq(66712, 66342, by = -1)  #Ranges of 2021/2022 season
  #You can add more ranges for each season by going to https://www.premierleague.com/results, select season, go to the last match which happened during that season, find the API call in the network tab 
  #(You can reload the page to see all the calls, there will be a lot but you have to sift through it to find the correct one which returns the JSON response for that match)
  #Do the same step for the first match of the season and the API call should look like something like this https://footballapi.pulselive.com/football/broadcasting-schedule/fixtures/93691
  #In the network tab you will find a number such as 93691 for the last match of that seasos (This is the last match ID for the 2023/2024 season)
  #So after you did that and you got the IDs for first and last matches you can insert them to get the data
  #sometimes the user agent might change so make sure to check it for that season since its crucial for working
)

# API setup
user_agent_string <- "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Mobile Safari/537.36"

# empty data frame for storingn match data
combined_matches_df <- data.frame()

# Loop through each range and each match ID in the range
for (range in match_id_ranges) {
  for (match_id in range) {
    api_url <- sprintf("https://footballapi.pulselive.com/football/stats/match/%s", match_id)
    
    response <- GET(api_url,
                    add_headers(
                      'User-Agent' = user_agent_string,
                      Referer = "https://www.premierleague.com/",
                      Accept = "application/json",
                      'Accept-Encoding' = "identity",
                      Origin = "https://www.premierleague.com",
                      Content_Type = "application/json"
                    ))
    
    if(status_code(response) == 200) {
      page_data <- fromJSON(rawToChar(response$content), flatten = TRUE)
      
      # Extract general match and stats info which comes in page_data$entity section
      gameweek_id <- page_data$entity$gameweek$gameweek
      competition_season <- page_data$entity$gameweek$compSeason$id
      match_date <- page_data$entity$kickoff$label
      print(paste("Data retrieved for Match ID:", match_id))
      
      #This part is uncommented since it was used for testing if we would get the second portion of the data with the GET request
      #We left this here to show our work as well as to talk about potential issues while scraping
      #if (is.null(page_data$data)) { 
      #  print(paste("No data section for Match ID:", match_id, "; likely not occurred. Skipping."))
      #  next  # Skip to the next match id
      #}
      
      team_1_name <- page_data$entity$teams$team.name[[1]]
      team_2_name <- page_data$entity$teams$team.name[[2]]
      team_1_score <- page_data$entity$teams$score[[1]]
      team_2_score <- page_data$entity$teams$score[[2]]
      
      # Extract stats for both teams dynamically
      team_ids <- names(page_data$data)
      team_1_stats <- page_data$data[[team_ids[1]]]$M
      team_2_stats <- page_data$data[[team_ids[2]]]$M
      
      team_1_df <- data.frame(t(setNames(team_1_stats$value, paste("Team1", team_1_stats$name, sep="_"))), stringsAsFactors = FALSE)
      team_2_df <- data.frame(t(setNames(team_2_stats$value, paste("Team2", team_2_stats$name, sep="_"))), stringsAsFactors = FALSE)
      
      match_info <- data.frame(
        MatchID = as.character(match_id),
        GameweekID = as.character(gameweek_id),
        CompetitionSeason = as.character(competition_season),
        MatchDate = as.character(match_date),
        Team1Name = as.character(team_1_name),
        Team2Name = as.character(team_2_name),
        Team1Score = as.integer(team_1_score),
        Team2Score = as.integer(team_2_score),
        stringsAsFactors = FALSE
      )
      #
      final_match_data <- cbind(match_info, team_1_df, team_2_df)
      print(head(final_match_data))
      combined_matches_df <- bind_rows(combined_matches_df, final_match_data)
    } else {
      print(paste("Failed to retrieve data for match ID:", match_id, "Status code:", status_code(response)))
    }
  }
}


write.csv(combined_matches_df, "all_matches_data.csv", row.names = FALSE)
