#exclude those presence in low-complexity regions and minor allele count (≥1)
wget https://github.com/lh3/varcmp/blob/master/scripts/LCR-hs38.bed.gz

#把这里面的snp去掉，用plink --keep保留 
