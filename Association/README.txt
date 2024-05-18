---
For rare variants (maf < 0.01), we use SAIGE for gene-based collapse analysis. 
First, a sparse GRM is created using the GRM.sh script, which only needs to be run once. This GRM will be adjusted in subsequent SAIGE analyses. 
Then, we run the SAIGE.sh script, which performs Step1 and Step2 sequentially to obtain gene-based results. 

---
For common variants, we use plink to perform association tests with the common.sh script.
We then apply the clump.sh script to obtain independent significant loci.
