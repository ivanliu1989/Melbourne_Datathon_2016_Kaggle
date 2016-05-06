setwd('/Users/ivanliu/Downloads/datathon2016/Melbourne_Datathon_2016_Kaggle')
rm(list=ls());gc()
load('../data/model/total.RData')
require(data.table)
# pred_a <- a
# pred_a$hat <- pred_a$hat >=0.5
# pred_a$hat2 <- b$hat >= 0.5
# pred_a$vari <- pred_a$hat == pred_a$hat2
# 
# total[total$job_id %in% pred_a[!pred_a$vari, 'job_id'],]
# a[a$job_id==1301928,]
# b[b$job_id==1301928,]

a <- read.csv('../pred/submissions_20160501_unigram_full_idf_salary_geo.csv')
b <- read.csv('../pred/submissions_20160502_bigram_full_idf_salary_geo.csv')
c <- read.csv('../pred/submissions_20160505_0.986796.csv')
d <- read.csv('../pred/submissions_20160505_0.987314.csv')
e <- read.csv('../pred/submit_20160505_0.1_fix2_0.986502.csv')
f <- read.csv('../pred/submit_20160505_0.1_fix2_0.989216.csv')
g <- read.csv('../pred/submit_20160505_0.2_fix2_0.986292.csv')
h <- read.csv('../pred/submit_20160505_0.2_bytree_3.40pm.csv')

pred <- a
pred$hat <- 0.15 * a$hat + 
            0.65/6 * b$hat + 
            0.65/6 * c$hat +
            0.65/6 * d$hat +
            0.65/6 * e$hat +
            0.65/6 * f$hat +
            0.65/6 * g$hat +
            0.20 * h$hat

cor(h$hat,pred$hat)
write.csv(pred, file = '../blend/submit_20160505_blend_8_models.csv', row.names = F)

### NI
a <- read.csv('../blend/12_10_xgb_on_all_train_md_20_salary_location_all_1_and_2_gram.csv')
b <- read.csv('../blend/submit_20160505_blend_8_models.csv')

df.a.b.merge <- merge(a
      , b
      , by = "job_id"
      , sort = F)
cor(df.a.b.merge$hat.x, df.a.b.merge$hat.y)

job_id <- df.a.b.merge$job_id
hat <- 0.6 * df.a.b.merge$hat.x + 0.4 * df.a.b.merge$hat.y
submit <- data.table(job_id = job_id, hat = hat)
write.csv(submit, file = '../pred_final/noah_ivan_0.6_0.4_by_colmn.csv', row.names = F, quote = F)
# 0.98991, 3:7
###


cor(a$hat,b$hat)
head(a)
head(b)
hist(log(a$hat))
hist(log(b$hat))






















df.a.b.merge$NOAH <- df.a.b.merge$hat.x >= 0.5
df.a.b.merge$IVAN <- df.a.b.merge$hat.y >= 0.5
df.a.b.merge$DIFF <- df.a.b.merge$IVAN == df.a.b.merge$NOAH
table(df.a.b.merge$DIFF)
diff <- df.a.b.merge[!df.a.b.merge$DIFF, ]
head(diff, 20)[11:20,]
total[total$job_id %in% head(diff, 20)[11:20,1], c('job_id','title','abstract')]

head(total[total$hat == 1, 'class_description'])
