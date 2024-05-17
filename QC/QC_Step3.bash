###High-quality variants for sample quality control and relationship inference
#High-quality independent autosomal variants subset
plink2 --bfile test_qc_autosomal --maf 0.0001 --geno 0.01 --hwe 10e-6 --indep-pairwise 200 100 0.1 --make-bed --out high_quality_v1
plink2 --bfile high_quality_v1 --indep-pairwise 200 100 0.05 --make-bed --out high_quality_v2

#WES-vs-array independent autosomal variants subset
#WES
plink2 --bfile test_qc_autosomal --maf 0.0001 --geno 0.01 --hwe 10e-6 --out wes_snp_list
#array
plink2 --bfile array_autosomal --maf 0.0001 --geno 0.01 --hwe 10e-6 --out array_snp_list
#取交集
cat wes_snp_list.bim array_snp_list.bim | sort | uniq -d > intersect_snp.txt

cat /home1/Huashan1/wbs_data/UKB_exome_bim/raw/UKBexomeOQFE_chr1.bim | awk '{if(($5=="A") && ($6=="T"))print$2}' > ambiguous_1
cat /home1/Huashan1/wbs_data/UKB_exome_bim/raw/UKBexomeOQFE_chr1.bim | awk '{if(($5=="T") && ($6=="A"))print$2}' > ambiguous_2
cat /home1/Huashan1/wbs_data/UKB_exome_bim/raw/UKBexomeOQFE_chr1.bim | awk '{if(($5=="C") && ($6=="G"))print$2}' > ambiguous_3
cat /home1/Huashan1/wbs_data/UKB_exome_bim/raw/UKBexomeOQFE_chr1.bim | awk '{if(($5=="G") && ($6=="1"))print$2}' > ambiguous_4
cat ambiguous* > ambiguous_snp.txt

plink2 --extract intersect_snp.txt --snps-only --exclude ambiguous_snp.txt --indep-pairwise 200 100 0.1 --make-bed --out wes_array_snp_v1
plink2 --bfile wes_array_snp_v1 --indep-pairwise 200 100 0.05 --out wes_array_snp_v2

###Sample quality control
king -b high_quality_v2.bed --related 计算HetConc
#合并wes_array为一个家系
#分析同上
#check-sex
plink \
--bed /home1/ISTBI_data/UKB/ukbExome/ukb23155_cX_b0_v1.bed \
--bim /home1/Vinceyang/wbs_data/UKB_WES_bim/UKBexomeOQFE_chrX.bim \
--fam /home1/ISTBI_data/UKB/ukbExome/ukb23155_cX_b0_v1_s200603.fam \
--check-sex \
--out check_sex_test

#PCA based on king matrix
home1/Huashan1/wbs_data/software/plink2 \
--bfile /home1/Huashan1/UKB_WES_data/qcstep4/sample_qc_final/ukb_wes_chr_all_king_sample_qc \
--make-king \ 
--make-king-table \
--king-table-filter 0.0884 \
--pca approx \
--threads 60 \
--out /home1/Huashan1/UKB_WES_data/qcstep4/ukb_wes_chr_all_king_sample_qc

## exclude duplicated
cd /home1/Huashan1/UKB_WES_data/qcstep4/
king -b /home1/Huashan1/UKB_WES_data/qcstep4/HQ_autosomal_gene/ukb_wes_chr_all_king_new.bed --duplicate --cpus 64
