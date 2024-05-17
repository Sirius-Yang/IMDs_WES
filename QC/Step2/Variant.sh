### Variant quality control
# excluding those genotype < 0.1 & HWE p-value < 1E-15
ls | grep "merge_list_chr" > merged.txt
while read lines; do
     plink2 --bfile ./QCStep1/${lines} --geno 0.1 --hwe 10e-15 --make-bed --out ./QCStep2/${lines}
done < merged.txt
