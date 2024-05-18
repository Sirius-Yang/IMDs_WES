# Clump the results of common variants
#!/bin/bash
Pheno=$1
ResultName=$2
awk 'BEGIN{print "MarkerName\tAllele1\tAllele2\tEffect\tStdErr\tP-value\tDirection\tHetISq\tHetChiSq\tHetDf\tHetPVal"}''{OFS="\t"}{print $3,$5,$4,$9,$10,$12}' $Pheno/${Pheno}_Common.txt > ${Pheno}_ForClump.txt

sed -i '2,2d' ${Pheno}_ForClump.txt
$HOME/yl_data/plink \
--bfile /share/home1/Vinceyang/yl_data/WES/unrelated_0_084/ukb_wes_chr6_sample_qc_final_unrelated \
--clump ${Pheno}_ForClump.txt \
--clump-p1 1e-6 \
--clump-p2 1e-4 \
--clump-r2 0.1 \
--clump-kb 10000 \
--clump-field P-value \
--clump-snp-field MarkerName \
--out $ResultName
