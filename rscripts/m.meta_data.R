setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
load('../data/model/total.RData')
load('../data_new/model_bigram_idf_20160501_scale_full.RData')
library(xgboost)
library(caret)
library(Matrix)
library(caTools)
library(doMC)
library(e1071)
library(Hmisc)
registerDoMC(cores = 4)

# meta_feature <-  total[total$hat != -1, c('job_id','class_id')]
# meta_feature[, 3:33] <- -1
# class_id <- meta_feature[, 'class_id']
# class_id[is.na(class_id)] <- 1
# class_id <- as.factor(class_id)
# levels(class_id) <- c(0:30)
# class_id <- as.numeric(class_id)-1

### Split Data ###
set.seed(23)
cv <- 2
folds <- createFolds(train[,'obj_hat'], k = cv, list = FALSE)
f <- folds ==1 
train_a <- train[f,]
train_b <- train[!f,]

### xgb
dropitems <- c('job_id','obj_hat', extra_feature) # [92:153]
feature.names <- colnames(train)[!colnames(train) %in% dropitems] 

dval          <- xgb.DMatrix(data=train_a[,feature.names],label=train_a[,'obj_hat'])
dtrain        <- xgb.DMatrix(data=train_b[,feature.names],label=train_b[,'obj_hat']) 
watchlist     <- list(val=dval,train=dtrain)
clf <- xgb.train(data = dtrain, nrounds = 500, early.stop.round = 10, watchlist = watchlist,
                 eval_metric = 'auc', objective = "binary:logistic",
                 booster = "gbtree",  eta = 0.3, max_depth = 8, subsample = .8, colsample= .4, print.every.n= 1)
train_ngrams_a <- predict(clf, train_a[,feature.names])

dval          <- xgb.DMatrix(data=train_b[,feature.names],label=train_b[,'obj_hat'])
dtrain        <- xgb.DMatrix(data=train_a[,feature.names],label=train_a[,'obj_hat']) 
watchlist     <- list(val=dval,train=dtrain)
clf <- xgb.train(data = dtrain, nrounds = 500, early.stop.round = 10, watchlist = watchlist,
                 eval_metric = 'auc', objective = "binary:logistic",
                 booster = "gbtree",  eta = 0.3, max_depth = 8, subsample = .8, colsample= .4, print.every.n= 1)
train_ngrams_b <- predict(clf, train_b[,feature.names])

dval          <- xgb.DMatrix(data=train[,feature.names],label=train[,'obj_hat'])
dtrain        <- xgb.DMatrix(data=train[,feature.names],label=train[,'obj_hat']) 
watchlist     <- list(val=dval,train=dtrain)
clf <- xgb.train(data = dtrain, nrounds = 500, early.stop.round = 10, watchlist = watchlist,
                 eval_metric = 'auc', objective = "binary:logistic",
                 booster = "gbtree",  eta = 0.3, max_depth = 8, subsample = .8, colsample= .4, print.every.n= 1)
test_ngrams <- predict(clf, test[,feature.names])

### xgb - impressions
dropitems <- c('job_id','obj_hat', extra_feature[92:153]) # [92:153]
feature.names <- colnames(train)[!colnames(train) %in% dropitems] 

dval          <- xgb.DMatrix(data=train_a[,feature.names],label=train_a[,'obj_hat'])
dtrain        <- xgb.DMatrix(data=train_b[,feature.names],label=train_b[,'obj_hat']) 
watchlist     <- list(val=dval,train=dtrain)
clf <- xgb.train(data = dtrain, nrounds = 500, early.stop.round = 10, watchlist = watchlist,
                 eval_metric = 'auc', objective = "binary:logistic",
                 booster = "gbtree",  eta = 0.3, max_depth = 8, subsample = .8, colsample= .4, print.every.n= 1)
train_user_a <- predict(clf, train_a[,feature.names])

dval          <- xgb.DMatrix(data=train_b[,feature.names],label=train_b[,'obj_hat'])
dtrain        <- xgb.DMatrix(data=train_a[,feature.names],label=train_a[,'obj_hat']) 
watchlist     <- list(val=dval,train=dtrain)
clf <- xgb.train(data = dtrain, nrounds = 500, early.stop.round = 10, watchlist = watchlist,
                 eval_metric = 'auc', objective = "binary:logistic",
                 booster = "gbtree",  eta = 0.3, max_depth = 8, subsample = .8, colsample= .4, print.every.n= 1)
train_user_b <- predict(clf, train_b[,feature.names])

dval          <- xgb.DMatrix(data=train[,feature.names],label=train[,'obj_hat'])
dtrain        <- xgb.DMatrix(data=train[,feature.names],label=train[,'obj_hat']) 
watchlist     <- list(val=dval,train=dtrain)
clf <- xgb.train(data = dtrain, nrounds = 500, early.stop.round = 10, watchlist = watchlist,
                 eval_metric = 'auc', objective = "binary:logistic",
                 booster = "gbtree",  eta = 0.3, max_depth = 8, subsample = .8, colsample= .4, print.every.n= 1)
test_user <- predict(clf, test[,feature.names])

save(train_a, train_b, 
     train_ngrams_a,train_ngrams_b,test_ngrams,
     train_user_a,train_user_b,test_user, folds,
     file = '/home/rstudio/meta_data_xgb.RData')

### glmnet
library(glmnet)
dropitems <- c('job_id','obj_hat', extra_feature) # [92:153]
feature.names <- colnames(train)[!colnames(train) %in% dropitems] 

glm <- glmnet(x=train_b[,feature.names], y=train_b[,'obj_hat'], family='binomial')
train_ngrams_glm_a <- predict(glm, train_a[,feature.names])

glm <- glmnet(x=train_a[,feature.names], y=train_a[,'obj_hat'], family='binomial')
train_ngrams_glm_b <- predict(glm, train_b[,feature.names])

glm <- glmnet(x=train[,feature.names], y=train[,'obj_hat'], family='binomial')
test_ngrams_glm <- predict(glm, test[,feature.names])

### glmnet - impression
dropitems <- c('job_id','obj_hat', extra_feature[92:153]) # [92:153]
feature.names <- colnames(train)[!colnames(train) %in% dropitems] 

glm <- glmnet(x=train_b[,feature.names], y=train_b[,'obj_hat'], family='binomial')
train_user_glm_a <- predict(glm, train_a[,feature.names])

glm <- glmnet(x=train_a[,feature.names], y=train_a[,'obj_hat'], family='binomial')
train_user_glm_b <- predict(glm, train_b[,feature.names])

glm <- glmnet(x=train[,feature.names], y=train[,'obj_hat'], family='binomial')
test_user_glm <- predict(glm, test[,feature.names])


save(train_a, train_b, 
     train_ngrams_a,train_ngrams_b,test_ngrams,
     train_user_a,train_user_b,test_user,
     train_ngrams_glm_a, train_ngrams_glm_b, test_ngrams_glm,
     train_user_glm_a, train_user_glm_b, test_user_glm,
     folds,
     file = '/home/rstudio/meta_data_xgb.RData')
