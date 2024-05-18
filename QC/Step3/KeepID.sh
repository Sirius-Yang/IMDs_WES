# Keep those IDs that passed Sample QC using results from Calculate.R
for i in {1..22};do
nohup plink --bfile ./QCStep3/WES_step3v1_chr${i} \
--keep sample_qc_final_keep.txt \
--make-bed \
--out ./QCStep3/WES_step3v2_chr${i} &
done
