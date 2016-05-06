setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
library(Matrix)
load('../data/model/total.RData')
source('./rscripts/a.preprocess_func.R')

### 1.TF/IDF features - title, abstract, raw_job_type, raw_location
### unigram
text_vector <- paste0(total$title, total$abstract, collapse = " ")
dtm_unigram <- tfidf_func(text_vector, ngrams = 1, minDocFreq = 100, wordLengths = 2, wordLengths_max = Inf, idf = F);
# dtm_title <- removeSparseTerms(dtm_title, 1 - 3/nrow(dtm_title)) 
bow_names <- colnames(dtm_unigram)
dtm_unigram <- sparseMatrix(dtm_unigram$i,dtm_unigram$j,x=dtm_unigram$v,dimnames = list(NULL,bow_names))
dim(dtm_unigram)
title_key_words_cnt <- rowSums(dtm_unigram >0)


### bigrams    
text_vector <- paste0(total$title, total$abstract, collapse = " ")
dtm_bigrams <- tfidf_func(text_vector, ngrams = 2, minDocFreq = 100, wordLengths = 2, wordLengths_max = Inf, idf = T);
# dtm_bigrams <- removeSparseTerms(dtm_bigrams, 1 - 3/nrow(dtm_bigrams)) 
bow_names <- colnames(dtm_bigrams)
dtm_bigrams <- sparseMatrix(dtm_bigrams$i,dtm_bigrams$j,x=dtm_bigrams$v,dimnames = list(NULL,bow_names))
dim(dtm_bigrams)
title_key_words_cnt_bi <- rowSums(dtm_bigrams >0)


### save data
save(dtm_unigram, 
     dtm_bigrams,
     
     file = '../data_new/o.pca_cosine.RData'
)
# load('../data_new/idf_unigram_to_trigrams_full_20160502.RData')

### PCA & cosine
pca_all <- prcomp(rbind(train[,feature.names], test[,feature.names]))
sv <- svd(rbind(train[,1:20000], test[,1:20000]))

cosineDist <- function(x){
    as.dist(1 - x%*%t(x)/(sqrt(rowSums(x^2) %*% t(rowSums(x^2))))) 
}






extra_feature <- colnames(pt3)
class_id <- total[all[,'obj_hat'] != -1, 'class_id']
train <- all[all[,'obj_hat'] != -1, ]
test <- all[all[,'obj_hat'] == -1, ]

save(train,test,extra_feature,class_id, file ='../data_new/model_trigram_idf_20160502_scale_full.RData')


load('../data_new/model_unigram_idf_20160505_scale_full.RData')
all <- rbind(train,test)
pca_all <- prcomp(all[,2:1000])
