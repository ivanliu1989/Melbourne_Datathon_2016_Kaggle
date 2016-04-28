setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
load('../data/model/total.RData')
# jobs_search <- read.delim('../data/all/job_searches_all.csv',header = TRUE,na.strings = "",stringsAsFactors=FALSE)
total <- total[,c('job_id','class_id', 'hat')]; gc()
# unique(total[,c('class_id','class_description')])

order_id <- total$job_id
#######################
### Tgt user clicks ###
#######################
jobs_click <- read.delim('../data_new/job_clicks_all_V2.csv',header = TRUE,na.strings = "",stringsAsFactors=FALSE)
job_click_pct <- merge(jobs_click[,c('job_id','user_id')], total[, c('job_id', 'class_id', 'hat')], all.x = T, all.y = F, by = 'job_id')

for(c in unique(total$class_id)[!is.na(unique(total$class_id))]){
    feat_name <- paste0('usr_click_',c)
    cat(paste0('start creating... ', feat_name, ' \n'))
    
    tgt_user_id <- unique(job_click_pct[job_click_pct$class_id == c,'user_id'])
    job_click_pct$tgt_user_num <- ifelse(job_click_pct$user_id %in% tgt_user_id, 1,0)
    tgt_user_num <- table(job_click_pct[job_click_pct$tgt_user_num > 0, 'job_id'])
    tgt_user_num <- cbind(job_id = as.numeric(names(tgt_user_num)), clicks = as.numeric(tgt_user_num))
    colnames(tgt_user_num) <- c('job_id', feat_name)
    # save(tgt_user_num, file = '../user_click_freq.RData')
    
    tgt_user_click <- merge(total[,c('job_id','class_id', 'hat')], tgt_user_num, all.x = T, all.y = F, sort = F)
    tgt_user_click[is.na(tgt_user_click[,feat_name]), feat_name] <- 0
    tgt_user_click <- tgt_user_click[order(match(tgt_user_click$job_id,order_id)),]
    total <- merge(total, tgt_user_click, all.x = T, all.y = F, sort = F)
    cat(paste0(feat_name, ' finished. # NA: ', table(is.na(tgt_user_click[,feat_name])), '. Range of clicks: ', 
               range(tgt_user_click[,feat_name])[1], ' ', range(tgt_user_click[,feat_name])[2], '. \n'))
}

save(total, file = '../data_new/user_click_freq.RData')

############################
### Tgt user impressions ###
############################
jobs_impressions <- read.delim('../data_new/job_impressions_all_V2',header = TRUE,na.strings = "",stringsAsFactors=FALSE)
job_impr_pct <- merge(jobs_impressions[,c('job_id','session_id')], total[, c('job_id', 'class_id', 'hat')], all.x = T, all.y = F, by = 'job_id')
tgt_impr_id <- unique(job_impr_pct[job_impr_pct$hat == 1,'session_id'])
job_impr_pct$tgt_impr_num <- ifelse(job_impr_pct$session_id %in% tgt_impr_id, 1,0)
tgt_impr_num <- table(job_impr_pct[job_impr_pct$tgt_impr_num > 0, 'job_id'])
tgt_impr_num <- cbind(job_id = as.numeric(names(tgt_impr_num)), impressions = as.numeric(tgt_impr_num))
save(tgt_impr_num, file = '../impression_freq.RData')

load('../impression_freq.RData')
tgt_impr_cnt <- merge(total, tgt_impr_num, all.x = T, all.y = F, sort = F)
tgt_impr_cnt[is.na(tgt_impr_cnt$impressions), 'impressions'] <- 0
table(is.na(tgt_impr_cnt$impressions))
range(tgt_impr_cnt$impressions)
tgt_impr_cnt$impressions <- scale(tgt_impr_cnt$impressions, scale = T, center = F)
tgt_impr_cnt <- tgt_impr_cnt[order(match(tgt_impr_cnt$job_id,total$job_id)),]

save(tgt_impr_cnt, file = '../impression_freq.RData')

#########################
### Tgt user searches ###
#########################



### duplicate advertisements
# duplicated_keys <- total[duplicated(total$job_id), 'job_id']
# total_dup <- total[(total$job_id %in% duplicated_keys),c('job_id','hat')]
# total_dup[total_dup$hat == -1, ]
