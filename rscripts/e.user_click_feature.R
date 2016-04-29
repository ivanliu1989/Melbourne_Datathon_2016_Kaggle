setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
load('../data/model/total.RData')
total <- total[,c('job_id','class_id', 'hat')]; gc()

total$id <- 1:nrow(total)
order_id <- total$id

#######################
### Tgt user clicks ###
#######################
jobs_click <- read.delim('../data_new/job_clicks_all_V2.csv',header = TRUE,na.strings = "",stringsAsFactors=FALSE)
job_click_pct <- merge(jobs_click[,c('job_id','user_id')], total[, c('job_id', 'class_id', 'hat', 'id')], all.x = T, all.y = F, by = 'job_id')

for(c in unique(total$class_id)[!is.na(unique(total$class_id))]){
    feat_name <- paste0('usr_click_',c)
    cat(paste0('start creating... ', feat_name, ' \n'))
    
    tgt_user_id <- unique(job_click_pct[job_click_pct$class_id == c,'user_id'])
    job_click_pct$tgt_user_num <- ifelse(job_click_pct$user_id %in% tgt_user_id, 1,0)
    tgt_user_num <- table(job_click_pct[job_click_pct$tgt_user_num > 0, 'job_id'])
    tgt_user_num <- cbind(job_id = as.numeric(names(tgt_user_num)), clicks = as.numeric(tgt_user_num))
    colnames(tgt_user_num) <- c('job_id', feat_name)
    
    tgt_user_click <- merge(total[,c('job_id','class_id', 'hat', 'id')], tgt_user_num, all.x = T, all.y = F, sort = F)
    tgt_user_click[is.na(tgt_user_click[,feat_name]), feat_name] <- 0
    tgt_user_click <- tgt_user_click[order(match(tgt_user_click$id,order_id)),]
    print(identical(tgt_user_click$job_id, total$job_id))
    
    total <- cbind(total, tgt_user_click[,feat_name])
    colnames(total) <- c(colnames(total)[-length(colnames(total))], feat_name)
    cat(paste0(feat_name, ' finished. # NA: ', table(is.na(tgt_user_click[,feat_name])), '. Range of clicks: ', 
               range(tgt_user_click[,feat_name])[1], ' ', range(tgt_user_click[,feat_name])[2], '. \n'))
}

total$usr_click_total <- rowSums(total[,5:ncol(total)])
for(i in 5:34){
    pct <- total[,i]/total$usr_click_total
    pct[is.na(pct)] <- 0
    total[,i] <- pct
}
tgt_user_click <- total
save(tgt_user_click, file = '../data_new/user_click_freq_pct.RData')

############################
### Tgt user impressions ###
############################
jobs_impressions <- read.delim('../data_new/job_impressions_all_V2.csv',header = TRUE,na.strings = "",stringsAsFactors=FALSE)
job_impr_pct <- merge(jobs_impressions[,c('job_id','session_id')], total[, c('job_id', 'class_id', 'hat', 'id')], all.x = T, all.y = F, by = 'job_id')

for(c in unique(total$class_id)[!is.na(unique(total$class_id))]){
    feat_name <- paste0('usr_imprs_',c)
    cat(paste0('start creating... ', feat_name, ' \n'))
    
    tgt_impr_id <- unique(job_impr_pct[job_impr_pct$class_id == c,'session_id'])
    job_impr_pct$tgt_impr_num <- ifelse(job_impr_pct$session_id %in% tgt_impr_id, 1,0)
    tgt_impr_num <- table(job_impr_pct[job_impr_pct$tgt_impr_num > 0, 'job_id'])
    tgt_impr_num <- cbind(job_id = as.numeric(names(tgt_impr_num)), impressions = as.numeric(tgt_impr_num))
    colnames(tgt_impr_num) <- c('job_id', feat_name)
    
    tgt_impr_cnt <- merge(total[,c('job_id','class_id', 'hat', 'id')], tgt_impr_num, by = 'job_id', all.x = T, all.y = F, sort = F)
    tgt_impr_cnt[is.na(tgt_impr_cnt[,feat_name]), feat_name] <- 0
    tgt_impr_cnt <- tgt_impr_cnt[order(match(tgt_impr_cnt$id,order_id)),]
    print(identical(tgt_impr_cnt$job_id, total$job_id))
    
    total <- cbind(total, tgt_impr_cnt[,feat_name])
    colnames(total) <- c(colnames(total)[-length(colnames(total))], feat_name)
    cat(paste0(feat_name, ' finished. # NA: ', table(is.na(tgt_impr_cnt[,feat_name])), '. Range of clicks: ', 
               range(tgt_impr_cnt[,feat_name])[1], ' ', range(tgt_impr_cnt[,feat_name])[2], '. \n \n'))
}

total$tgt_impr_total <- rowSums(total[,5:ncol(total)])
for(i in 5:34){
    pct <- total[,i]/total$tgt_impr_total
    pct[is.na(pct)] <- 0
    total[,i] <- pct
}
tgt_impr_cnt <- total
save(tgt_impr_cnt, file = '../data_new/tgt_impr_cnt_pct.RData')

#########################
### Tgt user searches ###
#########################



### duplicate advertisements
# duplicated_keys <- total[duplicated(total$job_id), 'job_id']
# total_dup <- total[(total$job_id %in% duplicated_keys),c('job_id','hat')]
# total_dup[total_dup$hat == -1, ]
avg_salary <- data.frame(class_id = 0, min_salary = 0, max_salary = 0, var_salary = 0)
for(c in unique(total$class_id)[!is.na(unique(total$class_id))]){
    cat(c, ' ' , mean(total[total$class_id == c, 'salary_min'], na.rm = T), ' ', mean(total[total$class_id == c, 'salary_max'], na.rm = T),  '\n')
    new_record <- c(c, mean(total[total$class_id == c, 'salary_min'], na.rm = T), mean(total[total$class_id == c, 'salary_max'], na.rm = T),
                    mean(total[total$class_id == c, 'salary_max'] - total[total$class_id == c, 'salary_min'], na.rm = T))
    avg_salary <- rbind(avg_salary, new_record)
}
avg_salary <- avg_salary[-1,]
save(avg_salary, file = '../data_new/avg_salary.RData')

