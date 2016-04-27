setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls())
library(data.table)
source('./rscripts/RCodeForGini.R')
load('../data/model/jobs.RData')

job_jobs <- as.data.table(job_jobs)
job_title_1 <- job_jobs[hat == 1,title]
job_title_0 <- job_jobs[hat == 0,title]

library(tm)
library(SnowballC)
# Positive counts
job_title_1 <- iconv(job_title_1, to = 'utf-8', sub=' ')
review_source <- VectorSource(job_title_1)
corpus <- Corpus(review_source)
# corpus <- tm_map(corpus, str_replace_all,"[^[:alnum:]]"," ", lazy = T)
corpus <- tm_map(corpus, content_transformer(tolower), lazy = T)
corpus <- tm_map(corpus, removePunctuation, lazy = T)
corpus <- tm_map(corpus, stripWhitespace, lazy = T)
corpus <- tm_map(corpus, removeWords, stopwords('english'), lazy = T)
dtm <- DocumentTermMatrix(corpus)
dtm2 <- as.matrix(dtm)
frequency <- colSums(dtm2)
frequency <- sort(frequency, decreasing=TRUE)
head(frequency,20)

freq_pos <- frequency
save(freq_pos, file = 'freq_pos.RData')

# Negative counts
job_title_0 <- iconv(job_title_0, to = 'utf-8', sub=' ')
review_source <- VectorSource(job_title_0)
corpus <- Corpus(review_source)
# corpus <- tm_map(corpus, str_replace_all,"[^[:alnum:]]"," ", lazy = T)
corpus <- tm_map(corpus, content_transformer(tolower), lazy = T)
corpus <- tm_map(corpus, removePunctuation, lazy = T)
corpus <- tm_map(corpus, stripWhitespace, lazy = T)
corpus <- tm_map(corpus, removeWords, stopwords('english'), lazy = T)
dtm <- DocumentTermMatrix(corpus)
dtm2 <- as.matrix(dtm)
frequency <- colSums(dtm2)
frequency <- sort(frequency, decreasing=TRUE)
head(frequency,20)

freq_neg <- frequency
save(ferq_neg, 'freq_neg.RData')
