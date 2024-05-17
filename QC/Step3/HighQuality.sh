### Extracting high quality variants to calculate PCA values and kinship relatedness
# maf selection, higher HWE selection, higher genotype quality (>99%) and indepth pairwise selection
for i in {1..22};do
plink2 --bfile ./QCStep2/WES_qcstep2_chr${i} --maf 0.0001 --geno 0.01 --hwe 10e-6 --indep-pairwise 200 100 0.1 --make-bed --out ./QCStep3/HQ_chr${i}_v1
plink2 --bfile ./QCStep3/HQ_chr${i}_v1 --indep-pairwise 200 100 0.05 --make-bed --out ./QCStep3/HQ_chr${i}_v2
done
