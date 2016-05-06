setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
load('./total.RData')
load('../data_new/model_bigram_idf_20160501_scale_full.RData')
library(xgboost)
library(caret)
library(Matrix)
library(caTools)

meta_feature <-  total[total$hat != -1, c('job_id','Segment')]
meta_feature[, 3:8] <- -2
class_id <- meta_feature[, 'Segment']
# class_id[is.na(class_id)] <- 1
class_id <- as.factor(class_id)
levels(class_id) <- c(0:5)
class_id <- as.numeric(class_id)-1

### Split Data ###
set.seed(23)
cv <- 2
folds <- createFolds(class_id, k = cv, list = FALSE)
f <- folds ==1 
train_a <- train[f,]
train_b <- train[!f,]

### xgb
dropitems <- c('job_id','obj_hat', extra_feature) # [92:153]
feature.names <- colnames(train)[!colnames(train) %in% dropitems] 

dval          <- xgb.DMatrix(data=train_a[,feature.names],label=class_id[f])
dtrain        <- xgb.DMatrix(data=train_b[,feature.names],label=class_id[!f]) 
watchlist     <- list(val=dval,train=dtrain)

clf <- xgb.train(data = dtrain, nrounds = 2000, early.stop.round = 20, watchlist = watchlist,
                 eval_metric = 'merror', objective = "multi:softprob",
                 booster = "gbtree",  eta = 0.3, max_depth = 8, subsample = .8, colsample= .4, print.every.n= 1,
                 num_class = 6)

train_seg_a <- predict(clf, train_a[,feature.names])

dval          <- xgb.DMatrix(data=train_b[,feature.names],label=class_id[!f])
dtrain        <- xgb.DMatrix(data=train_a[,feature.names],label=class_id[f]) 
watchlist     <- list(val=dval,train=dtrain)

clf <- xgb.train(data = dtrain, nrounds = 2000, early.stop.round = 20, watchlist = watchlist,
                 eval_metric = 'merror', objective = "multi:softprob",
                 booster = "gbtree",  eta = 0.3, max_depth = 8, subsample = .8, colsample= .4, print.every.n= 1,
                 num_class = 6)

train_seg_b <- predict(clf, train_b[,feature.names])

dval          <- xgb.DMatrix(data=train[,feature.names],label=class_id)
dtrain        <- xgb.DMatrix(data=train[,feature.names],label=class_id) 
watchlist     <- list(val=dval,train=dtrain)

clf <- xgb.train(data = dtrain, nrounds = 2000, early.stop.round = 20, watchlist = watchlist,
                 eval_metric = 'merror', objective = "multi:softprob",
                 booster = "gbtree",  eta = 0.3, max_depth = 8, subsample = .8, colsample= .4, print.every.n= 1,
                 num_class = 6)

test_seg <- predict(clf, test[,feature.names])

train_seg_a_m <- t(matrix(train_seg_a,6,length(train_seg_a)/6)); colnames(train_seg_a_m) <- paste0('meta_seg_',1:6)
train_seg_b_m <- t(matrix(train_seg_b,6,length(train_seg_b)/6)); colnames(train_seg_b_m) <- paste0('meta_seg_',1:6)
test_seg_m <- t(matrix(test_seg,6,length(test_seg)/6)); colnames(test_seg_m) <- paste0('meta_seg_',1:6)

save(train_seg_a_m, train_seg_b_m, test_seg_m, folds, file='./meta_seg.RData')


### test set
load('../data_new/meta_seg.RData')
f <- folds ==1 
train_a <- train[f,]
train_b <- train[!f,]

train_a <- cbind(train_a, train_seg_a_m)
train_b <- cbind(train_b, train_seg_b_m)

train <- rbind(train_a,train_b)
test <- cbind(test, test_seg_m)
extra_feature <- c(extra_feature, paste0('meta_seg_',1:6))
save(train, test, extra_feature, file = '../m.model_bigram_idf_scale_full_meta.RData')










