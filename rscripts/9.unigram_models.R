setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()

load('../model_unigram_idf_final_scale.RData')
library(xgboost)
library(caret)
library(Matrix)
library(caTools)

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
    
    #     # 2. h2o models
    #     library(h2o)
    #     localH2O <- h2o.init(ip = 'localhost', port = 54321, max_mem_size = '12g')
    #     independent <- feature.names
    #     dependent <- "hat"
    #     train_df <- as.h2o(localH2O, train[-f,]) 
    #     validation_df <- as.h2o(localH2O, train[f,])
    #     # 2.1 glm
    #     fit <-
    #         h2o.glm(
    #             y = dependent, x = independent, training_frame = train_df, #train_df | total_df
    #             max_iterations = 100, beta_epsilon = 1e-4, solver = "L_BFGS", #IRLSM  L_BFGS
    #             standardize = F, family = 'tweedie', link = 'tweedie', alpha = 0, # 1 lasso 0 ridge
    #             lambda = 0, lambda_search = T, nlambda = 55, #lambda_min_ratio = 1e-08,
    #             intercept = F
    #         )
    #     cat(paste0('Iteration: ', i, ' || Score: ', 
    #                eval_cus(h2o.predict(object = fit, newdata = validation_df), train[f,'hat'])))
    #     # 2.2 random forest
    #     fit <-
    #         h2o.randomForest(
    #             y = dependent, x = independent, training_frame = train_df, mtries = -1, 
    #             ntrees = 800, max_depth = 16, sample.rate = 0.632, min_rows = 1, 
    #             nbins = 20, nbins_cats = 1024, binomial_double_trees = T
    #         )
    #     cat(paste0('Iteration: ', i, ' || Score: ', 
    #                eval_cus(h2o.predict(object = fit, newdata = validation_df), train[f,'hat'])))
    #     # 2.3 deeplearning
    #     fit <-
    #         h2o.deeplearning(
    #             y = dependent, x = independent, training_frame = train_df, overwrite_with_best_model = T, #autoencoder
    #             use_all_factor_levels = T, activation = "RectifierWithDropout",#TanhWithDropout "RectifierWithDropout"
    #             hidden = c(300,150,75), epochs = 9, train_samples_per_iteration = -2, adaptive_rate = T, rho = 0.99,  #c(300,150,75)
    #             epsilon = 1e-6, rate = 0.01, rate_decay = 0.9, momentum_start = 0.9, momentum_stable = 0.99,
    #             nesterov_accelerated_gradient = T, input_dropout_ratio = 0.25, hidden_dropout_ratios = c(0.25,0.25,0.25), 
    #             l1 = NULL, l2 = 3e-5, loss = 'MeanSquare', classification_stop = 0.01,
    #             diagnostics = T, variable_importances = F, fast_mode = F, ignore_const_cols = T,
    #             force_load_balance = T, replicate_training_data = T, shuffle_training_data = T
    #         )
    #     cat(paste0('Iteration: ', i, ' || Score: ', 
    #                eval_cus(h2o.predict(object = fit, newdata = validation_df), train[f,'hat'])))
    
    # 3. vw
    
}

