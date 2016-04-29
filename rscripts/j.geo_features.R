setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
load('../data/model/total.RData')

total$id <- 1:nrow(total)
order_id <- total$id

#########################
### 1.geo information ###
#########################
geo_info <- read.delim('../data_new/AU.txt',header = FALSE,na.strings = "",stringsAsFactors=FALSE)
names(geo_info) <- c('geonameid','name','asciiname','alternatenames','latitude','longitude',
                     'feature_class','feature_code','country_code','cc2','admin1_code',
                     'admin2_code','admin3_code','admin4_code','population','elevation',
                     'dem','timezone','modification_date')
geo_info_postal <- read.delim('../data_new/AU_postal.txt',header = FALSE,na.strings = "",stringsAsFactors=FALSE)
names(geo_info_postal) <- c('country_code','postal_code','place_name','admin_name1','admin_code1',
                            'admin_name2','admin_code2','admin_name3','admin_code3','latitude','longitude','accuracy')

head(geo_info);head(geo_info_postal)

geo_info <- geo_info[,c('geonameid','name','latitude','longitude','feature_class','feature_code','population','dem','timezone','admin1_code')]
geo_info_postal <- geo_info_postal[,c('country_code','postal_code','place_name')]

geo_info$name <- tolower(geo_info$name)
geo_info_postal$place_name <- tolower(geo_info_postal$place_name)
geo_info_postal$geonameid2 <- paste0(geo_info_postal$country_code,'-',
                                     ifelse(geo_info_postal$postal_code < 100, paste0('00', geo_info_postal$postal_code), ifelse(geo_info_postal$postal_code < 1000, paste0('0',geo_info_postal$postal_code),geo_info_postal$postal_code))
                                     ,'-',geo_info_postal$place_name)
geo_info_postal$geonameid2 <- gsub(" ", "-", geo_info_postal$geonameid2)

geo_total <- merge(geo_info_postal, geo_info, by.x = 'place_name', by.y = 'name', all.x = T, all.y = T, sort = F)
geo_total_id <- geo_total[!duplicated(geo_total$geonameid),c('geonameid','feature_class','feature_code')]
geo_total_post <- geo_total[!duplicated(geo_total$geonameid2),c('geonameid2','feature_class','feature_code')]
# save(geo_total_id, geo_total_post, file='../data_new/geo_total_info.RData')
# load('../data_new/geo_total_info.RData')

######################
### 2.job geo list ###
######################
total_geo <- total[,c('job_id', 'location_id')]; #rm(total)
total_geo$location_id_2 <- gsub("g_id:", "", total_geo$location_id)
total_geo$location_id_2 <- gsub("g_zip:", "", total_geo$location_id_2)
head(total_geo)

###############
### 3.merge ###
###############
total_geo$location_id_2 <- tolower(total_geo$location_id_2); total_geo$location_id <- NULL
geo_total$geonameid <- tolower(geo_total$geonameid); geo_total$geonameid2 <- tolower(geo_total$geonameid2)
head(total_geo); head(geo_total)

total_geo_merge <- merge(total_geo, geo_total_id, by.x = 'location_id_2', by.y = 'geonameid', all.x = T)
total_geo_merge2 <- merge(total_geo, geo_total_post, by.x = 'location_id_2', by.y = 'geonameid2', all.x = T)
dim(total_geo);dim(total_geo_merge);dim(total_geo_merge2)

total_geo_id <- total_geo_merge[!is.na(total_geo_merge$feature_class), ]
total_geo_post <- total_geo_merge2[!is.na(total_geo_merge2$feature_class), ]
dim(total_geo_id);dim(total_geo_post)
total_geo_all <- rbind(total_geo_post, total_geo_id)
# total_geo_all[total_geo_all$job_id %in% total_geo_all[duplicated(total_geo_all$job_id),'job_id'],]
total_geo_all <- total_geo_all[!duplicated(total_geo_all$job_id),] # 1. total

# bug fix
total_geo_all
missed_loc <- total[!total$job_id %in% unique(total_geo_all$job_id), c('job_id','location_id')]
# write.csv(missed_loc, file = './missed_loc.csv')
missed_loc <- read.csv('./missed_loc.csv', header = T, stringsAsFactors = F)

missed_g_zip <- missed_loc[missed_loc$Identify == 0, ]
missed_other <- missed_loc[missed_loc$Identify == 1, ]
missed_g_id <- missed_other[missed_other$location_id != 'a_id:AU',]
missed_a_id <- missed_other[missed_other$location_id == 'a_id:AU',]

missed_g_zip$name <- gsub("-", " ", missed_g_zip$Location_name)
missed_g_zip <- merge(missed_g_zip, geo_info, by = 'name', all.x = T)
missed_g_zip <- missed_g_zip[!duplicated(missed_g_zip$job_id), c('job_id', 'feature_class', 'feature_code')] # 2. missed 1

head(total[total$job_id %in% missed_g_id$job_id,'raw_location'])
missed_g_id$feature_class <- 'gid_NA'
missed_g_id$feature_code <- 'gid_NA'
missed_g_id <- missed_g_id[, c('job_id', 'feature_class', 'feature_code')] # 3. missed 2

head(missed_a_id)
head(total[total$job_id %in% missed_a_id$job_id,'raw_location'])
missed_a_id$feature_class <- 'gid_NA'
missed_a_id$feature_code <- 'gid_NA'
missed_a_id <- missed_a_id[, c('job_id', 'feature_class', 'feature_code')] # 3. missed 3

# combine
geo_infor_total <- rbind(total_geo_all[,2:4], missed_g_zip,missed_a_id, missed_g_id)
geo_infor_total <- geo_infor_total[!duplicated(geo_infor_total$job_id),]
geo_infor_total <- merge(total[,c('job_id','hat','id')], geo_infor_total, by = 'job_id', all.x = T, all.y = F, sort = F)
geo_infor_total[is.na(geo_infor_total$feature_class),3] <- 'gid_NA'
geo_infor_total[is.na(geo_infor_total$feature_code),4] <- 'gid_NA'
geo_infor_total <- geo_infor_total[order(match(geo_infor_total[,'id'],order_id)),]

geo_infor_total$feature_class <- as.factor(geo_infor_total$feature_class)
geo_infor_total$feature_code <- as.factor(geo_infor_total$feature_code)
library(caret)
dummies <- dummyVars(hat ~ ., data = geo_infor_total, sep = "_", levelsOnly = FALSE, fullRank = TRUE)
geo_info_dummy <- predict(dummies, newdata = geo_infor_total)
geo_info_dummy[is.na(geo_info_dummy)] <- 0
geo_info_dummy <- geo_info_dummy[,-c(2,21)] # check
# geo_info_dummy <- geo_info_dummy[order(match(geo_info_dummy[,'id'],order_id)),]
identical(total$job_id,geo_info_dummy[,'job_id'])
total$job_id-geo_info_dummy$job_id
save(geo_info_dummy, file='../data_new/geo_info_dummy.RData')

#########################
### 4. data dictonary ###
#########################
# The main 'geoname' table has the following fields :
# ---------------------------------------------------
# geonameid         : integer id of record in geonames database
# name              : name of geographical point (utf8) varchar(200)
# asciiname         : name of geographical point in plain ascii characters, varchar(200)
# alternatenames    : alternatenames, comma separated, ascii names automatically transliterated, convenience attribute from alternatename table, varchar(10000)
# latitude          : latitude in decimal degrees (wgs84)
# longitude         : longitude in decimal degrees (wgs84)
# feature class     : see http://www.geonames.org/export/codes.html, char(1)
# feature code      : see http://www.geonames.org/export/codes.html, varchar(10)
# country code      : ISO-3166 2-letter country code, 2 characters
# cc2               : alternate country codes, comma separated, ISO-3166 2-letter country code, 200 characters
# admin1 code       : fipscode (subject to change to iso code), see exceptions below, see file admin1Codes.txt for display names of this code; varchar(20)
# admin2 code       : code for the second administrative division, a county in the US, see file admin2Codes.txt; varchar(80) 
# admin3 code       : code for third level administrative division, varchar(20)
# admin4 code       : code for fourth level administrative division, varchar(20)
# population        : bigint (8 byte int) 
# elevation         : in meters, integer
# dem               : digital elevation model, srtm3 or gtopo30, average elevation of 3''x3'' (ca 90mx90m) or 30''x30'' (ca 900mx900m) area in meters, integer. srtm processed by cgiar/ciat.
# timezone          : the timezone id (see file timeZone.txt) varchar(40)
# modification date : date of last modification in yyyy-MM-dd format


# country code      : iso country code, 2 characters
# postal code       : varchar(20)
# place name        : varchar(180)
# admin name1       : 1. order subdivision (state) varchar(100)
# admin code1       : 1. order subdivision (state) varchar(20)
# admin name2       : 2. order subdivision (county/province) varchar(100)
# admin code2       : 2. order subdivision (county/province) varchar(20)
# admin name3       : 3. order subdivision (community) varchar(100)
# admin code3       : 3. order subdivision (community) varchar(20)
# latitude          : estimated latitude (wgs84)
# longitude         : estimated longitude (wgs84)
# accuracy          : accuracy of lat/lng from 1=estimated to 6=centroid