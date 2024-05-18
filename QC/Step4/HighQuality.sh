### Extracting high quality variants to calculate PCA values and kinship relatedness
# maf selection, higher HWE selection, missing < 0.01, and two rounds of pairwise pruning
for i in {1..22};do
plink2 --bfile ./QCStep3/WES_qcstep3_chr${i} --maf 0.0001 --geno 0.01 --hwe 10e-6 --indep-pairwise 200 100 0.1 --make-bed --out ./QCStep4/HQ_chr${i}_v1
plink2 --bfile ./QCStep4/HQ_chr${i}_v1 --indep-pairwise 200 100 0.05 --make-bed --out ./QCStep4/HQ_chr${i}_v2
done

# Excluding ambiguous mutations （待确认）
for i in {1..22}; do
awk '{if(($5=="A") && ($6=="T"))print$2; else if(($5=="T") && ($6=="A"))print$2; else if (($5=="C") && ($6=="G"))print$2; else if(($5=="G") && ($6=="C"))print$2}' ./QCStep4/HQ_chr${i}_v2.bim | > ambiguous_chr${i}.txt
plink2 --bfile ./QCStep4/HQ_chr${i}_v2 --snps-only --exclude ambiguous_chr${i}.txt --make-bed --out ./QCStep4/HQ_chr${i}_v3
done
