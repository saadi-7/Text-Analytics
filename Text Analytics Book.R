library(tidytext)
library(gutenbergr)
library(tidyverse)

titles <- c("Twenty Thousand Leagues under the Sea", 
            "Pride and Prejudice", 
            "The Iliad",
            "Great Expectations")
my_mirror <- "http://mirrors.xmission.com/gutenberg/"

books <- gutenberg_works(title %in% titles) %>%
  gutenberg_download(meta_fields = "title",
                     mirror = my_mirror)

books

# divide into documents, each representing one chapter
by_chapter <- books %>%
  group_by(title) %>%
  mutate(chapter = cumsum(str_detect(
    text, regex("^chapter ", ignore_case = TRUE)
  ))) %>%
  ungroup() %>%
  unite(document, title, chapter)

by_chapter

# split into words
by_chapter_word <- by_chapter %>%
  unnest_tokens(output = word ,
                input = text )
by_chapter_word

# find document-word counts
word_counts <- by_chapter_word %>%
  anti_join(stop_words)  %>% 
  count(document,word,sort=T)
word_counts

# Make into DTM
chapters_dtm <- word_counts %>%
  cast_dtm(document = document ,
           term = word,
           value = n)
chapters_dtm

# Do Topic Modeling, 4 topics
library(topicmodels)
chapters_lda <- LDA(chapters_dtm, k = 4, 
                    control = list(seed = 1234))

# Grab the topic-word probabilities (this is for beta)
chapter_topics <- tidy(chapters_lda,
                       matrix = "beta")

chapter_topics

# What are the most common words in each topic
top_terms <- chapter_topics %>%
  group_by(topic) %>%
  slice_max(order_by= beta, n = 5) %>% 
  ungroup() %>%
  arrange(topic, -beta)
top_terms

# Make a plot
top_terms %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(x = beta, y = term, fill = factor(topic) )) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~factor(topic)  , scales = "free" ) +
  scale_y_reordered()
#factor for topic makes it distinct color 


#Get document-topic probabilities
chapters_gamma <- tidy(chapters_lda,
                       matrix = "gamma")

chapters_gamma
# Split Title and Chapter
chapters_gamma <- chapters_gamma %>%
  separate(document, c("title", "chapter"),
           sep = "_", convert = TRUE)
chapters_gamma
#convert makes numbers into a numeric column 
# - good since we have chapters
#convert makes it numeric

# Make a boxplot of the distribution of 
#topics in each book

chapters_gamma %>%
  ggplot() +
  geom_boxplot(aes(x = factor(topic), y = gamma)) +
  facet_wrap(~ title) +
  labs(x = "topic", y = expression(gamma))

# We found an extra chapter lying around

book_ex <- gutenberg_works(title == "Emma") %>%
  gutenberg_download(meta_fields = "title",mirror = my_mirror)
#OR
#book_ex <- read_csv("In-Class-Exercises/class_book_ex.csv",)

book_ex_ch <- book_ex %>%
  group_by(title) %>%
  mutate(chapter = cumsum(str_detect(
    text, regex("^chapter ", ignore_case = TRUE)
  ))) %>%
  ungroup() %>%
  unite(document, title, chapter)

book_ex_ch
# split into words and just keep a single chapter
by_chapter_ex <- book_ex_ch %>%
   unnest_tokens(input=text, output=word)%>% 
  filter(document =="Emma_10" )
by_chapter_ex

# Append to previous data
by_ch_word_2 <- by_chapter_word %>% 
              bind_rows(by_chapter_ex)



word_counts2 <- by_ch_word_2 %>%
  anti_join(stop_words)%>% #remove stops
  count(document,word,sort=T) #count doc and word

word_counts2

# Make DTM
chapters_dtm2 <- word_counts2 %>%
  cast_dtm(document = document, 
           term = word , 
           value = n)

chapters_lda2 <- LDA(chapters_dtm2, k = 4, 
                     control = list(seed = 1234))

chapters_gamma2 <- tidy(chapters_lda2, 
                        matrix = "gamma")

#Just get the vector for Ch 10 of Emma
test_gamma <- chapters_gamma2 %>% 
  filter(document == "Emma_10") %>% 
  pull()

#Remove that chapter from the dataset
gam_tib <- chapters_gamma2 %>% 
  filter(document != "Emma_10") %>% 
  split(.$document) %>% #within documents
  map(select,c(document,gamma)) %>% # Grab these columns
  tibble(gamma_vector = .)  #Make it a tibble
  
unnest(cols = gamma_vector,gam_tib[1,])
gam_tib

install.packages("lsa")
library(lsa)

similarity <- c()
for(i in 1:170){
  similarity[i] <- gam_tib[i,] %>% 
    unnest(cols = gamma_vector) %>% 
    pull(gamma) %>% 
    cosine(test_gamma) %>% 
    #test each documents' gamma against the test
    as.numeric()
}
similarity
tibble(similarity = similarity,
       doc = 1:170) %>% 
  arrange(desc(similarity))


gam_tib %>% 
  slice(97) %>% 
  unnest(cols = gamma_vector)
