setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
library(data.table)
load('../data/model/total_cleaned.RData')
load('./freq_title_One_gram.RData')

unique(total[,c('class_id', 'class_description')])
head(total)
head(freq_title_1grams[[1212]],200)
write.csv(freq_title_1grams[[1212]], file = './features/Hospitality & Tourism_1212.csv')

for(i in unique(total$class_id)){
    if(!is.na(i)){
        class_name <- total[which(total$class_id == i), 'class_description'][1]
        write.csv(freq_title_1grams[[i]], file = paste0('./features/',class_name,'_',i,'.csv'))
    }
}