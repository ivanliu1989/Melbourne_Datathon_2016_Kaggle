setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
# load('../data/model/total.RData')
# load('../model_unigram_idf_final_scale_20160428.RData')
load('../data_new/model_unigram_idf_final_20160428.RData')
library(xgboost)
library(caret)
library(Matrix)
library(caTools)
# class_id <- total$class_id
# rm(total); gc()

### Split Data ###
set.seed(23)
cv <- 10
folds <- createFolds(train[,'obj_hat'], k = cv, list = FALSE)
dropitems <- c('job_id','obj_hat')
feature.names <- colnames(train)[!colnames(train) %in% dropitems] 
i=3
f <- folds==i
dval          <- xgb.DMatrix(data=train[f,feature.names],label=train[f,'obj_hat'])
dtrain        <- xgb.DMatrix(data=train[,feature.names],label=train[,'obj_hat']) 
watchlist     <- list(val=dval,train=dtrain)
clf <- xgb.train(data                = dtrain,
                 nrounds             = 500, 
                 early.stop.round    = 300,
                 watchlist           = watchlist,
                 eval_metric         = 'auc',
                 # feval                = eval_cus,
                 maximize            = TRUE,
                 objective           = "binary:logistic",
                 booster             = "gbtree", # gblinear
                 eta                 = 0.1,
                 max_depth           = 22,
                 min_child_weight    = 5,
                 subsample           = .8,
                 colsample           = .4,
                 print.every.n       = 1
)