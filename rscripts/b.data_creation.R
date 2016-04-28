setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
library(Matrix)
load('../data/model/total.RData')
source('./rscripts/a.preprocess_func.R')

### 1.TF/IDF features - title, abstract, raw_job_type, raw_location
    # text_vector <- paste0(total$title, '. ', total$abstract, '. ', total$raw_job_type, '. ', total$raw_location)
    # dtm_all <- tfidf_func(text_vector, ngrams = 1, minDocFreq = 2, wordLengths = 3, wordLengths_max = 20, idf = TRUE);
    # save(dtm_all, file='../data_new/dtm_all.RData'); dim(dtm_all)
    # load('../data_new/dtm_all.RData')
    # dtm_all <- removeSparseTerms(dtm_all, 1 - 3/nrow(dtm_all))
    # bow_names <- colnames(dtm_all)
    # dtm_all <- sparseMatrix(dtm_all$i,dtm_all$j,x=dtm_all$v,dimnames = list(NULL,bow_names))
    # dim(dtm_all)
    
    text_vector <- total$title
    dtm_title <- tfidf_func(text_vector, ngrams = 1, minDocFreq = 2, wordLengths = 3, wordLengths_max = 20, idf = TRUE);
    dtm_title <- removeSparseTerms(dtm_title, 1 - 3/nrow(dtm_title)) #dtm[,findFreqTerms(dtm,1)] # 5
    bow_names <- colnames(dtm_title)
    dtm_title <- sparseMatrix(dtm_title$i,dtm_title$j,x=dtm_title$v,dimnames = list(NULL,bow_names))
    dim(dtm_title)
    
    text_vector <- total$abstract
    dtm_abstract <- tfidf_func(text_vector, ngrams = 1, minDocFreq = 2, wordLengths = 3, wordLengths_max = 20, idf = TRUE)
    dtm_abstract <- removeSparseTerms(dtm_abstract, 1 - 3/nrow(dtm_abstract)) #dtm[,findFreqTerms(dtm,1)] # 5
    bow_names <- paste0('abs_',colnames(dtm_abstract))
    dtm_abstract <- sparseMatrix(dtm_abstract$i,dtm_abstract$j,x=dtm_abstract$v,dimnames = list(NULL,bow_names))
    dim(dtm_abstract)
    
    text_vector <- total$raw_job_type
    dtm_job_type <- tfidf_func(text_vector, ngrams = 1, minDocFreq = 2,wordLengths = 3, wordLengths_max = 20, idf = TRUE);
    dtm_job_type <- removeSparseTerms(dtm_job_type, 1 - 3/nrow(dtm_job_type)) 
    bow_names <- paste0('job_',colnames(dtm_job_type))
    dtm_job_type <- sparseMatrix(dtm_job_type$i,dtm_job_type$j,x=dtm_job_type$v,dimnames = list(NULL,bow_names))
    dim(dtm_job_type)
    
    text_vector <- total$raw_location
    dtm_location <- tfidf_func(text_vector, ngrams = 1, minDocFreq = 2, wordLengths = 3, wordLengths_max = 20, idf = TRUE);
    dtm_location <- removeSparseTerms(dtm_location, 1 - 3/nrow(dtm_location)) 
    bow_names <- paste0('loc_',colnames(dtm_location))
    dtm_location <- sparseMatrix(dtm_location$i,dtm_location$j,x=dtm_location$v,dimnames = list(NULL,bow_names))
    dim(dtm_location)

    save(dtm_title, 
         dtm_abstract,
         dtm_job_type,
         dtm_location,
         file = '../data_new/model_features_20160429.RData'
         )
    # load('../data_new/model_features_20160429.RData')

### 2. binary features - salary_type
    salary_type <- ifelse(total$salary_type == 'h', 0, 1)
    salary_type[is.na(salary_type)] <- 1

### 3. numerical features - salary_min, salary_max
    salary_min <- total$salary_min; salary_min[is.na(salary_min)] <- -1
    salary_max <- total$salary_max; salary_max[is.na(salary_max)] <- -1

### 4. clicks & impression freq
    load('../user_click_freq.RData')
    load('../impression_freq.RData')

### 5. combine model data
# remove features not in test
    rm_feat <- colSums(dtm_all[total[,'hat']==-1,])
    dtm_all <- dtm_all[,rm_feat!=0]
    
#     rm_feat <- colSums(dtm_title[total[,'hat']==-1,])
#     dtm_title <- dtm_title[,rm_feat!=0]
#     
#     rm_feat <- colSums(dtm_abstract[total[,'hat']==-1,])
#     dtm_abstract <- dtm_abstract[,rm_feat!=0]
#     
#     rm_feat <- colSums(dtm_job_type[total[,'hat']==-1,])
#     dtm_job_type <- dtm_job_type[,rm_feat!=0]
#     
#     rm_feat <- colSums(dtm_location[total[,'hat']==-1,])
#     dtm_location <- dtm_location[,rm_feat!=0]
    
    pt3 <- cbind(salary_type = salary_type,
                 salary_min = salary_min,
                 salary_max = salary_max,
                 salary_variance = (salary_max - salary_min),
                 tgt_impr_cnt = tgt_impr_cnt$impressions,
                 tgt_user_click = tgt_user_click$clicks,
                 obj_hat = total$hat)
    colnames(pt3) <- c('salary_type','salary_min','salary_max','salary_var','tgt_impr_cnt','tgt_user_click','obj_hat')
    
    all <- cbind(job_id = total$job_id, 
                 # dtm_title,
                 # dtm_abstract,
                 # dtm_job_type,
                 # dtm_location,
                 dtm_all,
                 pt3
                 )
    
    all[,'salary_min'] <- scale(all[,'salary_min'])
    all[,'salary_max'] <- scale(all[,'salary_max'])
    all[,'salary_var'] <- scale(all[,'salary_var'])
    train <- all[all[,'obj_hat'] != -1, ]
    test <- all[all[,'obj_hat'] == -1, ]
    
    save(train,test, file ='../data_new/model_unigram_idf_final_scale_20160428.RData')

    
    
# user count (all categories, %) (% of them clicks other categories)
# impressions (all categories, %)
# segment - salary
    
    
    
    
    
    
    # 0.982138
    
    library(xgboost)
    library(caret)
    library(Matrix)
    library(caTools)
    
    set.seed(23)
    cv <- 10
    folds <- createFolds(train[,'obj_hat'], k = cv, list = FALSE)
    dropitems <- c('job_id','obj_hat')
    feature.names <- colnames(train)[!colnames(train) %in% dropitems] 
    i=2
    
    f <- folds==i
    # 1. xgboost 0.991413/0.982826
    dval          <- xgb.DMatrix(data=train[f,feature.names],label=train[f,'obj_hat'])
    dtrain        <- xgb.DMatrix(data=train[!f,feature.names],label=train[!f,'obj_hat']) 
    watchlist     <- list(val=dval,train=dtrain)
    clf <- xgb.train(data                = dtrain,
                     nrounds             = 2500, 
                     early.stop.round    = 300,
                     watchlist           = watchlist,
                     eval_metric         = 'auc',
                     # feval                = eval_cus,
                     maximize            = TRUE,
                     objective           = "binary:logistic",
                     booster             = "gbtree", # gblinear
                     eta                 = 0.2,
                     max_depth           = 6,
                     min_child_weight    = 10,
                     subsample           = .8,
                     colsample           = .4,
                     print.every.n       = 1
    )
    cat(paste0('Iteration: ', i, ' || Score: ', 2*(clf$bestScore-0.5)))