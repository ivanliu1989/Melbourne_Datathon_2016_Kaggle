setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
source('./rscripts/f.crawler.R')

categories <- c('Airlines%20&%20Travel%20Agents',
                'Bars',
                'Restaurants',
                'Cafes',
                'Gaming%20Venues',
                'Domestic%20Services',
                'Tourist%20Attractions%20&%20Information',
                'Travel%20Agents',
                'Hospitality%20(Training%20&%20Development)')
urls <- paste0('http://www.yellowpages.com.au/search/listings?clue=',categories,'&pageNumber=')
xpath<-"//meta[@itemprop='name']"
content<-"content"

dt_total <- data.frame(url = 1, vari = 1)
for (url in urls){
    cat(paste0(url,'\n'))
    for(page in 1:100){
        url_temp <- paste0(url,page)
        cat(paste0('  -page ', page, '. url: ',url_temp, ' \n'))
        dt <- crawler2(url_temp,xpath,content)
        dt_total <- rbind(dt_total, dt)
    }
}
