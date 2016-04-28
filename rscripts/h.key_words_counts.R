setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
load('../data/model/total.RData')
source('./rscripts/a.preprocess_func.R')

unique(total[,c('class_id','class_description')])
### 1.TF/IDF features - title, abstract, raw_job_type, raw_location
# c = 'Hospitality & Tourism'
freq_list <- list()
for(c in unique(total$class_description)[!is.na(unique(total$class_description))]){
    class_id <- total[which(total$class_description == c), 'class_id'][1]
    cat(paste(class_id, ' - ', c, '\n'))
    text_vector <- total[which(total$class_description == c), 'title']
    
    cat(paste('Input data frame (rows:',length(text_vector), '| size:',round(object.size(text_vector)/1024/1024,0),'mb) \n'))
    
    dtm <- tfidf_func(text_vector, ngrams = 1, minDocFreq = 1, wordLengths = 3, idf = FALSE);
    dtm2 <- as.matrix(dtm)
    frequency <- colSums(dtm2)
    frequency <- sort(frequency, decreasing=TRUE)
    freq_list[[class_id]] <- frequency
}

save(freq_list, file='../data_new/h.key_words_counts.RData')

# COUNTS
# ALL FREQ 