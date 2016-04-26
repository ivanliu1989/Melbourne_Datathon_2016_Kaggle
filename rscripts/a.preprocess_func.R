library(tm)
library(RWeka)
library(parallel)
options(mc.cores=1)

tfidf_func <- function(text_vector, ngrams = 1, minDocFreq = 2, wordLengths = 3, idf = TRUE){
    cat('load data...')
    review_source <- VectorSource(text_vector)
    cat('create corpus...')
    corpus <- Corpus(review_source)
    cat('to lower case...')
    corpus <- tm_map(corpus, content_transformer(tolower), lazy = T)
    cat('remove punctuation...')
    corpus <- tm_map(corpus, removePunctuation, lazy = T)
    cat('remove numerical characters...')
    corpus <- tm_map(corpus, removeNumbers, lazy = T)
    cat('remove stop words...')
    corpus <- tm_map(corpus, removeWords, stopwords('english'), lazy = T)
    cat('strip white space...')
    corpus <- tm_map(corpus, stripWhitespace, lazy = T)
    cat('stemming...')
    corpus <- tm_map(corpus, stemDocument, 'english', lazy = T)
    
    if(idf){
        if(ngrams > 1){
            cat(paste0('term-frequency with ',ngrams,'-grams. Minimum word length: ', wordLengths, '. Minimum frequencies: ', minDocFreq, '. '))
            BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = ngrams, max = ngrams))
            dtm_bigram <- DocumentTermMatrix(corpus, 
                                             control = list(tokenize = BigramTokenizer,
                                                            minDocFreq = minDocFreq, 
                                                            wordLengths = c(wordLengths, Inf),
                                                            weighting = weightTfIdf),
                                             bounds=list(global=c(floor(length(corpus)*0.05), Inf)))
        }else{
            cat(paste0('term-frequency with ',ngrams,'-grams. Minimum word length: ', wordLengths, '. Minimum frequencies: ', minDocFreq, '. '))
            dtm <- DocumentTermMatrix(corpus, 
                                      control = list(minDocFreq = minDocFreq,
                                                     wordLengths = c(wordLengths, Inf),
                                                     weighting = weightTfIdf),
                                      bounds=list(global=c(floor(length(corpus)*0.05), Inf))) 
        }
    }else{
        if(ngrams > 1){
            cat(paste0('tf-idf with ',ngrams,'-grams. Minimum word length: ', wordLengths, '. Minimum frequencies: ', minDocFreq, '. '))
            BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = ngrams, max = ngrams))
            dtm_bigram <- DocumentTermMatrix(corpus, 
                                             control = list(tokenize = BigramTokenizer,
                                                            minDocFreq = minDocFreq, 
                                                            wordLengths = c(wordLengths, Inf)),
                                             bounds=list(global=c(floor(length(corpus)*0.05), Inf)))
        }else{
            cat(paste0('tf-idf with ',ngrams,'-grams. Minimum word length: ', wordLengths, '. Minimum frequencies: ', minDocFreq, '. '))
            dtm <- DocumentTermMatrix(corpus, 
                                      control = list(minDocFreq = minDocFreq,
                                                     wordLengths = c(wordLengths, Inf)),
                                      bounds=list(global=c(floor(length(corpus)*0.05), Inf)))
        }
    }
    return(dtm)
}

