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
