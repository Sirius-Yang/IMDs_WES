library(optparse)
library(data.table)
library(dplyr)
setwd("/mnt/storage/home1/Huashan3/yl_data/BHR/")
option_list <- list(make_option("--Pheno", type="character",default=""))
parser <- OptionParser(usage="%prog [options]", option_list=option_list)
args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)
MyPheno=opt$Pheno


Freq_Case <- as.data.frame(fread(paste("./",MyPheno,"/",MyPheno,"_Freq_Case",sep="")))
Freq_Control <- as.data.frame(fread(paste("./",MyPheno,"/",MyPheno,"_Freq_Control",sep="")))
Freq_Case <- rename(Freq_Case,MAF_Case=MAF,N_Case=NCHROBS)
Freq <- Freq_Case
Freq$N_Control <- Freq_Control[match(Freq$SNP,Freq_Control$SNP),6]
Freq$MAF_Control <- Freq_Control[match(Freq$SNP,Freq_Control$SNP),5]
Freq <- Freq[which(Freq$MAF_Case!="MAF"),]
Freq$N_Case <- as.numeric(Freq$N_Case)
Freq$N_Control <- as.numeric(Freq$N_Control)
Freq$Total <- Freq$N_Case+Freq$N_Control
Freq$MAF_Case<-as.numeric(Freq$MAF_Case)
Freq$MAF_Control<-as.numeric(Freq$MAF_Control)
Freq$ac_case <- Freq$MAF_Case*Freq$N_Case
Freq$ac_ctrl <- Freq$MAF_Control*Freq$N_Control
Freq$ac_case<-round(Freq$ac_case)
Freq$ac_ctrl<-round(Freq$ac_ctrl)
Gene <- as.data.frame(fread("baseline_symbol.txt"))
Gene <- Gene[,c(1,3:6)]
Gene <- rename(Gene,gene=V1)
Variant <-  as.data.frame(fread("SnpEff_gene_group_allchr.csv"))
LM_Freq <- Freq[which(Freq$SNP%in%Variant$V2),]
LM_Freq$gene_id <- Variant[match(LM_Freq$SNP,Variant$V2),1]
LM_Freq<-rename(LM_Freq,locus=SNP)

library(tidyverse)
library(bhr)
wrangle_sumstats <- function(table, myPheno) {
  
  #Compute sample prevalence, will be used to compute per-sd beta
  table$prevalence = table$N_Case/(table$N_Case+table$N_Control)
  
  #Compute variant MAF in cases, will be used to compute per-sd beta
  table$AF_case = table$MAF_Case
  
  #Compute variant MAFoverall, will be used to compute per-sd beta
  table$AF = (table$ac_case + table$ac_ctrl)/(table$N_Case + table$N_Control)
  
  #calculate per-sd betas
  table$beta = (2 * (table$AF_case - table$AF) * table$prevalence)/sqrt(2 * table$AF * (1 - table$AF) * table$prevalence * (1 - table$prevalence))
  
  #calculate variant variances
  table$twopq = 2*table$AF * (1 - table$AF)
  
  #convert betas from per-sd (i.e. sqrt(variance explained)) to per-allele (i.e. in units of phenotype) betas.
  #per-allele are the usual betas reported by an exome wide association study.
  table$beta_perallele = table$beta/sqrt(table$twopq)
  
  #aggregate into gene-level table.
  #position doesn't need to be super precise, as it is only used to order genes for jackknife
  #N = sum of case and control counts
  sumstats = data.frame(gene = table$gene_id,
                        AF = table$AF,
                        beta = table$beta_perallele,
                        gene_position = parse_number(sapply(strsplit(table$locus, split = ":"), function(x) x[[2]])),
                        chromosome =  parse_number(sapply(strsplit(table$locus, split = ":"), function(x) x[[1]])),
                        N = (table$N_Case + table$N_Control)/2,
                        phenotype_key = myPheno)
  
  return(sumstats)
}

Sum_LM <- wrangle_sumstats(LM_Freq,MyPheno)
Sum_LM <- Sum_LM[which(!is.na(Sum_LM$beta)),]
fwrite(Sum_LM,paste("./",MyPheno,"/",MyPheno,"_total_Sumstats",sep=""),sep="\t",quote=F)
Bin1_Sum_LM <- Sum_LM[which(Sum_LM$AF<1e-5),]
BHR_LM_Bin1 <- BHR(trait1_sumstats = Bin1_Sum_LM,
                   annotations = list(Gene),
                   num_blocks = 100,
                   mode = "univariate")
t1 <- c("lof_mis_Bin1",BHR_LM_Bin1$mixed_model$heritabilities[1,5],BHR_LM_Bin1$mixed_model$heritabilities[2,5])
Bin2_Sum_LM <- Sum_LM[which(Sum_LM$AF<1e-4&Sum_LM$AF>=1e-5),]
BHR_LM_Bin2 <- BHR(trait1_sumstats = Bin2_Sum_LM,
                   annotations = list(Gene),
                   num_blocks = 100,
                   mode = "univariate")
t2 <- c("lof_mis_Bin2",BHR_LM_Bin2$mixed_model$heritabilities[1,5],BHR_LM_Bin2$mixed_model$heritabilities[2,5])
Bin3_Sum_LM <- Sum_LM[which(Sum_LM$AF<1e-3&Sum_LM$AF>=1e-4),]
BHR_LM_Bin3 <- BHR(trait1_sumstats = Bin3_Sum_LM,
                   annotations = list(Gene),
                   num_blocks = 100,
                   mode = "univariate")
t3 <- c("lof_mis_Bin3",BHR_LM_Bin3$mixed_model$heritabilities[1,5],BHR_LM_Bin3$mixed_model$heritabilities[2,5])
Bin4_Sum_LM <- Sum_LM[which(Sum_LM$AF<1e-2&Sum_LM$AF>=1e-3),]
BHR_LM_Bin4 <- BHR(trait1_sumstats = Bin4_Sum_LM,
                   annotations = list(Gene),
                   num_blocks = 100,
                   mode = "univariate")
t4<- c("lof_mis_Bin4",BHR_LM_Bin4$mixed_model$heritabilities[1,5],BHR_LM_Bin4$mixed_model$heritabilities[2,5])


lof <- Variant[which(Variant$V4=="lof"),]
missense <- Variant[which(Variant$V4=="missense"),]
L_Freq <- LM_Freq[which(LM_Freq$locus%in%lof$V2),]
M_Freq <- LM_Freq[which(LM_Freq$locus%in%missense$V2),]
Sum_L <- wrangle_sumstats(L_Freq,MyPheno)
Sum_L <- Sum_L[which(!is.na(Sum_L$beta)),]
fwrite(Sum_L,paste("./",MyPheno,"/",MyPheno,"_lof_Sumstats",sep=""),sep="\t",quote=F)
Bin1_Sum_L <- Sum_L[which(Sum_L$AF<1e-5),]
BHR_L_Bin1 <- BHR(trait1_sumstats = Bin1_Sum_L,
                  annotations = list(Gene),
                  num_blocks = 100,
                  mode = "univariate")
t5 <- c("lof_Bin1",BHR_L_Bin1$mixed_model$heritabilities[1,5],BHR_L_Bin1$mixed_model$heritabilities[2,5])
Bin2_Sum_L <- Sum_L[which(Sum_L$AF<1e-4&Sum_L$AF>=1e-5),]
BHR_L_Bin2 <- BHR(trait1_sumstats = Bin2_Sum_L,
                  annotations = list(Gene),
                  num_blocks = 100,
                  mode = "univariate")
t6 <- c("lof_Bin2",BHR_L_Bin2$mixed_model$heritabilities[1,5],BHR_L_Bin2$mixed_model$heritabilities[2,5])
Bin3_Sum_L <- Sum_L[which(Sum_L$AF<1e-3&Sum_L$AF>=1e-4),]
BHR_L_Bin3 <- BHR(trait1_sumstats = Bin3_Sum_L,
                  annotations = list(Gene),
                  num_blocks = 100,
                  mode = "univariate")
t7 <- c("lof_Bin3",BHR_L_Bin3$mixed_model$heritabilities[1,5],BHR_L_Bin3$mixed_model$heritabilities[2,5])
Bin4_Sum_L <- Sum_L[which(Sum_L$AF<1e-2&Sum_L$AF>=1e-3),]
BHR_L_Bin4 <- BHR(trait1_sumstats = Bin4_Sum_L,
                  annotations = list(Gene),
                  num_blocks = 100,
                  mode = "univariate")
t8<- c("lof_Bin4",BHR_L_Bin4$mixed_model$heritabilities[1,5],BHR_L_Bin4$mixed_model$heritabilities[2,5])


Sum_M <- wrangle_sumstats(M_Freq,MyPheno)
Sum_M <- Sum_M[which(!is.na(Sum_M$beta)),]
fwrite(Sum_M,paste("./",MyPheno,"/",MyPheno,"_misense_Sumstats",sep=""),sep="\t",quote=F)
Bin1_Sum_M <- Sum_M[which(Sum_M$AF<1e-5),]
BHR_M_Bin1 <- BHR(trait1_sumstats = Bin1_Sum_M,
                  annotations = list(Gene),
                  num_blocks = 100,
                  mode = "univariate")
t9 <- c("mis_Bin1",BHR_M_Bin1$mixed_model$heritabilities[1,5],BHR_M_Bin1$mixed_model$heritabilities[2,5])
Bin2_Sum_M<- Sum_M[which(Sum_M$AF<1e-4&Sum_M$AF>=1e-5),]
BHR_M_Bin2 <- BHR(trait1_sumstats = Bin2_Sum_M,
                  annotations = list(Gene),
                  num_blocks = 100,
                  mode = "univariate")
t10 <- c("mis_Bin2",BHR_M_Bin2$mixed_model$heritabilities[1,5],BHR_M_Bin2$mixed_model$heritabilities[2,5])
Bin3_Sum_M <- Sum_M[which(Sum_M$AF<1e-3&Sum_M$AF>=1e-4),]
BHR_M_Bin3 <- BHR(trait1_sumstats = Bin3_Sum_M,
                  annotations = list(Gene),
                  num_blocks = 100,
                  mode = "univariate")
t11 <- c("mis_Bin3",BHR_M_Bin3$mixed_model$heritabilities[1,5],BHR_M_Bin3$mixed_model$heritabilities[2,5])
Bin4_Sum_M <- Sum_M[which(Sum_M$AF<1e-2&Sum_M$AF>=1e-3),]
BHR_M_Bin4 <- BHR(trait1_sumstats = Bin4_Sum_M,
                  annotations = list(Gene),
                  num_blocks = 100,
                  mode = "univariate")
t12 <- c("mis_Bin4",BHR_M_Bin4$mixed_model$heritabilities[1,5],BHR_M_Bin4$mixed_model$heritabilities[2,5])

Result <- as.data.frame(rbind(t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12))
fwrite(Result,paste("./",MyPheno,"/",MyPheno,"_BHRUnivariate.csv",sep=""),sep="\t",quote=F)

Agg <- BHR(mode = "aggregate",
           ss_list = list(Bin1_Sum_L,Bin2_Sum_L,Bin3_Sum_L,Bin4_Sum_L,Bin1_Sum_M,Bin2_Sum_M,Bin3_Sum_M,Bin4_Sum_M),
           trait_list = list(MyPheno),
           annotations = list(Gene))
Aggregate <- c(paste(MyPheno,"_Aggregate_Total",sep=""),Agg$aggregated_mixed_model_h2,Agg$aggregated_mixed_model_h2se)
Result <- rbind(Result,Aggregate)
fwrite(Result,paste("./",MyPheno,"/",MyPheno,"_BHRUnivariate.csv",sep=""),sep="\t",quote=F)
