### Annotating mutation types to select putative loss-of-function variants
# snpEff GRCh38.105
for i in {1..22};
do
java -jar snpEff.jar  GRCh38.105 /home1/Huashan1/UKB_WES_data/snpEff/input/ukb_wes_chr${i}_qc.bim \
> /home1/Huashan1/UKB_WES_data/snpEff/output/GRCh38.105/ukb_wes_chr${i}_SnpEff.vcf
done

### Annotating using 5 methods to define putative damaging missense variants
# snpEff dbnsfp
for i in {1..22};
do
java -jar SnpSift.jar dbnsfp \
-f genename,Ensembl_geneid,Uniprot_acc,LRT_pred,Polyphen2_HDIV_pred,MutationTaster_pred,Polyphen2_HVAR_pred,SIFT_pred \
-db /home1/Huashan1/wbs_data/software/snpEff/data/dbNSFP/dbNSFP.txt.gz \
-g hg38 -v /home1/Huashan1/UKB_WES_data/snpEff/input/ukb_wes_chr${i}_qc.bim \
> /home1/Huashan1/UKB_WES_data/snpEff/output/dbnsfp/five/ukb_wes_chr${i}_SnpEff_five.vcf
done
