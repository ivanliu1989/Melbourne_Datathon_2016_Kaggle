setwd('C:\\Users\\iliu2\\Datathon 2016')
files <- list.files('./data', full.names = T)

library(data.table)
job_jobs <- fread(files[4])

job_title_1 <- job_jobs[hat == 1,title]

job_title_0 <- job_jobs[hat == 0,title]

library(tm)
# Positive counts
review_source <- VectorSource(job_title_1)
corpus <- Corpus(review_source)
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, stripWhitespace)
corpus <- tm_map(corpus, removeWords, stopwords('english'))
dtm <- DocumentTermMatrix(corpus)
dtm2 <- as.matrix(dtm)
frequency <- colSums(dtm2)
frequency <- sort(frequency, decreasing=TRUE)
head(frequency,20)

# Negative counts
review_source <- VectorSource(job_title_0)
corpus <- Corpus(review_source)
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, stripWhitespace)
corpus <- tm_map(corpus, removeWords, stopwords('english'))
dtm <- DocumentTermMatrix(corpus)
dtm2 <- as.matrix(dtm)
frequency <- colSums(dtm2)
frequency <- sort(frequency, decreasing=TRUE)
head(frequency,20)