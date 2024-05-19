#!/bin/bash
#PBS -N task
#PBS -q workq
#PBS -l nodes=2:ppn=4
#PBS -k oe



Pheno="Diabetes"
# transfrom to format for plink to perform association tests
awk 'BEGIN{print "PLINK_ID\tIID\tIF"}''{FS=","}{OFS="\t"}{print 0,$1,$2}' $HOME/SiriusWhite/AIDs/DiseaseData/${Pheno}_Caucasian.csv > $HOME/SiriusWhite/AIDs/WESCommon/${Pheno}/WESCommon_${Pheno}_middle.csv
awk '{OFS="\t"}{if ($NF==0) $1=1}{if ($NF==1) $1=2}1' $HOME/SiriusWhite/AIDs/WESCommon/${Pheno}/WESCommon_${Pheno}_middle.csv > $HOME/SiriusWhite/AIDs/WESCommon/${Pheno}/WESCommon_${Pheno}_middle2.csv
awk 'BEGIN{print "PLINK_ID\tIID\tIF"}''{OFS="\t"}{print 0,$2,$1}' $HOME/SiriusWhite/AIDs/WESCommon/${Pheno}/WESCommon_${Pheno}_middle2.csv > $HOME/SiriusWhite/AIDs/WESCommon/${Pheno}/WESCommon_${Pheno}_Outcome.csv
sed -i '2,3d' $HOME/SiriusWhite/AIDs/WESCommon/${Pheno}/WESCommon_${Pheno}_Outcome.csv
awk 'BEGIN{print "PLINK_ID\tIID\tAge\tSex\tPC1\tPC2\tPC3\tPC4\tPC5\tPC6\tPC7\tPC8\tPC9\tPC10"}''{FS=","}{OFS="\t"}{print 0,$1,$3,$5,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16}' $HOME/SiriusWhite/AIDs/DiseaseData/${Pheno}_Caucasian.csv > $HOME/SiriusWhite/AIDs/WESCommon/${Pheno}/WESCommon_${Pheno}_Covar.csv
sed -i '2,2d' $HOME/SiriusWhite/AIDs/WESCommon/${Pheno}/WESCommon_${Pheno}_Covar.csv

for i in {1..22};do
plink2 --bfile /mnt/storage/home1/Huashan1/UKB_WES_data/qcstep5/unrelated_0_0884/ukb_wes_chr${i}_sample_qc_final_unrelated \
--geno 0.05 \
--mind 0.05 \
--logistic hide-covar cols=chrom,pos,ref,alt,a1freq,nobs,beta,se,tz,p \
--maf 0.01 \
--hwe 1e-6 \
--vif 1000 \
--pheno /mnt/storage/home1/Huashan1/SiriusWhite/AIDs/WESCommon/${Pheno}/WESCommon_${Pheno}_Outcome.csv \
--covar /mnt/storage/home1/Huashan1/SiriusWhite/AIDs/WESCommon/${Pheno}/WESCommon_${Pheno}_Covar.csv \
--covar-variance-standardize PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
--covar-col-nums 3,4,5,6,7,8,9,10,11,12,13,14 \
--memory 16000 \
--threads 15 \
--out /mnt/storage/home1/Huashan1/SiriusWhite/AIDs/WESCommon/${Pheno}/WESCommon_Result_${Pheno}_chr${i}.csv
done
wait
echo "c.sh..finish.."
