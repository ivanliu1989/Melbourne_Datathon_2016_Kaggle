setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
library(data.table)
load('../data/model/total.RData')
load('./freq_title_3grams.RData')

head(freq_title_2grams[[1212]],50)

myRows <- c()
for (i in head(freq_title_3grams[[1212]],50)$terms){
    cat(paste(i,' \n'))
    myRows <- c(grep(pattern=i,x=total$title,ignore.case = TRUE), myRows)
}
myRows <- unique(myRows)

#create a prediction
total$prediction <- 0
total[myRows,'prediction'] <- 1

#train and score rows
trainRows <- which(total$hat != -1)
scoreRows <- which(total$hat == -1)

#calculate the gini on train rows (these are the ones we know the answers for)
library(caTools)
act <- total[trainRows,'hat']
pred <- total[trainRows,'prediction']
AUC <- colAUC(pred,act,plotROC=TRUE)[1]
GINI <- 2 * (AUC - 0.5)
#expected gini
#0.265
#0.5050619
