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
dtm_title <- tfidf_func(text_vector, ngrams = 2, minDocFreq = 2, wordLengths = 2, wordLengths_max = 80, idf = T);
# dtm_title <- removeSparseTerms(dtm_title, 1 - 3/nrow(dtm_title)) 
bow_names <- paste0('bi_',colnames(dtm_title))
dtm_title <- sparseMatrix(dtm_title$i,dtm_title$j,x=dtm_title$v,dimnames = list(NULL,bow_names))
dim(dtm_title)
title_key_words_cnt <- rowSums(dtm_title >0)

text_vector <- total$abstract
dtm_abstract <- tfidf_func(text_vector, ngrams = 2, minDocFreq = 2, wordLengths = 2, wordLengths_max = 80, idf = T)
# dtm_abstract <- removeSparseTerms(dtm_abstract, 1 - 3/nrow(dtm_abstract))
bow_names <- paste0('bi_abs_',colnames(dtm_abstract))
dtm_abstract <- sparseMatrix(dtm_abstract$i,dtm_abstract$j,x=dtm_abstract$v,dimnames = list(NULL,bow_names))
dim(dtm_abstract)
abs_key_words_cnt <- rowSums(dtm_abstract >0)

text_vector <- total$raw_job_type
dtm_job_type <- tfidf_func(text_vector, ngrams = 2, minDocFreq = 2,wordLengths = 2, wordLengths_max = 80, idf = T);
# dtm_job_type <- removeSparseTerms(dtm_job_type, 1 - 3/nrow(dtm_job_type)) 
bow_names <- paste0('bi_job_',colnames(dtm_job_type))
dtm_job_type <- sparseMatrix(dtm_job_type$i,dtm_job_type$j,x=dtm_job_type$v,dimnames = list(NULL,bow_names))
dim(dtm_job_type)
type_key_words_cnt <- rowSums(dtm_job_type >0)

text_vector <- total$raw_location
dtm_location <- tfidf_func(text_vector, ngrams = 2, minDocFreq = 2, wordLengths = 2, wordLengths_max = 80, idf = T);
# dtm_location <- removeSparseTerms(dtm_location, 1 - 3/nrow(dtm_location)) 
bow_names <- paste0('bi_loc_',colnames(dtm_location))
dtm_location <- sparseMatrix(dtm_location$i,dtm_location$j,x=dtm_location$v,dimnames = list(NULL,bow_names))
dim(dtm_location)
loc_key_words_cnt <- rowSums(dtm_location >0)

dtm_title_bi <- dtm_title
dtm_abstract_bi <- dtm_abstract
dtm_job_type_bi <- dtm_job_type
dtm_location_bi <- dtm_location
title_key_words_cnt_bi <- title_key_words_cnt
abs_key_words_cnt_bi <- abs_key_words_cnt
type_key_words_cnt_bi <- type_key_words_cnt
loc_key_words_cnt_bi <- loc_key_words_cnt

save(dtm_title_bi, 
     dtm_abstract_bi,
     dtm_job_type_bi,
     dtm_location_bi,
     title_key_words_cnt_bi,
     abs_key_words_cnt_bi,
     type_key_words_cnt_bi,
     loc_key_words_cnt_bi,
     file = '../data_new/idf_bigrams_full_20160501.RData'
)
load('../data_new/idf_unigrams_full_20160501.RData')
# idf_unigrams_full_20160501.RData
# idf_bigrams_full_20160501.RData

### 2. binary features - salary_type
salary_type <- ifelse(total$salary_type == 'h', 0, 1)
salary_type[is.na(salary_type)] <- 1

### 3. numerical features - salary_min, salary_max
load('../data_new/avg_salary.RData')
feat_list <- c()
for(c in unique(total$class_id)[!is.na(unique(total$class_id))]){
    feat_name <- paste0('min_salary_ratio_',c)
    total[,feat_name] <- total[,'salary_min'] / avg_salary[avg_salary$class_id == c,'min_salary']
    total[is.na(total[,feat_name]),feat_name] <- 1
    feat_list <- c(feat_list, feat_name)
}
for(c in unique(total$class_id)[!is.na(unique(total$class_id))]){
    feat_name <- paste0('max_salary_ratio_',c)
    total[,feat_name] <- total[,'salary_max'] / avg_salary[avg_salary$class_id == c,'max_salary']
    total[is.na(total[,feat_name]),feat_name] <- 1
    feat_list <- c(feat_list, feat_name)
}
for(c in unique(total$class_id)[!is.na(unique(total$class_id))]){
    feat_name <- paste0('var_salary_ratio_',c)
    total[,feat_name] <- (total[,'salary_max'] - total[,'salary_min']) / avg_salary[avg_salary$class_id == c,'var_salary']
    total[is.na(total[,feat_name]),feat_name] <- 1
    feat_list <- c(feat_list, feat_name)
}
salary_features <- total[,feat_list]

### 4. clicks & impression freq
load('../data_new/user_click_freq_pct.RData')
load('../data_new/tgt_impr_cnt_pct.RData')
tgt_impr_all_cnt <- rowSums(tgt_impr_cnt[,5:34] > 0)
tgt_user_click_cnt <- rowSums(tgt_user_click[,5:34] > 0)

### 5. Geo Info
load('../data_new/geo_info_dummy.RData')
# head(geo_info_dummy[,2:61])

### 6. Key word counts
# load('../data_new/h.key_words_counts.RData')

### 5. combine model data
# remove features not in test
# rm_feat <- colSums(dtm_all[total[,'hat']==-1,])
# dtm_all <- dtm_all[,rm_feat!=0]

rm_feat <- colSums(dtm_title[total[,'hat']==-1,])
dtm_title <- dtm_title[,rm_feat!=0]

rm_feat <- colSums(dtm_abstract[total[,'hat']==-1,])
dtm_abstract <- dtm_abstract[,rm_feat!=0]

rm_feat <- colSums(dtm_job_type[total[,'hat']==-1,])
dtm_job_type <- dtm_job_type[,rm_feat!=0]

rm_feat <- colSums(dtm_location[total[,'hat']==-1,])
dtm_location <- dtm_location[,rm_feat!=0]

rm_feat <- colSums(dtm_title_bi[total[,'hat']==-1,])
dtm_title_bi <- dtm_title_bi[,rm_feat!=0]

rm_feat <- colSums(dtm_abstract_bi[total[,'hat']==-1,])
dtm_abstract_bi <- dtm_abstract_bi[,rm_feat!=0]

rm_feat <- colSums(dtm_job_type_bi[total[,'hat']==-1,])
dtm_job_type_bi <- dtm_job_type_bi[,rm_feat!=0]

rm_feat <- colSums(dtm_location_bi[total[,'hat']==-1,])
dtm_location_bi <- dtm_location_bi[,rm_feat!=0]

# 218
pt3 <- as.matrix(cbind(salary_type = salary_type,
                       salary_features,
                       tgt_impr_cnt[,5:34],
                       tgt_impr_all_cnt = tgt_impr_all_cnt,
                       tgt_user_click[,5:34],
                       tgt_user_click_cnt = tgt_user_click_cnt,
                       title_key_words_cnt = title_key_words_cnt,
                       abs_key_words_cnt = abs_key_words_cnt,
                       type_key_words_cnt = type_key_words_cnt,
                       loc_key_words_cnt = loc_key_words_cnt,
                       
                       title_key_words_cnt_bi = title_key_words_cnt_bi,
                       abs_key_words_cnt_bi = abs_key_words_cnt_bi,
                       type_key_words_cnt_bi = type_key_words_cnt_bi,
                       loc_key_words_cnt_bi = loc_key_words_cnt_bi,
                       
                       geo_info_dummy[,2:61]))

library(caret)
pre <- preProcess(pt3, method = c("center", "scale"))
pt3_scale <- predict(pre, pt3)

all <- cbind(job_id = total$job_id, 
             dtm_title,
             dtm_abstract,
             dtm_job_type,
             dtm_location,
             dtm_title_bi,
             dtm_abstract_bi,
             dtm_job_type_bi,
             dtm_location_bi,
             pt3_scale,
             obj_hat = total$hat
)

extra_feature <- colnames(pt3)
train <- all[all[,'obj_hat'] != -1, ]
test <- all[all[,'obj_hat'] == -1, ]

save(train,test,extra_feature,file ='../data_new/model_bigram_idf_20160501_scale_full.RData')



### 6. key words frequency
#     load(file='../data_new/h.key_words_counts.RData')
#     load(file='../data_new/model_unigram_idf_final_20160428.RData')
#     
#     for(c in unique(total$class_id)[!is.na(unique(total$class_id))]){
#         print(length(freq_list[[c]]))
#         apply(train[,2:19197])
#         sum(train[1,2:19197][train[1,2:19197]!=0] %in% names(freq_list[[c]]))
#     }

# 1) location
# 2) meta data - glm, xgb
# 3) duplicated records
# 4) vw?

#     for(c in unique(total$class_id)[!is.na(unique(total$class_id))]){
#         # print(length(freq_list[[c]]))
#         print(mean(b[total$class_id == c]))
#     }



### 7. test run
library(xgboost)
library(caret)
library(Matrix)
library(caTools)

set.seed(23)
cv <- 10
folds <- createFolds(train[,'obj_hat'], k = cv, list = FALSE)
dropitems <- c('job_id','obj_hat')
feature.names <- colnames(train)[!colnames(train) %in% dropitems] 

f <- folds %in% c(2)
# 1. xgboost 0.996185/0.99236
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