#exclude low call rates or were outliers (outside 8 s.d. from the mean) for a number of additional metrics
for i in {1..22};
do
/home1/Huashan1/wbs_data/software/plink2 \
--bfile /home1/Huashan1/UKB_WES_data/qcstep2/plink_qc_chr/ukb_wes_chr${i}_qc \
--keep /home1/Huashan1/UKB_WES_data/qcstep4/non_retracted_and_sex_qc_filtered.txt \
--sample-counts  'cols'=hom,het,ts,tv,dipsingle,single,missing \
--make-just-bim \
--make-just-fam \
--out /home1/Huashan1/UKB_WES_data/qcstep4/sample_qc/ukb_wes_chr${i}_sample_qc \
;done

#exclude those presence in low-complexity regions and minor allele count (≥1)
cd /home1/Huashan1/wbs_data/public_data/Ensemble_low_complexity_region/LCR-hs38.txt
#把这里面的snp去掉，用plink --keep保留 