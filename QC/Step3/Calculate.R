# Combining the results from Outlier.sh
# Calculating Ti/Tv, Het/Hom, number of singletons, and sample call rate
# Exclude Ti/Tv, Het/Hom, and number of singletons out of 8 s.d, and sample call rate < 0.9 from ID list
library(data.table)
setwd("/home1/Huashan1/UKB_WES_data/QCstep3")
rm(list = ls())
filelist <- list.files("/home1/Huashan1/UKB_WES_data/QCstep3")
filelist<-grep("scount$",filelist,value = T)

sample_id<-as.data.frame(matrix(nrow=453812,ncol=22))

#read in files
for (i in c(1:length(filelist))) {
  filepath<-filelist[i]
  data<-as.data.frame(fread(filepath))
  coln<-paste("chr",i,sep = "")
  sample_id[,i]<-data[,1]
  names(sample_id)[i]<-coln
}

for (i in 2:22) {
  result<-all.equal(sample_id[,1],sample_id[,i])
  print(result)
}

#matrix plus matrix
sc_all<-vector("list", length = 22)

for (i in c(1:length(filelist))) {
  filepath<-filelist[i]
  data<-as.data.frame(fread(filepath))
  sc_all[[i]]<-as.matrix(data)
}

sc_all_matrix<-matrix(0,nrow=453812,ncol=8)
for (i in 1:22) {
  sc_all_matrix<-sc_all_matrix+sc_all[[i]]
}
#calculate Ti/Tv, Het/Hom, number of singletons
sc_all_matrix<-as.data.frame(sc_all_matrix)
names(sc_all_matrix)[1]<-"IID"
sc_all_matrix$IID<-sc_all_matrix$IID/22
sc_all_matrix$Ti_Tv<-sc_all_matrix$TRANSITION_CT/sc_all_matrix$TRANSVERSION_CT
sc_all_matrix$Het_Hom<-sc_all_matrix$HET_CT/sc_all_matrix$HOM_CT
sc_all_matrix$singletons<-sc_all_matrix$SINGLETON_CT
sc_all_matrix$call_rate<-1-(sc_all_matrix$MISSING_CT/20080554)

#sample qc start
Ti_Tv_mean<-mean(sc_all_matrix$Ti_Tv)
Ti_Tv_sd<-sd(sc_all_matrix$Ti_Tv)
Het_Hom_mean<-mean(sc_all_matrix$Het_Hom)
Het_Hom_sd<-sd(sc_all_matrix$Het_Hom)
singletons_mean<-mean(sc_all_matrix$singletons)
singletons_sd<-sd(sc_all_matrix$singletons)

Ti_Tv_pass<-subset(sc_all_matrix,(sc_all_matrix$Ti_Tv > (Ti_Tv_mean-8*Ti_Tv_sd)) & (sc_all_matrix$Ti_Tv < (Ti_Tv_mean+8*Ti_Tv_sd)),select = "IID") #0 people filtered
Het_Hom_pass<-subset(sc_all_matrix,(sc_all_matrix$Het_Hom > (Het_Hom_mean-8*Het_Hom_sd)) & (sc_all_matrix$Het_Hom < (Het_Hom_mean+8*Het_Hom_sd)),select = "IID") #1733 people filtered
singletons_pass<-subset(sc_all_matrix,(sc_all_matrix$singletons > (singletons_mean-8*singletons_sd)) & (sc_all_matrix$singletons < (singletons_mean+8*singletons_sd)),select = "IID") #286 people filtered

call_rate_90_pass<-subset(sc_all_matrix,sc_all_matrix$call_rate>=0.9,select = "IID") #14 people filtered

sample_qc_final_keep<-intersect(Ti_Tv_pass,Het_Hom_pass) %>% intersect(singletons_pass) %>% intersect(call_rate_90_pass)
sample_qc_final_keep$FID<-0
sample_qc_final_keep<-sample_qc_final_keep[,c(2,1)]

write.table(sample_qc_final_keep,"~/UKB_WES_data/QCstep3/sample_qc_final_keep.txt",sep = "\t",row.names = F,quote = F)
