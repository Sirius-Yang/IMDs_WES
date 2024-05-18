### Combining files of the same chromosome to one file

# Download files from UKB RAP 
mkdir ~/UKB_WES_data/qcstep1/merge_by_chrom/
cd ~/UKB_WES_data/qcstep1/merge_by_chrom/
dx download project-GF4jpV8JyFyK68BP64YpqFYQ:/Sirius_data/plink/ukb*

for i in $chrt; do
  cat merge_list_chr${i}.txt | head -n 1 >> merge_list_first_row_clean.txt
done

# Combination files 
n=0
while IFS= read -r line;do
  ((n++))
  bfile=`echo ${lines} | awk '{print $2}'`
  plink \
  --bfile ${bfile} \
  --merge-list ~/UKB_WES_data/qcstep1/merge_by_chrom/sed_1d/merge_list_chr${n}.txt \
  --make-bed \
  --out ~/UKB_WES_data/qcstep1/plink_qc_chr/ukb_wes_chr${n}_qc
done < ~/UKB_WES_data/qcstep1/merge_by_chrom/merge_list_first_row_clean.txt
