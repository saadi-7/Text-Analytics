# Text-Analytics
Gutenberg's text analytics on most common words 

Code Explanation and ReadMe
The given code is written in R programming language and is used to perform topic modeling on a set of books. The code uses the tidytext, gutenbergr, tidyverse, topicmodels, and lsa packages in R.

The code does the following:

Load the required libraries - tidytext, gutenbergr, and tidyverse.
Specify a list of titles and download the text of books from the Gutenberg Project.
Divide each book into documents, where each document represents one chapter, using the group_by(), mutate(), and unite() functions from the tidyverse package.
Split each chapter into words using the unnest_tokens() function from the tidytext package.
Find the document-word counts, remove stop words using the anti_join() function, and create a Document-Term Matrix (DTM) using the cast_dtm() function, all using the tidyverse package.
Do Topic Modeling with 4 topics using the LDA() function from the topicmodels package.
Get the topic-word probabilities and create a table of the top 5 most common words in each topic using the tidy() function from the topicmodels package, and then visualize it using ggplot2 package.
Get the document-topic probabilities using the tidy() function and separate the title and chapter using the separate() function from the tidyverse package.
Make a boxplot of the distribution of topics in each book using the ggplot2 package.
Add an extra chapter of the book "Emma" to the previous data and do the same steps from 4 to 9 with this data.
Use the lsa package to calculate the cosine similarity between the topic distributions of each chapter and a specific chapter of the book "Emma".
How to use the code?
Install the required packages - tidytext, gutenbergr, tidyverse, topicmodels, and lsa.
Set a list of book titles and a mirror for the Gutenberg Project. Alternatively, you can use the read_csv() function to read a CSV file containing the book texts and their titles.
Run the code to perform topic modeling on the books and analyze the results.
