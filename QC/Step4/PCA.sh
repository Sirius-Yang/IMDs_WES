# Calculate PCA after excluding duplicated samples and relative samples using high quality variants (result: ukb_wes_chr_all_king_sample_qc_final_unrelated.eigenval)
# norealte_nodup.txt is the combination of IDs from king.con and related_2nd_sample_remove.txt
plink2 --bfile ukb_wes_chr_all_king_sample_qc \
--keep norelate_nodup.txt \
--make-bed \
--out ukb_wes_chr_all_king_sample_qc_final_unrelated

plink2 --bfile ukb_wes_chr_all_king_sample_qc_final_unrelated \
--pca approx \
--out ukb_wes_chr_all_king_sample_qc_final_unrelated
