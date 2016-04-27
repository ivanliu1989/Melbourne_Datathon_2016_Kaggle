setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
library(Matrix)
load('../data/model/total.RData')
source('./rscripts/a.preprocess_func.R')

### 1.TF/IDF features - title, abstract, raw_job_type, raw_location
    text_vector <- paste0(total$title, '. ', total$abstract, '. ', total$raw_job_type, '. ', total$raw_location)
    dtm_all <- tfidf_func(text_vector, ngrams = 1, minDocFreq = 2, wordLengths = 3, idf = TRUE);
    dtm_all <- removeSparseTerms(dtm_all, 1 - 3/nrow(dtm_all)) #dtm[,findFreqTerms(dtm,1)] # 5
    dtm_all <- sparseMatrix(dtm_all$i,dtm_all$j,x=dtm_all$v)
    dim(dtm_all)
    
#     text_vector <- total$title
#     dtm_title <- tfidf_func(text_vector, ngrams = 1, minDocFreq = 2, wordLengths = 3, idf = TRUE);
#     dtm_title <- removeSparseTerms(dtm_title, 1 - 3/nrow(dtm_title)) #dtm[,findFreqTerms(dtm,1)] # 5
#     dtm_title <- sparseMatrix(dtm_title$i,dtm_title$j,x=dtm_title$v)
#     dim(dtm_title)
#     
#     text_vector <- total$abstract
#     dtm_abstract <- tfidf_func(text_vector, ngrams = 1, minDocFreq = 5, wordLengths = 3, idf = TRUE)
#     dtm_abstract <- removeSparseTerms(dtm_abstract, 1 - 3/nrow(dtm_abstract)) #dtm[,findFreqTerms(dtm,1)] # 5
#     dtm_abstract <- sparseMatrix(dtm_abstract$i,dtm_abstract$j,x=dtm_abstract$v)
#     dim(dtm_abstract)
#     
#     text_vector <- total$raw_job_type
#     dtm_job_type <- tfidf_func(text_vector, ngrams = 1, minDocFreq = 2, wordLengths = 3, idf = TRUE)
#     dtm_job_type <- removeSparseTerms(dtm_job_type, 1 - 3/nrow(dtm_job_type)) #dtm[,findFreqTerms(dtm,1)] # 5
#     dtm_job_type <- sparseMatrix(dtm_job_type$i,dtm_job_type$j,x=dtm_job_type$v)
#     dim(dtm_job_type)
#     
#     text_vector <- total$raw_location
#     dtm_location <- tfidf_func(text_vector, ngrams = 1, minDocFreq = 2, wordLengths = 3, idf = TRUE)
#     dtm_location <- removeSparseTerms(dtm_location, 1 - 3/nrow(dtm_location)) #dtm[,findFreqTerms(dtm,1)] # 5
#     dtm_location <- sparseMatrix(dtm_location$i,dtm_location$j,x=dtm_location$v)
#     dim(dtm_location)
    
    save(dtm_title, 
         dtm_abstract,
         dtm_job_type,
         dtm_location,
         file = '../model_features_20160426.RData'
         )
    load('../model_features_20160426.RData')

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
    rm_feat <- colSums(dtm_title[total[,'hat']==-1,])
    dtm_title <- dtm_title[,rm_feat!=0]
    
    rm_feat <- colSums(dtm_abstract[total[,'hat']==-1,])
    dtm_abstract <- dtm_abstract[,rm_feat!=0]
    
    rm_feat <- colSums(dtm_job_type[total[,'hat']==-1,])
    dtm_job_type <- dtm_job_type[,rm_feat!=0]
    
    rm_feat <- colSums(dtm_location[total[,'hat']==-1,])
    dtm_location <- dtm_location[,rm_feat!=0]
    
    all <- cbind(job_id = total$job_id, 
                 dtm_title,
                 dtm_abstract,
                 dtm_job_type,
                 dtm_location,
                 salary_type = salary_type,
                 salary_min = salary_min,
                 salary_max = salary_max,
                 tgt_impr_cnt = tgt_impr_cnt$impressions,
                 tgt_user_click = tgt_user_click$clicks,
                 hat = total$hat)
    colnames(all) <- c('job_id', 
                       paste0('title_',1:ncol(dtm_title)),
                       paste0('abstr_',1:ncol(dtm_abstract)),
                       paste0('type_',1:ncol(dtm_job_type)),
                       paste0('loc_',1:ncol(dtm_location)),
                       'salary_type', 'salary_min', 'salary_max', 
                       'tgt_impr_cnt','tgt_user_click','hat')
    
    all[,'salary_min'] <- scale(all[,'salary_min'])
    all[,'salary_max'] <- scale(all[,'salary_max'])
    train <- all[all[,'hat'] != -1, ]
    test <- all[all[,'hat'] == -1, ]
    
    save(train,test, file ='../model_unigram_idf_final_scale_20160428.RData')
