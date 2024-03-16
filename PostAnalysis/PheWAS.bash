awk '{print $1"\tvar\n"$1"\tanno"}' Gene > GeneNew 
for i in $(seq 1 22);do
awk 'NR==FNR{a[$1,$2]=$0;next}{print a[$1,$2]}' /share/home1/Vinceyang/yl_data/WES/lof_missense_five/SnpEff_gene_group_chr22.txt GeneNew > Cognition_chr${i}.txt
sed -i '/^[[:blank:]]*$/d' Cognition_chr${i}.txt
done
for Pheno in `cat PhenoList`;do
	echo ${Pheno}
	mkdir ${Pheno}
	for i in {1..22};do
	Rscript step1_fitNULLGLMM.R   \
		--sparseGRMFile=/share/home1/Vinceyang/yl_data/WES/GRM/UKB_GRM_relatednessCutoff_0.05_5000_randomMarkersUsed_unrelated_2nd_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx \
		--sparseGRMSampleIDFile=/share/home1/Vinceyang/yl_data/WES/GRM/UKB_GRM_relatednessCutoff_0.05_5000_randomMarkersUsed_unrelated_2nd_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt \
		--plinkFile=/share/home1/Vinceyang/yl_data/WES/unrelated_0_084/ukb_wes_chr${i}_sample_qc_final_unrelated \
		--useSparseGRMtoFitNULL=FALSE   \
		--useSparseGRMforVarRatio=TRUE \
		--phenoFile=/home1/Vinceyang/wxr_data/${Pheno}_Caucasian.csv \
		--phenoCol=IF \
		--covarColList=Sex,Age,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
		--sampleIDColinphenoFile=eid \
		--isCovariateOffset=FALSE \
		--traitType=binary       \
		--nThreads=30   \
		--isCateVarianceRatio=TRUE \
		--outputPrefix=/home1/Vinceyang/wxr_data/$Pheno/${Pheno}_s1_chr${i}_10PC_both	\
		--IsOverwriteVarianceRatioFile=TRUE	&#p-value TRUE FALSE
		done
  wait
done

for Pheno in `cat PhenoList`;do
for i in {1..22};do
Rscript step2_SPAtests.R \
     --bedFile=/share/home1/Vinceyang/yl_data/WES/unrelated_0_084/ukb_wes_chr${i}_sample_qc_final_unrelated.bed  \
     --bimFile=/share/home1/Vinceyang/yl_data/WES/unrelated_0_084/ukb_wes_chr${i}_sample_qc_final_unrelated.bim  \
     --famFile=/share/home1/Vinceyang/yl_data/WES/unrelated_0_084/ukb_wes_chr${i}_sample_qc_final_unrelated.fam  \
     --SAIGEOutputFile=/home1/Vinceyang/wxr_data/$Pheno/${Pheno}_chr${i}_10PC_both.txt \
     --AlleleOrder=alt-first \
     --minMAF=0 \
     --minMAC=0.5 \
     --GMMATmodelFile=/home1/Vinceyang/wxr_data/$Pheno/${Pheno}_s1_chr${i}_10PC_both.rda \
     --varianceRatioFile=/home1/Vinceyang/wxr_data/$Pheno/${Pheno}_s1_chr${i}_10PC_both.varianceRatio.txt \
     --sparseGRMFile=/share/home1/Vinceyang/yl_data/WES/GRM/UKB_GRM_relatednessCutoff_0.05_5000_randomMarkersUsed_unrelated_2nd_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx \
     --sparseGRMSampleIDFile=/share/home1/Vinceyang/yl_data/WES/GRM/UKB_GRM_relatednessCutoff_0.05_5000_randomMarkersUsed_unrelated_2nd_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt \
     --groupFile=/share/home1/Vinceyang/yl_data/WES/lof_missense_five/SnpEff_gene_group_chr${i}.txt \
     --annotation_in_groupTest="lof,missense:lof,missense" \
     --maxMAF_in_groupTest=0.00001,0.0001,0.001,0.01 \
     --is_output_markerList_in_groupTest=TRUE \
     --LOCO=FALSE \
     --is_fastTest=TRUE   &
done
wait
done