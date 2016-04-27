setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
load('../data/model/total.RData')
source('./rscripts/a.preprocess_func.R')

### 1.TF/IDF features - title, abstract, raw_job_type, raw_location
text_vector <- total[total$class_id == 1212,'title']
dtm_title <- tfidf_func(text_vector, ngrams = 1, minDocFreq = 1, wordLengths = 3, idf = FALSE);
dtm2 <- as.matrix(dtm_title)
frequency <- colSums(dtm2)
frequency <- sort(frequency, decreasing=TRUE)
head(frequency,20)
dtm_sim <- dtm_title[,findFreqTerms(dtm_title,10)] # 5


# COUNTS
# ALL FREQ 