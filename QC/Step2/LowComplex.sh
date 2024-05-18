#exclude those presence in low-complexity regions and minor allele count (≥1)
wget https://github.com/lh3/varcmp/blob/master/scripts/LCR-hs38.bed.gz
awk '{print $0,NR}' LCR-hs38.bed > LCR-hs38.txt
for i in {1..22};do
plink \
--bfile ./QCStep2/WES_step2v1_chr${i} \
--exclude range /home1/Huashan1/wbs_data/public_data/Ensemble_low_complexity_region/LCR-hs38.txt \
--make-bed \
--out ./QCStep2/WES_step2v2_chr${i}
done
