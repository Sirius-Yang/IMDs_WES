# Gene-based analysis for rare variants
for i in {1..22}; do
Rscript step1_fitNULLGLMM.R     \
    --sparseGRMFile=UKB_GRM_relatednessCutoff_0.05_5000_randomMarkersUsed_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx \
    --sparseGRMSampleIDFile=UKB_GRM_relatednessCutoff_0.05_5000_randomMarkersUsed_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt \
    --plinkFile=/home1/Vinceyang/yl_data/sample_qc_final/ukb_wes_chr${i}_sample_qc_final \
    --useSparseGRMtoFitNULL=FALSE    \
	--useSparseGRMforVarRatio=TRUE \
    --phenoFile=../Collapse/UC/IBD_Caucasian.csv \
    --phenoCol=UC \
    --covarColList=sex,age,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
	--qCovarColList=sex  \
    --sampleIDColinphenoFile=eid \
	--isCovariateOffset=FALSE \
	--nThreads=150 \
    --traitType=binary          \
    --isCateVarianceRatio=TRUE	\
    --outputPrefix=../Collapse/UC/UC_s1_chr${i}_10PC_both \
    --IsOverwriteVarianceRatioFile=TRUE	
done


for i in {1..22}; do
  Rscript step2_SPAtests.R \
     --bedFile=/home1/Huashan1/UKB_WES_data/qcstep5/unrelated_0_0442/ukb_wes_chr${i}_sample_qc_final_unrelated.bed  \
     --bimFile=/home1/Huashan1/UKB_WES_data/qcstep5/unrelated_0_0442/ukb_wes_chr${i}_sample_qc_final_unrelated.bim  \
     --famFile=/home1/Huashan1/UKB_WES_data/qcstep5/unrelated_0_0442/ukb_wes_chr${i}_sample_qc_final_unrelated.fam  \
     --SAIGEOutputFile=/mnt/storage/home1/Huashan1/SiriusWhite/Collapse/AIDs/Psoriasis/Psoriasis_chr${i}_10PC_both.txt \
     --AlleleOrder=ref-first \
     --minMAF=0 \
     --minMAC=0.5 \
     --GMMATmodelFile=/share/inspurStorage/home1/Vinceyang/yl_data/Collapse/Psoriasis/Psoriasis_s1_chr${i}_10PC_both.rda \
     --varianceRatioFile=/share/inspurStorage/home1/Vinceyang/yl_data/Collapse/Psoriasis/Psoriasis_s1_chr${i}_10PC_both.varianceRatio.txt \
     --sparseGRMFile=/home1/Huashan1/UKB_WES_data/SAIGE/Huashan1/GRM/UKB_GRM_relatednessCutoff_0.05_5000_randomMarkersUsed_unrelated_3rd_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx \
     --sparseGRMSampleIDFile=/home1/Huashan1/UKB_WES_data/SAIGE/Huashan1/GRM/UKB_GRM_relatednessCutoff_0.05_5000_randomMarkersUsed_unrelated_3rd_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt \
     --groupFile=/home1/Huashan1/UKB_WES_data/snpEff/output/SAIGE_group_file/lof_missense_five/SnpEff_gene_group_chr${i}.txt \
     --annotation_in_groupTest="lof,missense:lof" \
     --maxMAF_in_groupTest=0.00001,0.0001,0.001,0.01 \
     --is_output_markerList_in_groupTest=TRUE \
     --LOCO=FALSE \
     --is_fastTest=TRUE   #p-value TRUE FALSE
done
