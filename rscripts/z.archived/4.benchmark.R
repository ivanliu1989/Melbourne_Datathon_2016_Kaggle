
###########################################
# dms datathon 2016
# R code snippets
###########################################

#clear all object from memory
rm(list=ls())

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
myRows3 <- grep(pattern="cook",x=jobs$title,ignore.case = TRUE)
myRows4 <- grep(pattern="cafe",x=jobs$title,ignore.case = TRUE)
myRows5 <- grep(pattern="kitchen",x=jobs$title,ignore.case = TRUE)
myRows6 <- grep(pattern="food",x=jobs$title,ignore.case = TRUE)
myRows7 <- grep(pattern="cleaner",x=jobs$title,ignore.case = TRUE)
myRows8 <- grep(pattern="chefs",x=jobs$title,ignore.case = TRUE)
myRows9 <- grep(pattern="beverage",x=jobs$title,ignore.case = TRUE)
myRows10 <- grep(pattern="housekeeper",x=jobs$title,ignore.case = TRUE)
myRows11 <- grep(pattern="waitree",x=jobs$title,ignore.case = TRUE)
myRows12 <- grep(pattern="catering",x=jobs$title,ignore.case = TRUE)
myRows13 <- grep(pattern="cooks",x=jobs$title,ignore.case = TRUE)
myRows14 <- grep(pattern="breakfast",x=jobs$title,ignore.case = TRUE)
myRows15 <- grep(pattern="baker",x=jobs$title,ignore.case = TRUE)
myRows16 <- grep(pattern="kitchenhand",x=jobs$title,ignore.case = TRUE)
myRows17 <- grep(pattern="housekeepers",x=jobs$title,ignore.case = TRUE)
myRows18 <- grep(pattern="cookchef",x=jobs$title,ignore.case = TRUE)
myRows19 <- grep(pattern="baristas",x=jobs$title,ignore.case = TRUE)

myRows <- c(myRows1,myRows2,myRows3,myRows4,myRows5,myRows6,myRows7,myRows8,myRows9,myRows10,myRows11,myRows12,myRows13
                ,myRows14,myRows15,myRows16,myRows17,myRows18,myRows19)

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
#0.5050619

#now create the submission file
# submission <- jobs[scoreRows,c('job_id','prediction')]
# colnames(submission) <- c('job_id','HAT')
# myOutputFile <- paste(myFolder,"R_barista_prediction.csv",sep="")
# write.csv(submission,myOutputFile,row.names = FALSE,quote=FALSE)

#submit to Kaggle and you should get
#0.279 

