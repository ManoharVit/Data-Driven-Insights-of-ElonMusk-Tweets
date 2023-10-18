# Install & import modules
library(httr)
library(utils)
library(readxl)
library(networkD3)
library(igraph)
library(dplyr)
library(tibble)
library(ggplot2)

# Prepare the data

# download Keyword_data.xlsx
url <- "https://docs.google.com/spreadsheets/d/1GTwv07i98vL7S-J9eeP8NV1fJVnymm1eJ31RDyt4Mxw/export?format=xlsx"
GET(url, write_disk("Keyword_data.xlsx"))

# download Elon Musk's tweets
url <- "https://drive.google.com/file/d/1qIOwcJyLSmQvOw0lndZ3i5VfQWSrZzfd/view?usp=sharing"
GET(url, write_disk("MuskTweetsarc.zip"))

# unzip
unzip("MuskTweetsarc.zip") 
# Read data
df <- read_excel("Keyword_data.xlsx")
df <- df[, -1]  # Select all columns except the first one
df <- df[!apply(is.na(df), 1, all), ]  # Remove rows with all NA values
df <- df[ , , drop = FALSE]  # Ensure that the result remains a data frame
rownames(df) <- NULL

# Create adjacency matrix
# Initialize an empty vector to store keywords
# extract keyword data from the file and convert it to a weighted adjacency matrix.

# read all unique values from the dataset
keywords <- unique(unlist(df))

# create a new dataframe to store weighted adjacency matrix
matrix <- matrix(0, nrow = length(keywords), ncol = length(keywords))
colnames(matrix) <- keywords
rownames(matrix) <- keywords

# read data for each row
for (row in 1:nrow(df)) {
  # get one value from current row
  for (first_value_col_index in 1:ncol(df)) {
    # if this value is NaN, then break the loop
    if (is.na(df[row, first_value_col_index])) {
      break
    }
    # get another value from current row
    for (second_value_col_index in (first_value_col_index + 1):ncol(df)) {
      # if this value is NaN, then break the loop
      if (is.na(df[row, second_value_col_index])) {
        break
      }
      # record data in the two positions corresponding to the adjacency matrix
      matrix[df[row, first_value_col_index], df[row, second_value_col_index]] <- matrix[df[row, first_value_col_index], df[row, second_value_col_index]] + 1
      matrix[df[row, second_value_col_index], df[row, first_value_col_index]] <- matrix[df[row, second_value_col_index], df[row, first_value_col_index]] + 1
    }
  }
}

head(matrix, 10)

# Create a graph from adjacency matrix
G <- graph.adjacency(as.matrix(matrix), mode = "undirected", weighted = TRUE)

# Plot the graph
set.seed(123)
plot(G, layout = layout_with_sugiyama(G), vertex.color = "#40a6d1", edge.color = "#52bced", vertex.label = NA)

# Show the top 10 nodes by degree
degree_df <- as.data.frame(degree(G))
degree_df <- degree_df[order(degree_df$degree, decreasing = TRUE), ]
head(degree_df, 10)

# Show top 10 nodes by strength
strength_df <- as.data.frame(strength(G, mode = "all", loops = FALSE))
strength_df <- strength_df[order(strength_df$strength, decreasing = TRUE), ]
head(strength_df, 10)

# Show the top 10 node pairs by weight
edge_weights <- as.data.frame(get.edgelist(G, names = FALSE))
edge_weights$weight <- E(G)$weight
edge_weights <- edge_weights[order(edge_weights$weight, decreasing = TRUE), ]
head(edge_weights, 10)

# Calculate average degree and average strength
average_degree <- mean(degree(G))
average_strength <- mean(strength(G, mode = "all", loops = FALSE))
cat("Average Degree:", average_degree, "\n")
cat("Average Strength:", average_strength, "\n")

# Plot average strength on y-axis and degree on x-axis
avg_degree_strength <- data.frame(AverageDegree = average_degree, AverageStrength = average_strength)
ggplot(avg_degree_strength, aes(x = AverageDegree, y = AverageStrength)) +
  geom_point() +
  labs(x = "Average Degree", y = "Average Strength")

# Task 2

# Compute word frequencies for each year
years <- 2017:2022
frequencies <- list()

for (year in years) {
  file_name <- paste0(year, ".csv")
  tweets <- read.csv(file_name)$tweet
  words <- list()
  
  for (tweet in tweets) {
    tweet <- gsub("@\\w+", "", tweet)
    tweet <- gsub("&\\w+;", "", tweet)
    tweet <- gsub("(https|http)://t.co/\\w+", "", tweet)
    words <- c(words, tolower(unlist(strsplit(tweet, "\\W+"))))
  }
  
  word_counts <- table(words)
  total_words <- sum(word_counts)
  frequencies[[year]] <- data.frame(
    Word = names(word_counts),
    Count = as.numeric(word_counts),
    Frequency = as.numeric(word_counts) / total_words
  )
}

# Show top 10 words (for each year) by the highest value of word frequency
for (year in years) {
  cat("=== ", year, " ===\n")
  freq_df <- frequencies[[year]]
  freq_df <- freq_df[order(freq_df$Frequency, decreasing = TRUE), ]
  print(head(freq_df, 10))
}

# Plot histogram of word frequencies for each year
for (year in years) {
  freq_df <- frequencies[[year]]
  freq_df <- freq_df[order(freq_df$Frequency, decreasing = TRUE), ]
  freq_df <- freq_df[1:50, ]
  
  ggplot(freq_df, aes(x = reorder(Word, -Frequency), y = Frequency)) +
    geom_bar(stat = "identity") +
    labs(title = paste("Top 50 most frequent words in", year),
         x = "Words",
         y = "Count") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

# Use Zipf’s law and plot log-log plots of word frequencies and rank for each year
for (year in years) {
  freq_df <- frequencies[[year]]
  freq_df <- freq_df[order(freq_df$Frequency, decreasing = TRUE), ]
  freq_df$Rank <- 1:nrow(freq_df)
  
  ggplot(freq_df, aes(x = log(Rank), y = log(Frequency))) +
    geom_line() +
    labs(title = paste("log-log plots of word frequencies and rank for", year),
         x = "log(Rank)",
         y = "log(Frequency)")
}

# Compute bigrams for each tweet
bigram_for_each_tweet <- lapply(tweet_words, function(tweet) {
  bigrams(tweet)
})

# Flatten the list of bigrams
bigram <- unlist(bigram_for_each_tweet)

# Count the occurrence of each bigram using the 'table' function
bigram_counts <- as.data.frame(table(bigram))
colnames(bigram_counts) <- c("bigram", "count")

# Sort the bigrams by count in descending order
bigram_counts <- bigram_counts[order(bigram_counts$count, decreasing = TRUE), ]

cat(paste("======= bigram of", year, " =======\n"))
print(bigram_counts)

# Store the results for further analysis
bigram_result[[year]] <- bigram_counts

# Create bigram network graphs for each year
for (year in years) {
  cat(paste("========= bigram network graph of", year, " ==========\n"))
  bigram_data <- bigram_result[[year]][1:50, ]
  
  # Set up the figure size
  plot.new()
  par(mar = c(5, 4, 4, 2))
  
  # Create a directed graph
  G <- graph.data.frame(bigram_data, directed = TRUE)
  
  # Set the edge weights
  edge_weights <- 10 * bigram_data$count
  
  # Create node positions using layout_with_fr for visualization
  pos <- layout_with_fr(G)
  
  # Plot the figure
  plot(G, layout = pos, edge.arrow.size = 0.5, vertex.color = "#40a6d1", vertex.label = NA)
  title(main = paste("Bigram Network Graph of", year))
}
