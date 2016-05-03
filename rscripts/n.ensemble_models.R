setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
load('../data/model/total.RData')
load('../data_new/model_bigram_idf_20160501_scale_full.RData')
library(xgboost)
library(caret)
library(Matrix)
library(caTools)

### Split Data ###
set.seed(19890624)
cv <- 20
folds <- createFolds(train[,'obj_hat'], k = cv, list = FALSE)
dropitems <- c('job_id','obj_hat', extra_feature)
feature.names <- colnames(train)[!colnames(train) %in% dropitems] 

for(i in 1:cv){
    f <- folds == i
    dval          <- xgb.DMatrix(data=train[f,feature.names],label=train[f,'obj_hat'])
    dtrain        <- xgb.DMatrix(data=train[!f,feature.names],label=train[!f,'obj_hat']) 
    watchlist     <- list(val=dval,train=dtrain)
    clf <- xgb.train(data                = dtrain,
                     nrounds             = 3000, 
                     early.stop.round    = 50,
                     watchlist           = watchlist,
                     eval_metric         = 'auc',                                       
                     # feval                = eval_cus,
                     maximize            = TRUE,
                     objective           = "binary:logistic",
                     booster             = "gbtree", # gblinear
                     eta                 = 0.15,
                     max_depth           = 18,
                     # min_child_weight    = 10,
                     subsample           = .8,
                     colsample           = .3,
                     print.every.n       = 1
    )
    cat(paste0('Iteration: ', i, ' || Score: ', 2*(clf$bestScore-0.5)))
    
    submissions <- predict(clf, test[,feature.names])
    submissions <- cbind(job_id = test[,'job_id'], hat = submissions)
    options(scipen = 3)
    write.csv(submissions, file=paste0('./pred/submit_bigrams_iter_',i,'_cvscore_',2*(clf$bestScore-0.5),'.csv'), row.names = F)
}
