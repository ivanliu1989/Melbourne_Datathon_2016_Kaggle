setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
library(data.table)
load('../data/model/total.RData')
source('./rscripts/0.ngram_split_func.R')

# text_vector <- paste0(total[,'title'],'. ', total[,'abstract'])
text_vector <- total[,'title']

text_vector <- iconv(text_vector, to = 'utf-8', sub=' ')
review_source <- VectorSource(text_vector)
corpus <- Corpus(review_source)
corpus <- tm_map(corpus, content_transformer(tolower), lazy = T)
corpus <- tm_map(corpus, removePunctuation, lazy = T)
corpus <- tm_map(corpus, removeNumbers, lazy = T)
corpus <- tm_map(corpus, removeWords, stopwords('english'), lazy = T)
corpus <- tm_map(corpus, stripWhitespace, lazy = T)
corpus <- tm_map(corpus, stemDocument, 'english', lazy = T)
# 
# library("RWeka")
# library(parallel)
# options(mc.cores=1)
# BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 1, max = 3))
# dtm_bigram <- DocumentTermMatrix(corpus, control = list(tokenize = BigramTokenizer))
dtm <- DocumentTermMatrix(corpus, control = list(minDocFreq = 2, wordLengths = c(3, Inf)),
                          bounds=list(global=c(floor(length(corpus)*0.05), Inf))) # , weighting = weightTfIdf

library(Matrix)
dtm_sim <- removeSparseTerms(dtm, 1 - 3/nrow(dtm))
# dtm_sim <- dtm[,findFreqTerms(dtm,1)] # 5
dtm2 <- sparseMatrix(dtm_sim$i,dtm_sim$j,x=dtm_sim$v)
dim(dtm2)
all <- cbind(job_id = total$job_id, dtm2, hat = total$hat)
train <- all[all[,'hat'] != -1, ]
test <- all[all[,'hat'] == -1, ]
colnames(train) <- c('job_id', paste0('var_', 1:(ncol(train)-2)), 'hat')
colnames(test) <- c('job_id', paste0('var_', 1:(ncol(train)-2)), 'hat')

# remove features not in test
rm_feat <- colSums(test)
test <- test[,rm_feat!=0]
train <- train[,rm_feat!=0]

rm_feat <- colSums(train)
test <- test[,rm_feat!=0]
train <- train[,rm_feat!=0]

save(train,test, file ='../model_unigram_idf_2.RData')

