plink2 --bfile ukb_wes_chr_all_king_sample_qc \
--exclude \
--make-bed \
--out ukb_wes_chr_all_king_sample_qc_final_unrelated

plink2 --bfile ukb_wes_chr_all_king_sample_qc_final_unrelated \
--pca approx \
--out ukb_wes_chr_all_king_sample_qc_final_unrelated
