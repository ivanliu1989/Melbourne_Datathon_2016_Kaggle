setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
library(Matrix)
library(caret)
load('../m.model_bigram_idf_scale_full_meta.RData')

### Split Data ###
set.seed(23)
cv <- 2
folds <- createFolds(train[,'obj_hat'], k = cv, list = FALSE)
f <- folds ==1 
train_a <- train[f,]
train_b <- train[!f,]


nb_feature_imprs <- extra_feature[92:122]
nb_feature_click <- extra_feature[123:153]

imprs_nb <- as.matrix(train[,c(nb_feature_imprs,'obj_hat')])
imprs_nb_a <- as.matrix(train_a[,c(nb_feature_imprs,'obj_hat')])
imprs_nb_b <- as.matrix(train_b[,c(nb_feature_imprs,'obj_hat')])

click_nb <- as.matrix(train[,c(nb_feature_click,'obj_hat')])
click_nb_a <- as.matrix(train_a[,c(nb_feature_click,'obj_hat')])
click_nb_b <- as.matrix(train_b[,c(nb_feature_click,'obj_hat')])


### fit
library(e1071)
imprs_fit <- naiveBayes(imprs_nb[,1:31], imprs_nb[,32])
imprs_pred_test <- predict(imprs_fit, as.matrix(test[,nb_feature_imprs]),type='raw')
imprs_fit <- naiveBayes(imprs_nb_b[,1:31], imprs_nb_b[,32])
imprs_pred_a <- predict(imprs_fit, as.matrix(imprs_nb_a[,nb_feature_imprs]),type='raw')
imprs_fit <- naiveBayes(imprs_nb_a[,1:31], imprs_nb_a[,32])
imprs_pred_b <- predict(imprs_fit, as.matrix(imprs_nb_b[,nb_feature_imprs]),type='raw')

click_fit <- naiveBayes(click_nb[,1:31], click_nb[,32])
click_pred_test <- predict(click_fit, as.matrix(test[,nb_feature_click]),type='raw')
click_fit <- naiveBayes(click_nb_b[,1:31], click_nb_b[,32])
click_pred_a <- predict(click_fit, as.matrix(click_nb_a[,nb_feature_click]),type='raw')
click_fit <- naiveBayes(click_nb_a[,1:31], click_nb_a[,32])
click_pred_b <- predict(click_fit, as.matrix(click_nb_b[,nb_feature_click]),type='raw')

test <- cbind(test, imprs_meta = imprs_pred_test[,2])
test <- cbind(test, click_meta = click_pred_test[,2])
train_a <- cbind(train_a, imprs_meta = imprs_pred_a[,2])
train_a <- cbind(train_a, click_meta = click_pred_a[,2])
train_b <- cbind(train_b, imprs_meta = imprs_pred_b[,2])
train_b <- cbind(train_b, click_meta = click_pred_b[,2])
train <- rbind(train_a, train_b)

extra_feature <- c(extra_feature, 'imprs_meta', 'click_meta')
save(train, test, extra_feature, file = '../m.model_bigram_idf_scale_full_meta_nb.RData')


