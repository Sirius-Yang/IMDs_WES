### check-sex
#使用文件待确认！！！！
plink \
--bed /home1/ISTBI_data/UKB/ukbExome/ukb23155_cX.bed \
--bim /home1/Vinceyang/wbs_data/UKB_WES_bim/UKBexomeOQFE_chrX.bim \
--fam /home1/ISTBI_data/UKB/ukbExome/ukb23155_cX_b0_v1_s200603.fam \
--check-sex \
--out check_sex_test
