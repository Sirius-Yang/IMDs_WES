#Step0 of SAIGE, create sparse GRM matrix, this script only needs to run for once
#!/bin/bash
cd /home1/Huashan2/SAIGE/extdata
Rscript createSparseGRM.R \
--plinkFile=/home1/Huashan1/UKB_WES_data/qcstep5/unrelated_0_0884/ukb_wes_chr_all_king_sample_qc_final_unrelated \
--nThreads=100  \
--outputPrefix=/home1/Huashan2/wbs_data/SAIGE/GRM/UKB_GRM_relatednessCutoff_0.05_5000_randomMarkersUsed_unrelated_2nd \
--numRandomMarkerforSparseKin=5000 \
--relatednessCutoff=0.05
