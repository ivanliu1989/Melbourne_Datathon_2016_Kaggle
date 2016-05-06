setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
library(Matrix)
# load('../data/model/total.RData')
load('../data_new/model_bigram_idf_20160501_scale_full.RData')


rm_col <- colSums(train)
rm_col <- rm_col!=0
table(rm_col)


train <-  train[,rm_col]
colnames(train)
test <- test[,rm_col]

extra_feature <- tail(colnames(train), 218)
extra_feature <- extra_feature[-length(extra_feature)]
save(train, test, extra_feature, file = '../model_unigram_idf_scale_full_fix.RData')


rm_col_tms <- colSums(train != 0)
train <- train[,rm_col_tms>=2]
test <- test[,rm_col_tms>=2]
extra_feature <- tail(colnames(train), 222)
extra_feature <- extra_feature[-length(extra_feature)]
save(train, test, extra_feature, file = '../model_bigram_idf_scale_full_fix_2.RData')
