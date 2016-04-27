setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
library(data.table)
load('../data/model/total.RData')
source('./rscripts/0.ngram_split_func.R')

for(c in unique(total$class_description)){
    print(c)
    class_id <- total[which(total$class_description == c), 'class_id'][1]
    text_vector <- total[which(total$class_description == c), 'title']
    
    cat(paste('Input data frame (rows:',length(text_vector), '| size:',round(object.size(text_vector)/1024/1024,0),
              'mb) \n'))
    
    frequency <- freqencize(text_vector)
    save(frequency, file=paste0('key_word_freq_',c,'_',class_id,'.RData'))
}

for(c in unique(total$class_description)){
    print(c)
    class_id <- total[which(total$class_description == c), 'class_id'][1]
    text_vector <- total[which(total$class_description == c), 'abstract']
    
    cat(paste('Input data frame (rows:',length(text_vector), '| size:',round(object.size(text_vector)/1024/1024,0),
              'mb) \n'))
    
    frequency <- freqencize(text_vector)
    save(frequency, file=paste0('key_word_abstract_freq_',c,'_',class_id,'.RData'))
}

# Compare difference of keywords
freq_list <- list()

for(c in unique(total$class_description)){
    print(c)
    class_id <- total[which(total$class_description == c), 'class_id'][1]
    text_vector <- total[which(total$class_description == c), 'title']
    
    cat(paste('Input data frame (rows:',length(text_vector), '| size:',round(object.size(text_vector)/1024/1024,0),
              'mb) \n'))
    
    frequency <- freqencize(text_vector)
    freq_list[[class_id]] <- frequency
}

save(freq_list, file = './key_word_extraction/title_one_gram.RData')


# 1212 Hospitality & Tourism
freq_other <- c()
for(c in unique(total$class_description)){
    print(c)
    class_id <- total[which(total$class_description == c), 'class_id'][1]
    if(class_id != 1212){
        cat(paste('Input data frame (rows:',length(text_vector), '| size:',round(object.size(text_vector)/1024/1024,0),
                  'mb) \n'))
        freq_other <- c(freq_other, freq_list[[class_id]])
    }
}

freq_other
freq_obj <- freq_list[[1212]]
freq_obj_exc <- freq_obj[!names(freq_obj) %in% names(freq_other)]
head(freq_obj_exc)
