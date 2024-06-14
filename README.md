# Football Match Outcome Predictor using Data Mining

## Project Overview
This project was part of a semester-long data mining class, developed collaboratively with a classmate. The aim was to predict football match outcomes using various data mining techniques. We used the R programming language for web scraping, data cleaning, visualization, and applying machine learning models.

## Features
- Web scraping to collect match data
- Data cleaning and preprocessing
- Data visualization to understand trends and patterns
- Machine learning models: Decision Tree Classifier and Random Forest

## Technologies Used
- R Programming Language
- Libraries: `rvest`, `dplyr`, `ggplot2`, `caret`, `randomForest`, `rpart` ...

## Motivation
The goal of this project was to explore the use of data mining techniques in sports analytics and to gain practical experience in applying machine learning models to real-world data.


## Project Structure
- `WebScraper.R`: Script for web scraping match data from premierleague.com website
- `DataProcessing.R`: Script for data cleaning and preprocessing
- `Vizualization.R`: Script for data visualization (Includes multiple Vizualization techniques)
- `DecisionTreeClassifier.R`: Script for training the Decision Tree model
- `RandomForest.R`: Script for training the Random Forest model
- `Data/`: Directory containing sample data (Try running the scraper and renaming the file to which you write to)
- `Vizualization/`: Directory containing sample vizualization images 

## Results

Decision Tree Classifier: ~67% accuracy

Random Forest: ~78% accuracy

Both of these could be improved as well as depends what features they are making predicitions on, we took some of the obvious ones to not get 100% accuracy

## Usage

1. Clone the repository on your machine (Make sure you have R Studio installed on your computer for running the scripts and seeing the vizualization on the side bar)

2. Run the WebScraper.R script to get the all_matches_data.csv file which is a huge data set containing results and statistics from 3 seasons of premier league (2023/2024 || 2022/2023 || 2021/2022).
You can adjust to have more seasons, I left comments in the WebScraper.R file which explains how to do that.

3. After you got the large file you can upload it on google docs to be able to view the file, keep in mind its very large file

4. You can try running the DataProcessing.R script for pre processing the data we scraped in the previous step

5. After you got the clean data you can try running the vizualization scripts to get a better idea about the teams and matches between different teams

6. After All you can try running the decision tree classifier or the random forrest to see the accuracy of the models.

7. ***Very Important*** make sure to load the correct files, I might have missed adding some files but you should be able to scrape them if anything, you might need to tweak the DataProcessing.R script for being able to run all the vizualization techniques, I will update them later.

8. ***Also Very Important*** Make sure to install the libraries needed before loading them.


## Data

We have included a subset of the data we gathered. To collect the most recent data, run the scraper script. The data includes close to 2500 matches from previous 3 seasons of premier league. Each row represents a match between two teams, each match has a result of win, draw or lose and we specify which team won by writing Team1_Win or Team2_Win or Draw. Team1 is the Team playing at Home and Team 2 is the one playing away. Remember there are some stats which occured during one game but did not happen during another game such as yellow cards, or other stats.

## Contributing

Contributions are always welcome! Please open an issue or submit a pull request.



