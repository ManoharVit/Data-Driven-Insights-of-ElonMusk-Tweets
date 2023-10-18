# Data-Driven-Insights-of-ElonMusk-Tweets
Conduct a word frequency analysis and keyword network analysis of Elon Musk's tweets. Transform the extracted keyword information from the aforementioned file into a weighted adjacency matrix. Plotting log-log graphs of word frequencies and ranks for each year using Zipf's law. Show bigram network graphs for each year.

The project involves performing keyword network analysis and word frequency analysis on a dataset containing Elon Musk's Twitter data from 2017 to 2022. Here's a breakdown of the code and its execution:

# Data Preparation
The code begins by downloading two datasets: "Keyword_data.xlsx" and "archive.zip," which contain keyword data and Musk's tweets, respectively. These datasets are obtained using the httr package's GET function and saved locally.

## Task 1: Keyword Network Analysis
This section of the code focuses on creating a weighted adjacency matrix, constructing a network graph, and analyzing node degree, strength, and weighted node pairs.

The "Keyword_data.xlsx" file is read into an R dataframe (df) for analysis. Missing values are removed, and the dataframe is used to create a weighted adjacency matrix.

A network graph (G) is constructed from the adjacency matrix, and the graph is visualized using the igraph package.

The top 10 nodes by degree and top 10 nodes by strength are displayed.

A scatter plot is generated with average strength on the y-axis and degree on the x-axis to explore the relationship between these network properties.

## Task 2: Word Frequency Analysis
This section of the code focuses on computing word frequencies, identifying top words, plotting histograms, and analyzing word frequency distributions.
Word frequencies are computed for each year from 2017 to 2022 using the Twitter data. Stop words are excluded.

The top 10 words with the highest word frequencies for each year are displayed.

Histograms of word frequencies are plotted for each year, showing the top 50 most frequent words.

Log-log plots of word frequencies and ranks are generated for each year to explore Zipf's law.

## Task 3: Bigram Network Analysis
This section of the code focuses on extracting and analyzing bigrams (pairs of adjacent words) and constructing bigram network graphs. Bigrams are extracted from the Twitter data for each year, and their counts are computed.

The top bigrams for each year are displayed.

Bigram network graphs are created for each year, with edges weighted by the frequency of bigram occurrences. The bigram network graphs are visualized for analysis.

Overall, the code successfully accomplishes the tasks outlined in the problem statement, providing insights into keyword network analysis and word frequency analysis for Elon Musk's Twitter data from 2017 to 2022
