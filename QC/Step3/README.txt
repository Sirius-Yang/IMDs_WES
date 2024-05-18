Step3 : Sample QC
---

This step removes individuals with:
· Ti/Tv ratio, heterozygote/homozygote ratio, and number of singletons beyond 8 standard deviations
· Sample call rate < 90%. 
· discordance genetic sex and self-reported sex
· participants who had rescinded their consent

---

First, the Outlier.sh script uses plink to calculate the Ti, Tv, heterozygote, homozygote, and singleton counts, along with the number of sequenced sites for each individual.
The results are saved with the suffix .scount; an example is provided (ukb_wes_chr11_sample_qc.scount).
This step also removes individuals who had rescinded their consent, and those mismatched genetic sex and self-reported sex according to UKB's official calculations. An example of the first few lines of this ID file is shown in non_retracted_and_sex_qc_filtered_sample.txt 

Then, using the result from Outlier.sh, Calculation.R computes the ratios, and call rate by dividing each individual's variant count by the total variant count, retaining the IDs of individuals who pass QC. 
An example of the first few lines of this ID file is shown (sample_qc_final_keep_example.txt). 

Finally, the KeepID.sh script keeps only those individuals who passed the sample QC.
