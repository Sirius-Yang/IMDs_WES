#step1:common variant around 500kb of the specific gene
#Vinceyang
{
  gene='GIGYF1'
  path1='/public/home/Vinceyang/wxr_data/conditional'
  /home1/Vinceyang/yl_data/BHR/plink --bfile /share/home1/Vinceyang/UKB_gene_v3_imp_qc/UKB_gene_v3_imp_qc_chr7 \
  --chr 7 \
  --from-bp 100179507 \
  --to-bp 101194250 \
  --maf 0.01 \
  --make-bed \
  --out ${path1}/${gene}_common_maf0.01

#step 2
awk -F',' 'NR==1 {for (i=1; i<=NF; i++) {if ($i == "eid") col1=i; if ($i == "IF") col2=i}} {print $col1 "\t" $col2}' file.txt
awk 'BEGIN {FS=OFS="\t"} {if ($2 == 0) $2 = 1; else if ($2 == 1) $2 = 2; print}' ${path3}/${lines}_pheno.csv > ${path3}/${lines}_pheno_recode.csv
path2='/home1/Vinceyang/yl_data/conditional/'
path3='/public/home/Vinceyang/yl_data/DiseaseData'
path4='/share/home1/Royce/dengyueting_data/GWAS'
pheno=''                   
gene=''
i=''
${path4}/apps/plink2 --bfile ${path2}/${gene}_common_maf0.01 \
--remove ${path4}/QC/data/ID_unavailable.txt \
--exclude /share/home1/Vinceyang/dyt_data/GWAS/sh/snp_chr${i}.txt \
--glm hide-covar \
--covar ${path3}/cov.csv \
--covar-variance-standardize \
--pheno ${path3}/${pheno}_pheno.csv \
--geno 0.1 \
--hwe 1e-50 midp \
--out ${path2}/step2/${gene}_${pheno}_gwas_result

#step3 Transform
#ADGRB2-EduYears-rs2050256
library(data.table)
data<-fread('/mnt/storage/home1/Huashan1/wxr_data/WES/conditional/bonf/rs2050256.vcf')
data[1,c(1:10)]
#CHROM      POS        ID REF ALT QUAL FILTER INFO FORMAT 2526848_2526848
#1 32204683 rs2050256   A   G    .      .   PR     GT             0/1
rownames(data) <- data$ID
data.1 <- as.data.frame(t(data[,c(10:406770)]))
data.1$eid <- rownames(data.1)
library(tidyverse)
data.1<-separate(data = data.1, col = eid, into = "eid", sep = "_")
data.1$eid <- as.integer(data.1$eid)
data.1$CF <- 0
nco <- length(data.1)-2
for (j in 1:nco){
  data.1$CF[grep('1',data.1[,j])]<- 1
}
table(data.1$CF)
data.1 <- data.1[c('eid','CF')]
colnames(data.1)<-c('eid','rs2050256')

eid<-fread('/mnt/storage/home1/Huashan1/wxr_data/WES/penetrance/eid.csv')
rdata=eid#451825
rdata<-merge(rdata,data.1,by='eid')#376912
write.csv(rdata,'/mnt/storage/home1/Huashan1/wxr_data/WES/conditional/bonf/rs2050256.raw',row.names=F,quote=F)

#add related variants as covariates
data <- read.csv("/mnt/storage/home1/Huashan1/wxr_data/ukb_field_data/Caucasian/Education_Caucasian.csv",header = T,sep='\t')
data_1 <- merge(data,rdata, by='eid')
write.csv(data_1,"/mnt/storage/home1/Huashan1/wxr_data/WES/conditional/bonf/EA.csv")

colnames(data_1)

#step4 SAIGE