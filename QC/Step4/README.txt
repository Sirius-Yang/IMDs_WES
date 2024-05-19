Step4 :  Further QC using high-quality variants 
---

In this part, three QC were performed:
· kinship calculation, 2nd degree and above relatives were excluded
· remove duplicated samples between instances / centers
· calculate principle componets

---

High-quality SNPs were selected by using HighQuality.sh, which filtered:
· a minor allele frequency (MAF) > 0.1%
· call rate > 99%
· HWE P-value > 1x10^-6. 
· two rounds of pruning (Plink parameters: -indep-pairwise 200 1000.1 and -indep-pairwise 200 100 0.05). 

---

Duplicated individuals were identified using king software in Nodup.sh, with results saved in the king.con file. 
An example of the first few lines of this file is provided (king_example.con).

Kinship coefficients were calculated with Relative.sh, with a kinship threshold set at 0.0884 (second-degree relatives). 
An example of the first few lines of kinship result was provided (ukb_wes_chr_all_king_sample_qc.kin0).
To maximize sample retention, for each pair with a kinship coefficient > 0.0884, we iteratively removed individuals related to multiple others until none remained, then randomly removed one individual from each related pair by using keep_unrelated_2nd.py 

Finally, we removed duplicated and second-degree related samples from the entire dataset and the high-quality variants. 
PCA was then calculated using high-quality variants by running PCA.sh, and the first 10 PCA (an example: ukb_wes_chr_all_king_sample_qc_final_unrelated.eigenval) were used as covariates in association tests for common and rare variants.
