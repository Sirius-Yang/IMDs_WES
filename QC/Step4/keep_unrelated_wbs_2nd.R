library(data.table)
rm(list =ls())
data <- as.data.frame(fread('~/UKB_WES_data/qcstep4/ukb_wes_chr_all_king_sample_qc.kin0'))
#include kinship >= 0.0884
names(data)[2]<-"ID1"
names(data)[4]<-"ID2"
names(data)[8]<-"Kinship"
data <- data[data$Kinship >= 0.0884,]
#create array to save data
x<-array(0,dim=c(dim(data)[1],2))
x_cnt<-1
data_only<-x
data_only<-data.frame(data_only)
#find independent group
continue_signal <- TRUE
while_cnt <-1
while((continue_signal==TRUE)&(dim(data)[1]>0)){
  #Print cycle index 
  print(while_cnt)
  while_cnt <- while_cnt+1
  print('length data')
  print(dim(data)[1])
  #Sum data
  all_id <- cbind(data$ID1,data$ID2)
  sum <- data.frame(table(all_id))
  sum <- sum[order(sum$Freq),]
  sum$all_id <- as.numeric(as.character(sum$all_id))
  #Define whether continue
  len_sum <- as.numeric(dim(sum)[1])
  len_one <- as.numeric(sum(sum$Freq==1))
  if(len_sum==len_one){
    data_only <- data
    continue_signal <- FALSE
    break
  }else{
    #Find ID
    freq_max <- as.numeric(max(sum$Freq))
    sum_max <- sum[sum$Freq==freq_max,]
    len_sum_max <- as.numeric(dim(sum_max)[1])
    random <- ceiling( (runif(1, min=0, max=1))*len_sum_max + 0.0001 )
    if (random>len_sum_max){
      random<-len_sum_max
    }
    v1_d <- sum_max[random,1]
    #Delete same ID in data
    data_save<-data[data$ID1==v1_d,]
    if(dim(data_save)[1]!=freq_max){
      data_save<-rbind(data_save,data[data$ID2==v1_d,])
    }
    s_name1 <- as.numeric(data_save[,2])
    s_name2 <- as.numeric(data_save[,4])
    data<-data[data$ID1!=v1_d,]
    data<-data[data$ID2!=v1_d,]
    #Save ID to array
    pos<-sum(x[,1]!=0)
    x[(pos+1):(pos+length(s_name1)),1]<-s_name1
    x[(pos+1):(pos+length(s_name1)),2]<-s_name2
    x_cnt<-x_cnt+1
  }
  
}
###extract removed id
#extract id with excessive relatedness(abandon)
#x <- data.frame(x)
#x <- x[x$X1>0,]#37018 pairs
#x_remove<-unique(c(x$X1,x$X2))#45825 ren
#random keep one of the sample in the unique pair
data_only_id<-data_only[,c(2,4)]#26556 ren
data_only_remove<-as.data.frame(matrix(data = 0,nrow = nrow(data_only_id),ncol = 1))
for (i in 1:nrow(data_only_id)) {
  random <- ceiling( (runif(1, min=0, max=1))*2 + 0.0001 )
  if (random>2){
    random<-2
  }
  data_only_remove[i,1]<-data_only_id[i,random]
}#26556 ren
#extract the supplementary set
data_id <- as.data.frame(fread('~/UKB_WES_data/qcstep4/ukb_wes_chr_all_king_sample_qc.kin0'))
data_id <- data_id[data_id$KINSHIP >= 0.0884,]
data_id_all<-unique(c(data_id$IID1,data_id$IID2))#60154 ren
related_sample_remove<-setdiff(data_id_all,data_only_remove$V1)#33598 ren
#Save as txt
result<-as.data.frame(related_sample_remove)
write.table(result,"~/UKB_WES_data/qcstep4/keep_unrelated_wbs_2nd_related_sample_remove.txt",sep = "\t",row.names = F,quote = F)
