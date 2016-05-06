setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
load('../data/model/total.RData')
load('../model_bigram_idf_scale_full_fix.RData')
library(xgboost)
library(caret)
library(Matrix)
library(caTools)

### Split Data ###
set.seed(23)
cv <- 10
folds <- createFolds(train[,'obj_hat'], k = cv, list = FALSE)
i=c(2,5)
f <- folds %in% i

dropitems <- c('job_id','obj_hat', extra_feature[c(92:153)])
feature.names <- colnames(train)[!colnames(train) %in% dropitems] 

dval          <- xgb.DMatrix(data=train[f,feature.names],label=train[f,'obj_hat'])
dtrain        <- xgb.DMatrix(data=train[!f,feature.names],label=train[!f,'obj_hat']) 
# dtrain        <- xgb.DMatrix(data=train[,feature.names],label=train[,'obj_hat']) 
watchlist     <- list(val=dval,train=dtrain)
clf <- xgb.train(data                = dtrain,
                 nrounds             = 2000, 
                 early.stop.round    = 30,
                 watchlist           = watchlist,
                 eval_metric         = 'auc',                                       
                 # feval                = eval_cus,
                 maximize            = TRUE,
                 objective           = "binary:logistic",
                 booster             = "gbtree", # gblinear
                 eta                 = 0.2,
                 max_depth           = 12,
                 # min_child_weight    = 10,
                 subsample           = .9,
                 colsample           = .4,
                 print.every.n       = 1
)
cat(paste0('Iteration: ', i, ' || Score: ', 2*(clf$bestScore-0.5)))


submissions <- predict(clf, test[,feature.names])
submissions <- cbind(job_id = test[,'job_id'], hat = submissions)
options(scipen = 3)
write.csv(submissions, file='./pred/submit_20160505_.csv', row.names = F)

head(submissions)
varify.matrix <- total[total$job_id %in% submissions[submissions[,2]>0.5,1],c('job_id', 'title','abstract')]
feat_imp <- xgb.importance(dimnames(train[,feature.names])[[2]], model = clf)
xgb.plot.importance(feat_imp)

##########################
# Further improvement ###
#########################
# 1. meta data - glmnet & vw (nnet) 
# 2. duplicated / misclassified ads investigation
# 3. submodels based on sub class id
# 4. bigrams / trigrams features
# 5. model blending - tunning & different parameters
# 6. model blending - TF & IDF
# 7 (Done). feature center & scale 


# 328 991138

