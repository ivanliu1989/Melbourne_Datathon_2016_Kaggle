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

############
# xgb ####
############
evalerror = function(preds, dtrain) {
    labels <- getinfo(dtrain, "obj_hat")
    err <- colAUC(preds,labels,plotROC=FALSE)[1]
    err <- 2 * (err - 0.5)
    return(list(metric = "gini", value = err))
}
### Split Data ###
set.seed(23)
cv <- 10
folds <- createFolds(train[,'obj_hat'], k = cv, list = FALSE)
dropitems <- c('job_id','obj_hat')
feature.names <- colnames(train)[!colnames(train) %in% dropitems] 
i=c(2,8)
for(i in 1:cv){
    f <- folds %in% i
    # 1. xgboost 0.991413/0.982826
    dval          <- xgb.DMatrix(data=train[f,feature.names],label=train[f,'obj_hat'])
    dtrain        <- xgb.DMatrix(data=train[!f,feature.names],label=train[!f,'obj_hat']) 
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
    cat(paste0('Iteration: ', i, ' || Score: ', 2*(clf$bestScore-0.5)))
}

############
# glm ####
############
library(glmnet)
set.seed(23)
cv <- 10
folds <- createFolds(train[,'obj_hat'], k = cv, list = FALSE)
f <- folds == 2 
fit <- glmnet(train[!f, 2:(ncol(train)-4)], as.factor(train[!f, 'obj_hat']),
              family = 'binomial', alpha = 1, standardize = TRUE,
              intercept = TRUE, thresh = 1e-7, maxit = 10^5, type.gaussian = 'naive',
              type.logistic = 'modified.Newton'
)
preds <- predict(fit, train[f,2:(ncol(train)-4)],type="class")
evalerror(as.numeric(preds[,32]),train[f,'obj_hat'])
# 0.7961559

############
# vw ####
###a########
# devtools::install_github("JohnLangford/vowpal_wabbit", subdir = "R/r.vw")
library(r.vw)
feat <- colnames(train)[2:(ncol(train)-1)]; target <- 'obj_hat'
train_dt <- dt2vw(data = train[!f,2:(ncol(train))], target = target, fileName = '../data/vw/train_dt.vw')
test_dt <- to_vw(train[f,], feat, target, '../data/vw/test_dt.vw')
write.table(test_dt[,hat], file='data/vw/test_labels.txt', row.names = F, col.names = F, quote = F)

training_data='../data/vw/train_dt.vw'
test_data='../data/vw/test_dt.vw'
test_labels = "../data/vw/test_labels.txt"
out_probs = "../data/vw/sub.txt"
model = "../data/vw/mdl.vw"

# AUC using perf - Download at: osmot.cs.cornell.edu/kddcup/software.html
# Shows files in the working directory: /data
list.files('../data/vw')
grid = expand.grid(eta=c(0.1, 0.3),
                   extra=c('--holdout_period 50 --normalized --adaptive --invariant', 
                           '--nn 30 --holdout_period 50 --normalized --adaptive --invariant',
                           '-q:: --holdout_period 50 --normalized --adaptive --invariant'))
for(i in 1:nrow(grid)){
    g = grid[i, ]
    out_probs = paste0("../data/vw/preds/submission_vw_20160428_NoReg_", g[['eta']], "_", i,".txt")
    model = paste0("../data/vw/mdl",i,".vw")
    # out_probs = paste0("predictions/submission_vw_20151126_0.25_1.txt")
    auc = vw(training_data, training_data, loss = "logistic",
             model, b = 30, learning_rate = g[['eta']], 
             passes = 10, l1=1e-12, l2=NULL, early_terminate = 2,
             link_function = "--link=logistic", extra = g[['extra']],
             out_probs = out_probs, validation_labels = test_labels, verbose = TRUE, 
             do_evaluation = F, use_perf=FALSE, plot_roc=F)
    #extra='--decay_learning_rate 0.9 --ksvm --kernel linear -q ::'
    cat(paste0('Iteration - ',i,'. AUC Score: ', auc, '. GINI Score:', (auc-0.5)*2, '. \n'))
}
