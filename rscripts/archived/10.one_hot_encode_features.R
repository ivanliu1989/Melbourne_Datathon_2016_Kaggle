setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
library(data.table)
load('../data/model/total.RData')
source('./rscripts/0.ngram_split_func.R')

table(total$salary_type)
# table(total$salary_min)
# table(total$salary_max)
# table(total$salary_max-total$salary_min)
# table(total$location_id)
table(total$raw_job_type)
# table(total$Segment)

######################
### raw_job_type #####
######################
text_vector <- total[,'raw_job_type']

text_vector <- iconv(text_vector, to = 'utf-8', sub=' ')
review_source <- VectorSource(text_vector)
corpus <- Corpus(review_source)
corpus <- tm_map(corpus, content_transformer(tolower), lazy = T)
corpus <- tm_map(corpus, removePunctuation, lazy = T)
corpus <- tm_map(corpus, stripWhitespace, lazy = T)
corpus <- tm_map(corpus, removeWords, stopwords('english'), lazy = T)
corpus <- tm_map(corpus, stemDocument, 'english', lazy = T)

library("RWeka")
library(parallel)
options(mc.cores=1)
BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 1, max = 3))
dtm_bigram <- DocumentTermMatrix(corpus, control = list(tokenize = BigramTokenizer))

library(Matrix)
dtm_sim <- dtm[,findFreqTerms(dtm,100)] # 5
dtm2 <- sparseMatrix(dtm_sim$i,dtm_sim$j,x=dtm_sim$v)
dim(dtm2)

#####################
### salary_type #####
#####################
salary_type <- 

all <- cbind(job_id = total$job_id, dtm2, salary_type = salary_type, hat = total$hat)
train <- all[all[,'hat'] != -1, ]
test <- all[all[,'hat'] == -1, ]
colnames(train) <- c('job_id', paste0('var_', 1:(ncol(train)-2)), 'hat')
colnames(test) <- c('job_id', paste0('var_', 1:(ncol(train)-2)), 'hat')

# remove features not in test
rm_feat <- colSums(test)
test <- test[,rm_feat!=0]
train <- train[,rm_feat!=0]

save(train,test, file ='../model_bigram_freq_100.RData')

