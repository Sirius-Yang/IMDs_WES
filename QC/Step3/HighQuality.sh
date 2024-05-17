for i in {1..22};do
plink2 --bfile ./QCStep2/ukbWES_chr${i} --maf 0.0001 --geno 0.01 --hwe 10e-6 --indep-pairwise 200 100 0.1 --make-bed --out ./QCStep3/highquality_chr${i}_v1
plink2 --bfile ./QCStep3/highquality_chr${i}_v1 --indep-pairwise 200 100 0.05 --make-bed --out ./QCStep3/highquality_chr${i}_v2
done
