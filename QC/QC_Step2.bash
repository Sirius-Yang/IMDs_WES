### Combining files of the same chromosome to one file
t=$(seq 1 22)
total="$t X Y"
for i in $total; do
    cat SiriusWork.txt | grep "_c${i}_" > merge_list_chr${i}.txt
done

for i in $total; do
	cat merge_list_chr${i}.txt | head -n 1 >> merge_list_first_row_clean.txt
done

while read i;do
  n=`echo $i| awk '{print $1}'`
  bfile=`echo $i| awk '{print $2}'`
  plink \
  --bfile ${bfile} \
  --merge-list ~/UKB_WES_data/qcstep1/merge_by_chrom/sed_1d/merge_list_chr${n}.txt \
  --make-bed \
  --out ~/UKB_WES_data/qcstep1/plink_qc_chr/ukb_wes_chr${n}_qc
done < ~/UKB_WES_data/qcstep1/merge_by_chrom/merge_list_first_row_clean.txt


### Variant quality control
ls | grep "merge_list_chr" > merged.txt
while read lines; do
     plink2 --bfile test_qc_autosomal --geno 0.1 --hwe 10e-15 --make-bed --out test_qc_autosomal
done < merged.txt



#使用填充后的array，可以有更多SNP,首先用填充后的bgen和sample文件生成bim文件
#要保证样本在array和wes数据里均存在

cat ukb19542_imp_chr15_v3_s487378.sample | awk '{print $2}' > /mnt/storage/home1/Huashan1/SiriusWhite/Array_ID.txt
cat ukb_wes_chr15_qc.fam | awk '{print $2}' > /mnt/storage/home1/Huashan1/SiriusWhite/WES_ID.txt
cat WES_ID.txt Array_ID.txt | sort | uniq -d > ID0.txt
awk '{print $1,$1}' ID0.txt > ID.txt #--keep 要求必须有FID, IID两列，否则会报错，所以这里给ID0添上一行


for i in {1..22}; do
plink2 --bgen /share/inspurStorage/home1/UKB_Gene_v3/disk10t_2/batch/imp/ukb_imp_chr${i}_v3.bgen \
--sample /share/inspurStorage/home1/UKB_Gene_v3/disk10t_2/batch/sample/ukb19542_imp_chr${i}_v3_s487378.sample \
--keep /mnt/storage/home1/Huashan1/SiriusWhite/ID.txt \
--maf 0.0001 --geno 0.01 --hwe 10e-6 --make-just-bim \
--out /mnt/storage/home1/Huashan1/SiriusWhite/HighQuality/array_imp_chr${i}_snp_list
echo ${i}
done


#bgen参考的是hg19，需要先从hg19转为hg38
for i in {1..22}; do
cat array_imp_chr${i}_snp_list.bim | awk '{print "chr"$1,$4,$4+1}' > array_imp_chr${i}_snp_list.bed #liftover的'.bed'文件有自己的格式,chrxx,起始pos，终止pos
./liftOver array_imp_chr${i}_snp_list.bed hg19ToHg38.over.chain array_imp_chr${i}_hg38.bed unMapped
#用填充后的数据取交集
awk -F " " 'NR==FNR{a[$4]=$0;next}{print a[$2]}' wes_chr${i}_snp_list.bim array_imp_chr${i}_hg38.bed | grep -v '^$' > intersect_chr${i}.txt
echo ${i}
done


#去除模糊的SNP突变
for i in {1..22}; do
cat /home1/Huashan1/SiriusWhite/HighQuality/wes_chr${i}_snp_list.bim | awk '{if(($5=="A") && ($6=="T"))print$2; else if(($5=="T") && ($6=="A"))print$2; else if (($5=="C") && ($6=="G"))print$2; else if(($5=="G") && ($6=="C"))print$2}' > ambiguous_chr${i}.txt
done


#提取高质量的WES SNP
for i in {1..22}; do
plink2 --bfile wes_chr${i}_snp_list --extract intersect_chr${i}.txt --snps-only --exclude ambiguous_chr${i}.txt --indep-pairwise 200 100 0.1 --make-bed --out wes_array_snp_chr${i}_v1
plink2 --bfile wes_array_snp_chr${i}_v1 --indep-pairwise 200 100 0.05 --out wes_array_snp_chr${i}_v2
done


#合并到一个文件
cp wes_array_snp_chr1_v2.prune.in wes_array.prune.in
for i in {2..22}; do
cat wes_array_snp_chr${i}_v2.prune.in >> wes_array.prune.in
done