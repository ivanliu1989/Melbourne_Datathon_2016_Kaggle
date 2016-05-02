library(tm)
# library(RWeka)
library(parallel)
options(mc.cores=1)

replacePunctuation <- function(strings){
    gsub("[[:punct:]]", " ", strings)
    return(strings)
}

tfidf_func <- function(text_vector, ngrams = 1, minDocFreq = 2, wordLengths = 3, wordLengths_max = 20, idf = TRUE){
    cat('removing special characters... \n')
    text_vector <- iconv(text_vector, to = 'utf-8', sub=' ')
    cat('load data... \n')
    review_source <- VectorSource(text_vector)
    cat('create corpus... \n')
    corpus <- Corpus(review_source)
    cat('to lower case... \n')
    corpus <- tm_map(corpus, content_transformer(tolower), lazy = T)
    cat('remove/replace punctuation... \n')
    corpus <- tm_map(corpus, content_transformer(replacePunctuation), lazy = T)
    corpus <- tm_map(corpus, removePunctuation, lazy = T)
    cat('remove numerical characters... \n')
    corpus <- tm_map(corpus, removeNumbers, lazy = T)
    cat('remove stop words... \n')
    corpus <- tm_map(corpus, removeWords, stopwords('english'), lazy = T)
    cat('strip white space... \n')
    corpus <- tm_map(corpus, stripWhitespace, lazy = T)
    cat('stemming... \n')
    corpus <- tm_map(corpus, stemDocument, 'english', lazy = T)
    
    if(idf){
        if(ngrams > 1){
            cat(paste0('tf-idf with ',ngrams,'-grams. Minimum word length: ', wordLengths, '. Minimum frequencies: ', minDocFreq, '.  \n'))
            # BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = ngrams, max = ngrams))
            
            BigramTokenizer <- function(x){
                unlist(lapply(ngrams(words(x), ngrams), paste, collapse = ""), use.names = FALSE)
            }
            dtm <- DocumentTermMatrix(corpus, 
                                      control = list(tokenize = BigramTokenizer,
                                                     minDocFreq = minDocFreq, 
                                                     wordLengths = c(wordLengths, wordLengths_max),
                                                     weighting = weightTfIdf)
                                      # ,bounds=list(global=c(floor(length(corpus)*0.05), Inf))
            )
        }else{
            cat(paste0('tf-idf with ',ngrams,'-grams. Minimum word length: ', wordLengths, '. Minimum frequencies: ', minDocFreq, '.  \n'))
            dtm <- DocumentTermMatrix(corpus, 
                                      control = list(minDocFreq = minDocFreq,
                                                     wordLengths = c(wordLengths, wordLengths_max),
                                                     weighting = weightTfIdf)
                                      # ,bounds=list(global=c(floor(length(corpus)*0.05), Inf))
            ) 
        }
    }else{
        if(ngrams > 1){
            cat(paste0('term-frequency with ',ngrams,'-grams. Minimum word length: ', wordLengths, '. Minimum frequencies: ', minDocFreq, '.  \n'))
            # BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = ngrams, max = ngrams))
            BigramTokenizer <- function(x){
                unlist(lapply(ngrams(words(x), ngrams), paste, collapse = ""), use.names = FALSE)
            }
            dtm <- DocumentTermMatrix(corpus, 
                                      control = list(tokenize = BigramTokenizer,
                                                     minDocFreq = minDocFreq, 
                                                     wordLengths = c(wordLengths, wordLengths_max))
                                      # ,bounds=list(global=c(floor(length(corpus)*0.05), Inf))
            )
        }else{
            cat(paste0('term-frequency with ',ngrams,'-grams. Minimum word length: ', wordLengths, '. Minimum frequencies: ', minDocFreq, '.  \n'))
            dtm <- DocumentTermMatrix(corpus, 
                                      control = list(minDocFreq = minDocFreq,
                                                     wordLengths = c(wordLengths, wordLengths_max))
                                      # ,bounds=list(global=c(floor(length(corpus)*0.05), Inf))
            )
        }
    }
    return(dtm)
}

