setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
load('../data/model/total.RData')
jobs_click <- read.delim('../data/all/job_clicks_all.csv',header = TRUE,na.strings = "",stringsAsFactors=FALSE)
# jobs_search <- read.delim('../data/all/job_searches_all.csv',header = TRUE,na.strings = "",stringsAsFactors=FALSE)
jobs_impressions <- read.delim('../data/all/job_impressions_all.csv',header = TRUE,na.strings = "",stringsAsFactors=FALSE)

# Tgt user clicks
job_click_pct <- merge(jobs_click[,c('job_id','user_id')], total[, c('job_id', 'class_id', 'hat')], all.x = T, all.y = F)
tgt_user_id <- unique(job_click_pct[job_click_pct$hat == 1,'user_id'])
job_click_pct$tgt_user_num <- ifelse(job_click_pct$user_id %in% tgt_user_id, 1,0)
tgt_user_num <- table(job_click_pct[job_click_pct$tgt_user_num > 0, 'job_id'])
tgt_user_num <- cbind(job_id = as.numeric(names(tgt_user_num)), clicks = as.numeric(tgt_user_num))
tgt_user_click <- merge(total[,'job_id'], tgt_user_num, all.x = T)

# Tgt user impressions
job_impr_pct <- merge(jobs_impressions[,c('job_id','impression_id')], total[, c('job_id', 'class_id', 'hat')], all.x = T, all.y = F)
tgt_impr_id <- unique(job_impr_pct[job_impr_pct$hat == 1,'impression_id'])
job_impr_pct$tgt_impr_num <- ifelse(job_impr_pct$impression_id %in% tgt_impr_id, 1,0)
tgt_impr_num <- table(job_impr_pct[job_impr_pct$tgt_impr_num > 0, 'job_id'])
tgt_impr_num <- cbind(job_id = as.numeric(names(tgt_impr_num)), clicks = as.numeric(tgt_impr_num))
tgt_impr_cnt <- merge(total[,'job_id'], tgt_impr_num, all.x = T)
