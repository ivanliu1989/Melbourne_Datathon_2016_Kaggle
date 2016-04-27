### train ###
head(train,1)
col <- colnames(train)

row <- paste0(train[,ncol(train)],paste0(" '",train[,1]),"|n ")
row2 <- sapply(2:(ncol(train)-1), function(i) {
    cat(paste0('feature:',colnames(train)[i],'. \n'))
    if(i==(ncol(train)-1)){
        paste0(col[i],":",train[,i])
    }else{
        paste0(col[i],":",train[,i]," ")
    }
})

train_vw <- cbind(row,row2)
train_vw_int <- matrix(data = "",nrow = nrow(train_vw),ncol = 1)
for(i in 1:dim(train_vw)[2]){
    train_vw_int[,1] <- paste0(train_vw_int[,1],train_vw[,i])
}

write.table(train_vw_int, "../train.vw", quote = F,row.names = F,col.names = F)
