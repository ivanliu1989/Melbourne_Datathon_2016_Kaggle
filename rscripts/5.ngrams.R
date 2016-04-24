setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
library(data.table)
load('../data/model/total.RData')
source('./rscripts/0.ngram_split_func.R')

####################################
# N-grams frequency in job title ###
####################################
freq_list <- list()
for(c in unique(total$class_description)[-31]){
    cat(paste('\n ',c,' \n '))
    class_id <- total[which(total$class_description == c), 'class_id'][1]
    text_vector <- total[which(total$class_description == c), 'title']
    
    cat(paste('Input data frame (rows:',length(text_vector), '| size:',round(object.size(text_vector)/1024/1024,0),'mb) \n'))
    
    frequency <- ngramify(split_num=1, text_vector, grams = 1)
    # save(frequency, file=paste0('key_word_freq_',c,'_',class_id,'.RData'))
    freq_list[[class_id]] <- frequency
}

freq_title_1grams <- freq_list
save(freq_title_1grams, file='./freq_title_One_gram.RData')

freq_title_2grams <- freq_list
save(freq_title_2grams, file='./freq_title_2grams.RData')
freq_title_3grams <- freq_list
save(freq_title_3grams, file='./freq_title_3grams.RData')


unique(total[,c('class_id', 'class_description')])
head(freq_list[[1212]],20)


##########################################
# N-grams frequency in job description ###
##########################################
freq_list <- list()
for(c in unique(total$class_description)[-31]){
    cat(paste('\n ',c,' \n '))
    class_id <- total[which(total$class_description == c), 'class_id'][1]
    ngram_df <- total[which(total$class_description == c), 'abstract']
    
    cat(paste('Input data frame (rows:',length(ngram_df), '| size:',round(object.size(ngram_df)/1024/1024,0),'mb) \n'))
    
    frequency <- ngramify(split_num=1, ngram_df, grams = 4)
    # save(frequency, file=paste0('key_word_freq_',c,'_',class_id,'.RData'))
    freq_list[[class_id]] <- frequency
}


freq_abstract_2grams <- freq_list
save(freq_abstract_2grams, file='./freq_abstract_2grams.RData')
freq_abstract_3grams <- freq_list
save(freq_abstract_3grams, file='./freq_abstract_3grams.RData')
freq_abstract_4grams <- freq_list
save(freq_abstract_4grams, file='./freq_abstract_4grams.RData')


unique(total[,c('class_id', 'class_description')])
head(freq_list[[1212]],20)


# Transform
total$title <- iconv(total$title, to = 'utf-8', sub=' ')
total$title <- tolower(total$title)
total$title <- removePunctuation(total$title)
total$title <- stripWhitespace(total$title)
total$title <- removeWords(total$title, stopwords('english'))

total$abstract <- iconv(total$abstract, to = 'utf-8', sub=' ')
total$abstract <- tolower(total$abstract)
total$abstract <- removePunctuation(total$abstract)
total$abstract <- stripWhitespace(total$abstract)
total$abstract <- removeWords(total$abstract, stopwords('english'))
save(total, file = '../data/model/total_cleaned.RData')
