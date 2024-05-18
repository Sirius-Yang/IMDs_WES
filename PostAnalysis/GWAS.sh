# This is a example of performing GWAS analysis for PBC
 #!/bin/bash
#PBS -N task
#PBS -q workq
#PBS -l nodes=2:ppn=4
#PBS -k oe

Pheno="PBC"
awk -F "," 'BEGIN{print "PLINK_ID\tIID\tIF"}''{OFS="\t"}{print $1,$1,$2}' /home1/Vinceyang/yl_data/WES_PhenoDATA/${Pheno}/${Pheno}_Caucasian.csv > /home1/Stark/yl_data/GWAS/${Pheno}/GWAS_${Pheno}_Outcome.csv

awk '{if ($NF==0) $2="1"}{if ($NF==1) $2="2"}1' /home1/Stark/yl_data/GWAS/${Pheno}/GWAS_${Pheno}_Outcome.csv > /home1/Stark/yl_data/GWAS/${Pheno}/GWAS_${Pheno}_middle.csv
awk 'BEGIN{print "PLINK_ID\tIID\tIF"}''{OFS="\t"}{print $1,$1,$2}' /home1/Stark/yl_data/GWAS/${Pheno}/GWAS_${Pheno}_middle.csv > /home1/Stark/yl_data/GWAS/${Pheno}/GWAS_${Pheno}_Outcome.csv
sed -i '2,3d' /home1/Stark/yl_data/GWAS/${Pheno}/GWAS_${Pheno}_Outcome.csv
for i in {1..22};do
plink2 --bfile /share/inspurStorage/home1/Vinceyang/UKB_gene_v3_imp_qc/UKB_gene_v3_imp_qc_chr${i} \
--geno 0.05 \
--mind 0.05 \
--glm hide-covar cols=chrom,pos,ref,alt,a1freq,nobs,beta,se,tz,p \
--maf 0.01 \
--hwe 1e-6 \
--vif 1000 \
--pheno /home1/Stark/yl_data/GWAS/${Pheno}/GWAS_${Pheno}_Outcome.csv \
--covar /home1/Vinceyang/yl_data/GWAS/GWAS_Covar.csv \
--covar-variance-standardize PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
--covar-col-nums 3,4,5,6,7,8,9,10,11,12,13,14 \
--threads 30 \
--out /home1/Stark/yl_data/GWAS/${Pheno}/GWAS_${Pheno}_chr${i} &
done
wait
echo 'Congratulations! Your work has finished'
