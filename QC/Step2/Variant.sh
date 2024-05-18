### Variant quality control
ls | grep "ukb_merged_chr" > merged.txt # the name of merged files for chr1-22
# excluding those genotype < 0.1 & HWE p-value < 1E-15
while read lines; do
     plink2 --bfile ./QCStep1/${lines} --geno 0.1 --hwe 10e-15 --make-bed --out ./QCStep2/WES_step2v1_chr${i}
done < merged.txt
