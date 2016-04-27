setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
load('../data/model/total.RData')
load('../model_unigram_idf_final_scale.RData')
library(xgboost)
library(caret)
library(Matrix)
library(caTools)
class_id <- total$class_id
rm(total); gc()

############
# xgb ####
############
evalerror = function(preds, dtrain) {
    labels <- getinfo(dtrain, "hat")
    err <- colAUC(preds,labels,plotROC=FALSE)[1]
    err <- 2 * (err - 0.5)
    return(list(metric = "gini", value = err))
}
### Split Data ###
set.seed(23)
cv <- 10
folds <- createFolds(train[,'hat'], k = cv, list = FALSE)
dropitems <- c('job_id','hat')
feature.names <- colnames(train)[!colnames(train) %in% dropitems] 
i=2
for(i in 1:cv){
    f <- folds==i
    # 1. xgboost 0.94703
    dval          <- xgb.DMatrix(data=train[f,feature.names],label=train[f,'hat'])
    dtrain        <- xgb.DMatrix(data=train[!f,feature.names],label=train[!f,'hat']) 
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
                     subsample           = .9,
                     colsample           = .6,
                     print.every.n       = 1
    )
    cat(paste0('Iteration: ', i, ' || Score: ', 2*(clf$bestScore-0.5)))
}

############
# glm ####
############


###########
# vw ####
###a########