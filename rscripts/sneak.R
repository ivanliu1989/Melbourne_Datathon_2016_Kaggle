setwd('C:\\Users\\iliu2\\Datathon 2016')
files <- list.files('./data', full.names = T)

library(data.table)
job_clicks <- fread(files[1])
job_impressions <- fread(files[2])
job_searches <- fread(files[3])
job_jobs <- fread(files[4])

table(job_jobs$hat)


#"NormalizedGini" is the other half of the metric. This function does most of the work, though
SumModelGini <- function(solution, submission) {
  df = data.frame(solution = solution, submission = submission)
  df <- df[order(df$submission, decreasing = TRUE),]
  df
  df$random = (1:nrow(df))/nrow(df)
  df
  totalPos <- sum(df$solution)
  df$cumPosFound <- cumsum(df$solution) # this will store the cumulative number of positive examples found (used for computing "Model Lorentz")
  df$Lorentz <- df$cumPosFound / totalPos # this will store the cumulative proportion of positive examples found ("Model Lorentz")
  df$Gini <- df$Lorentz - df$random # will store Lorentz minus random
  print(df)
  return(sum(df$Gini))
}

NormalizedGini <- function(solution, submission) {
  SumModelGini(solution, submission) / SumModelGini(solution, solution)
}


solution <- c(1,1,1,1,0,0,0,0)
submission <- c(0.66,0.45,0.93,0.77,0.23,0.56,0.47,0.15)
submission <- c(0,0,1,0,1,1,1,1)

SumModelGini(solution,submission)
NormalizedGini(solution,submission)

gini_auc <- function(res, mtd = 'G2A'){
  if(mtd == 'G2A'){
    auc <- (res + 1)/2
    return(auc)
  }else if(mtd == 'A2G'){
    gini <- 2*res - 1
    return(gini)
  }else {
    print('Wrong input!')
    return(res)
  }
}

gini_auc(auc(solution,submission), mtd = 'A2G')
library(pROC)
auc(solution,submission)
