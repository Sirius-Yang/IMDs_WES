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

#### REVEL ####
dx download project-GF4jpV8JyFyK68BP64YpqFYQ:file-GGj89G8JyFyBF54g2P05Xybq
mv revel-v1.3_all_chromosomes.zip ~/.vep/Plugins
unzip revel-v1.3_all_chromosomes.zip
cat revel_with_transcript_ids | tr "," "\t" > tabbed_revel.tsv
sed '1s/.*/#&/' tabbed_revel.tsv > new_tabbed_revel.tsv
bgzip new_tabbed_revel.tsv
zcat new_tabbed_revel.tsv.gz | head -n1 > Sirius_title
zgrep -h -v ^#chr new_tabbed_revel.tsv.gz | awk '$3 != "." ' | sort -k1,1 -k3,3n - | cat Sirius_title - | bgzip -c > Sirius_tabbed_revel_grch38.tsv.gz
tabix -f -s 1 -b 3 -e 3 Sirius_tabbed_revel_grch38.tsv.gz

for i in {1..22};do
nohup vep -i /home1/Huashan1/SiriusWhite/AIDs/VEP/dbNSFP/VEP_chr${i}.txt \
--cache --dir $HOME/.vep \
--cache_version 108 \
--assembly GRCh38 \
--plugin REVEL,/home1/Huashan1/.vep/Plugins/dbNSFPFiles/dbNSFP4.3c_grch38.gz \
-o /mnt/storage/home1/Huashan1/SiriusWhite/AIDs/VEP/REVEL/REVEL_chr${i}.txt \
--force_overwrite &
done
wait
echo "Finished annotation of REVEL scores"
