setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
library(data.table)
load('../data/model/total.RData')
source('./rscripts/0.ngram_split_func.R')

text_vector <- total[,'title']

text_vector <- iconv(text_vector, to = 'utf-8', sub=' ')
review_source <- VectorSource(text_vector)
corpus <- Corpus(review_source)
corpus <- tm_map(corpus, content_transformer(tolower), lazy = T)
corpus <- tm_map(corpus, removePunctuation, lazy = T)
corpus <- tm_map(corpus, stripWhitespace, lazy = T)
corpus <- tm_map(corpus, removeWords, stopwords('english'), lazy = T)
corpus <- tm_map(corpus, stemDocument, 'english', lazy = T)

dtm <- DocumentTermMatrix(corpus)
# inspect(dtm[1:10,100:110])
# inspect(removeSparseTerms(dtm, 0.01))
library(Matrix)
dtm_sim <- dtm[,findFreqTerms(dtm,5)]
dtm2 <- sparseMatrix(dtm_sim$i,dtm_sim$j,x=dtm_sim$v)
# dtm2 <- as.matrix(dtm[,findFreqTerms(dtm,500)])
dim(dtm2)
all <- cbind(job_id = total$job_id, dtm2, hat = total$hat)
train <- all[all[,'hat'] != -1, ]
test <- all[all[,'hat'] == -1, ]
colnames(train) <- c('job_id', paste0('var_', 1:(ncol(train)-2)), 'hat')
colnames(test) <- c('job_id', paste0('var_', 1:(ncol(train)-2)), 'hat')

save(train,test, file ='../model.RData')

# remove features not in test
rm_feat <- colSums(test)
test <- test[,rm_feat!=0]
train <- train[,rm_feat!=0]

# train
library(xgboost)
library(caret)
### Split Data ###
set.seed(23)
cv <- 10
folds <- createFolds(train[,'hat'], k = cv, list = FALSE)
dropitems <- c('job_id','hat')
feature.names <- colnames(train)[!colnames(train) %in% dropitems] 

### Setup Results Table ###
results <- as.data.frame(matrix(rep(0,3*cv), cv))
names(results) <- c('cv_num', 'AUC', 'LogLoss')

nr <- 1500
sr <- 300
sp <- 0.01
md <- 11
mcw <- 1
ss <- 0.96
cs <- 0.45

### Start Training ###
for(i in 1:cv){
    f <- folds==i
    dval          <- xgb.DMatrix(data=train[f,feature.names],label=train[f,'hat'])
    dtrain        <- xgb.DMatrix(data=train[!f,feature.names],label=train[!f,'hat']) 
    watchlist     <- list(val=dval,train=dtrain)
    
    clf <- xgb.train(data                = dtrain,
                     nrounds             = nr, 
                     early.stop.round    = sr,
                     watchlist           = watchlist,
                     eval_metric         = 'logloss',
                     maximize            = FALSE,
                     objective           = "binary:logistic",
                     booster             = "gbtree",
                     eta                 = sp,
                     max_depth           = md,
                     min_child_weight    = mcw,
                     subsample           = ss,
                     colsample           = cs,
                     print.every.n       = 200
    )
    
    ### Make predictions
    cat(paste0('Iteration: ', i, ' || Score: ', clf$bestScore))
}




# ngrams
library("RWeka")
BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
dtm_bigram <- DocumentTermMatrix(corpus, control = list(tokenize = BigramTokenizer))

# library(tm); library(tau);
# tokenize_ngrams <- function(x, n=2) return(rownames(as.data.frame(unclass(textcnt(x,method="string",n=n)))))
# matrix <- DocumentTermMatrix(corpus,control=list(tokenize=tokenize_ngrams))
# 
# library(RTextTools)
# matrix <- create_matrix(text_vector,ngramLength=2)

