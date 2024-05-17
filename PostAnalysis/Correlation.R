#For calculating the correlation between phenotypes using heritage of rare variants
library(optparse)
library(data.table)
library(dplyr)
option_list <- list(make_option("--Pheno1", type="character",default=""))
parser <- OptionParser(usage="%prog [options]", option_list=option_list)
args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)
Pheno1=opt$Pheno1
library(tidyverse)
library(bhr)

Gene <- as.data.frame(fread("baseline_symbol.txt"))
Gene <- Gene[,c(1,3:6)]
Gene <- rename(Gene,gene=V1)
Sum_L1  <- as.data.frame(fread(paste("./",Pheno1,"/",Pheno1,"_lof_Sumstats",sep="")))
PhenoList <- as.data.frame(fread("Pheno",header=F))
i <- PhenoList[which(PhenoList$V1==Pheno1),2]
print(i)
j <- i

for (j in i:35){
  j=j+1
  Pheno2 <- PhenoList[which(PhenoList$V2==j),1]
  print(Pheno2)
  Sum_L2  <- as.data.frame(fread(paste("./",Pheno2,"/",Pheno2,"_lof_Sumstats",sep="")))
  Bin1_Sum_L1 <- Sum_L1[which(Sum_L1$AF<1e-5),]
  Bin1_Sum_L2 <- Sum_L2[which(Sum_L2$AF<1e-5),]
  BHR_L_Bin1 <-  BHR(trait1_sumstats = Bin1_Sum_L1,
                     trait2_sumstats = Bin1_Sum_L2,
                     annotations = list(Gene),
                     num_blocks = 100,
                     mode = "bivariate")
  t1 <- c("lof_Bin1",BHR_L_Bin1$rg$rg_mixed,BHR_L_Bin1$rg$rg_mixed_se,paste(Pheno1,"_",Pheno2,sep=""))
  
  Bin2_Sum_L1 <- Sum_L1[which(Sum_L1$AF<1e-4&Sum_L1$AF>=1e-5),]
  Bin2_Sum_L2 <- Sum_L2[which(Sum_L2$AF<1e-4&Sum_L2$AF>=1e-5),]
  BHR_L_Bin2 <-  BHR(trait1_sumstats = Bin2_Sum_L1,
                     trait2_sumstats = Bin2_Sum_L2,
                     annotations = list(Gene),
                     num_blocks = 100,
                     mode = "bivariate")
  t2 <- c("lof_Bin2",BHR_L_Bin2$rg$rg_mixed,BHR_L_Bin2$rg$rg_mixed_se,paste(Pheno1,"_",Pheno2,sep=""))
  
  
  Sum_M1  <- as.data.frame(fread(paste("./",Pheno1,"/",Pheno1,"_misense_Sumstats",sep="")))
  Sum_M2  <- as.data.frame(fread(paste("./",Pheno2,"/",Pheno2,"_misense_Sumstats",sep="")))
  Bin1_Sum_M1 <- Sum_M1[which(Sum_M1$AF<1e-5),]
  Bin1_Sum_M2 <- Sum_M2[which(Sum_M2$AF<1e-5),]
  BHR_M_Bin1 <-  BHR(trait1_sumstats = Bin1_Sum_M1,
                     trait2_sumstats = Bin1_Sum_M2,
                     annotations = list(Gene),
                     num_blocks = 100,
                     mode = "bivariate")
  t4 <- c("missense_Bin1",BHR_M_Bin1$rg$rg_mixed,BHR_M_Bin1$rg$rg_mixed_se,paste(Pheno1,"_",Pheno2,sep=""))
  
  Bin2_Sum_M1 <- Sum_M1[which(Sum_M1$AF<1e-4&Sum_M1$AF>=1e-5),]
  Bin2_Sum_M2 <- Sum_M2[which(Sum_M2$AF<1e-4&Sum_M2$AF>=1e-5),]
  BHR_M_Bin2 <-  BHR(trait1_sumstats = Bin2_Sum_M1,
                     trait2_sumstats = Bin2_Sum_M2,
                     annotations = list(Gene),
                     num_blocks = 100,
                     mode = "bivariate")
  t5 <- c("missense_Bin2",BHR_M_Bin2$rg$rg_mixed,BHR_M_Bin2$rg$rg_mixed_se,paste(Pheno1,"_",Pheno2,sep=""))
  
  Sum_L1 <- Sum_L1[which(Sum_L1$AF<=1e-4),]
  Sum_L2 <- Sum_L2[which(Sum_L2$AF<=1e-4),]
  BHR_L  <-  BHR(trait1_sumstats = Sum_L1,
                 trait2_sumstats = Sum_L2,
                 annotations = list(Gene),
                 num_blocks = 100,
                 mode = "bivariate")
  t3 <- c("lof",BHR_L$rg$rg_mixed,BHR_L$rg$rg_mixed_se,paste(Pheno1,"_",Pheno2,sep=""))
  
  Sum_M1 <- Sum_M1[which(Sum_M1$AF<=1e-4),]
  Sum_M2 <- Sum_M2[which(Sum_M2$AF<=1e-4),]
  BHR_M  <-  BHR(trait1_sumstats = Sum_M1,
                 trait2_sumstats = Sum_M2,
                 annotations = list(Gene),
                 num_blocks = 100,
                 mode = "bivariate")
  t6 <- c("missense",BHR_M$rg$rg_mixed,BHR_M$rg$rg_mixed_se,paste(Pheno1,"_",Pheno2,sep=""))
  
  Result <- as.data.frame(rbind(t1,t2,t3,t4,t5,t6))
  fwrite(Result,paste("./Correlations/",Pheno1,"_",Pheno2,"_BHR.csv",sep=""),sep="\t",quote=F)
}
