####### VEP Analaysis #######
# Changing into VEP Format
for i in {1..22};do
awk 'BEGIN {print "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO"}''{OFS="\t"}{print $1,$4,$2,$6,$5}' /home1/Huashan1/UKB_WES_data/qcstep5/unrelated_0_0884/ukb_wes_chr${i}_sample_qc_final_unrelated.bim > VEP_chr${i}.txt
done

#### LOFTEE ####
for i in {1..22};do
nohup perl /home1/Huashan1/miniconda3/envs/VEP_HS1/bin/vep \
-i /home1/Huashan1/SiriusWhite/VEP/VEP_Input/VEP_chr${i}.txt \
-plugin LoF,loftee_path:/home1/Huashan1/.vep/Plugins/loftee-master/,human_ancestor_fa:false \
--dir_plugins /home1/Huashan1/.vep/Plugins/loftee-master/ \
--cache --dir /home1/Huashan1/.vep \
--cache_version 108 \
--assembly GRCh38 \
-o /home1/Huashan1/SiriusWhite/VEP/loftee_chr${i}.txt \
--force_overwrite &
done
wait
echo "Finished annotation of LOFTEE"
