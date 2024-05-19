Association tests
---

Rare:
For rare variants (maf < 0.01), we use SAIGE for gene-based collapse analysis. 
First, a sparse GRM is created using the GRM.sh script, which only needs to be run once. This GRM will be adjusted in subsequent SAIGE analyses. 
Then, we run the SAIGE.sh script, which performs Step1 and Step2 sequentially to obtain gene-based results. 

To further validate SAIGE results, we conducted a case-control enrichment analysis by comparing the mutation counts of genes deemed significant by SAIGE in both cases and controls for each disease by using Case_Control.py. This approach is also simpler and more feasible than SAIGE association analysis, offering better clinical applicability.

---

Common:
For common variants, we utilzied plink to perform association tests with the Common.sh script.
We then apply the Clump.sh script to obtain independent significant signals.
GWAS.sh was performed to identify the convergence of significant common WES variants and GWAS signals.
