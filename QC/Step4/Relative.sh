# Create king matrix of 2nd degree (ukb_wes_chr_all_king_sample_qc.kin0)
home1/Huashan1/wbs_data/software/plink2 \
--bfile /home1/Huashan1/UKB_WES_data/qcstep4/sample_qc_final/ukb_wes_chr_all_king_sample_qc \
--make-king \ 
--make-king-table \
--king-table-filter 0.0884 \
--threads 60 \
--out /home1/Huashan1/UKB_WES_data/qcstep4/ukb_wes_chr_all_king_sample_qc
