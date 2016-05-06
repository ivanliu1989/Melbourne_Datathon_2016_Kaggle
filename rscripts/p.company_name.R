setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
load('../data/model/total.RData')
load('./business_name_2.RData')
load('./business_name.RData')
ls()
dt_total <- rbind(dt_total2, dt_total)
comp <- tolower(dt_total[,2])
comp <- unique(comp)[-7020]

abstract <- total[,c('job_id','abstract','hat')]
abstract$abstract <- iconv(total$abstract, to = 'utf-8', sub=' ')
abstract$abstract <- tolower(abstract$abstract)



save(comp, file='./camp.RData')
load('./camp.RData')
n <- 0
for(i in comp[1:2000]){
    n <- n + 1
    feat <- grepl(i, abstract$abstract)
    s <- sum(feat)
    if(s>0){
        cat(paste0(n, ' - ', i, '. Appeared: ', s, '. \n'))
        abstract[,i] <- feat
    }
}

abstract <- abstract[,-c(2,3)]
csum <- colSums(abstract)
abst <- abstract[,csum > 2]
abst$row_sum <- rowSums(abst[,-1])
abst <- ifelse(abst == TRUE, 1, 0)
save(abst, file = './company_feature_list_complete.RData')


grepl('student', 'Student fligtths pty ltd')


matches <- grepl(paste(comp,collapse="|"), abstract$abstract)

load('../model_bigram_idf_scale_full_fix.RData')
train <- cbind(train, as.matrix(total[total$hat>=0, 16:123]))
test <- cbind(test, as.matrix(total[total$hat<0, 16:123]))
extra_feature <- c(extra_feature, colnames(abst)[-1])
save(train, test, extra_feature, file = '../model_bigram_idf_scale_full_fix_comp.RData')
