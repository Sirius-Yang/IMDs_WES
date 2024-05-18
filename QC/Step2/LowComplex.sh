#exclude those presence in low-complexity regions and minor allele count (≥1)
wget https://github.com/lh3/varcmp/blob/master/scripts/LCR-hs38.bed.gz
awk '{print $0,NR}' LCR-hs38.bed > LCR-hs38.txt
plink \
--exclude range /home1/Huashan1/wbs_data/public_data/Ensemble_low_complexity_region/LCR-hs38.txt
