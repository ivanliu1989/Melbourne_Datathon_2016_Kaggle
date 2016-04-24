
###########################################
# dms datathon 2016
# R code snippets
###########################################

#clear all object from memory
rm(list=ls())

#increase memory (if required)
memory.limit(123456)


#location of data
myFolder <- '/Users/ivanliu/Downloads/datathon2016/data/all/'

#read in the jobs data
myFile1 <- 'jobs_all.csv'
myFile1 <- paste(myFolder,myFile1,sep="")
jobs <- read.delim(myFile1,header = TRUE,na.strings = "",stringsAsFactors=FALSE)

nrow(jobs)
#1,439,436

head(jobs)

summary(jobs)


#-----------------------------
# benchmark Kaggle submission
#-----------------------------

#flag the rows with the words in we want
myRows1 <- grep(pattern="barista",x=jobs$title,ignore.case = TRUE)
myRows2 <- grep(pattern="chef",x=jobs$title,ignore.case = TRUE)
myRows <- union(myRows1,myRows2)

#create a prediction
jobs$prediction <- 0
jobs[myRows,'prediction'] <- 1


#train and score rows
trainRows <- which(jobs$hat != -1)
scoreRows <- which(jobs$hat == -1)

#calculate the gini on train rows (these are the ones we know the answers for)
library(caTools)

act <- jobs[trainRows,'hat']
pred <- jobs[trainRows,'prediction']

AUC <- colAUC(pred,act,plotROC=TRUE)[1]
GINI <- 2 * (AUC - 0.5)

#expected gini
#0.265

#now create the submission file
submission <- jobs[scoreRows,c('job_id','prediction')]
colnames(submission) <- c('job_id','HAT')
myOutputFile <- paste(myFolder,"R_barista_prediction.csv",sep="")
write.csv(submission,myOutputFile,row.names = FALSE,quote=FALSE)

#submit to Kaggle and you should get
#0.279 

