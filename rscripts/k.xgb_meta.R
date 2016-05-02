setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
load('../data/model/total.RData')
# load('../data_new/model_unigram_idf_20160501_scale.RData')
load('../data_new/model_trigram_idf_20160501_scale_full.RData')
library(xgboost)
library(caret)
library(Matrix)
library(caTools)

class_id <- total[total$hat >= 0, 'class_id']
class_id[is.na(class_id)] <- 1
table(total[is.na(class_id),'hat'])
class_id <- as.factor(class_id)
levels(class_id) <- c(0:30)
class_id <- as.numeric(class_id)-1
table(class_id)

### Split Data ###
set.seed(23)
cv <- 5
folds <- createFolds(class_id, k = cv, list = FALSE)
dropitems <- c('job_id','obj_hat', extra_feature[96:157])
feature.names <- colnames(train)[!colnames(train) %in% dropitems] 

meta <- data.frame()
for(i in 1:2){
    f <- folds %in% i    
    dval          <- xgb.DMatrix(data=train[f,feature.names],label=class_id[f])
    dtrain        <- xgb.DMatrix(data=train[!f,feature.names],label=class_id[!f]) 
    watchlist     <- list(val=dval,train=dtrain)
    clf <- xgb.train(data                = dtrain,
                     nrounds             = 600, 
                     early.stop.round    = 50,
                     watchlist           = watchlist,
                     eval_metric         = 'auc',      
                     maximize            = TRUE,
                     objective           = "multi:softprob",
                     booster             = "gbtree", # gblinear
                     eta                 = 0.2,
                     max_depth           = 12,
                     # min_child_weight    = 10,
                     subsample           = .8,
                     colsample           = .4,
                     print.every.n       = 1,
                     num_class           = 31
    )
    cat(paste0('Iteration: ', i, ' || Score: ', 2*(clf$bestScore-0.5)))
    
    submissions <- predict(clf, train[f,feature.names])
    meta <- rbind(meta, submissions)
}



