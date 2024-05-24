for i in {1..22};
do
awk -v OFS="\t" '{print $1,$4,$4,$6,$5,$2}' ukb_wes_chr${i}_qc.bim > /home1/Huashan1/UKB_WES_data/annovar/input/ukb_wes_chr${i}_qc.avinput \
;done

for i in {1..22};
do
path1=/home1/Huashan1/UKB_WES_data/annovar/output
path2=/home1/Huashan1/UKB_WES_data/annovar/input
perl table_annovar.pl ${path2}/ukb_wes_chr${i}_qc.avinput humandb/ \
-buildver hg38 \
-out ${path1}/ukb_wes_chr${i}_qc \
-remove \
-protocol refGene,gnomad211_exome,gnomad30_genome,dbnsfp42a,ensGene \
-operation g,f,f,f,g \
-nastring . \
-csvout \
;done
