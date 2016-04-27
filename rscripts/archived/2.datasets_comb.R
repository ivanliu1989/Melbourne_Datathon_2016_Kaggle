setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
library(data.table)
load('../data/model/jobs.RData')

cate_file <- './ref/job_classification.txt'
category_desc <- read.delim(cate_file,header = TRUE,na.strings = "",stringsAsFactors=FALSE)
head(category_desc)
table(category_desc$class_id)
table(category_desc$sub_class_id)


head(job_jobs)
length(unique(job_jobs$job_id)); dim(job_jobs)
job_jobs[duplicated(job_jobs$job_id),]

total <- merge(job_jobs, category_desc, by.x = 'subclasses', by.y = 'sub_class_id', all.x = T, sort = F)
dim(total);dim(job_jobs)
head(total)
total <- total[, c(2:11, 13:14,1,15,12)]

save(total, file = '../data/model/total.RData')
