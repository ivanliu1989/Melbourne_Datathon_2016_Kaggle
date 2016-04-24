setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
files <- list.files('../data/all', full.names = T)

library(data.table)
source('./rscripts/RCodeForGini.R')
job_clicks <- fread(files[1], data.table = F)
job_impressions <- fread(files[2], data.table = F)
job_searches <- fread(files[3], data.table = F)
job_jobs <- read.delim(files[4],header = TRUE,na.strings = "",stringsAsFactors=FALSE)

table(job_jobs$hat)
save(job_jobs, file = '../data/model/jobs.RData')
save(job_clicks,job_impressions,job_searches,job_jobs, file = '../data/model/full_data.RData')

# Test validation func
solution <- c(1,1,1,1,0,0,0,0)
submission <- c(0.66,0.45,0.93,0.77,0.23,0.56,0.47,0.15)
submission <- c(0,0,1,0,1,1,1,1)

SumModelGini(solution,submission)
NormalizedGini(solution,submission)

library(pROC)
gini_auc(auc(solution,submission), mtd = 'A2G')
auc(solution,submission)
