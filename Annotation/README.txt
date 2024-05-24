Annotation
---

SnpEff:
In the SAIGE analysis, we used SnpEff annotation to classify mutation types. 

Frameshift insertion/deletion, splice acceptor, splice donor, stop gain, start loss, and stop loss mutations were categorized as predicted loss-of-function. An example file, ukb_wes_chr9_SnpEff_example.vcf, shows the first few lines of ukb_wes_chr9_SnpEff.vcf. 

Predicted deleterious missense (pmis) variants were defined as those consistently predicted to be deleterious by five in silico tools: SIFT, LRT, PolyPhen2 HDIV, PolyPhen2 HVAR, and MutationTaster. An example of these results is provided in ukb_wes_chr10_SnpEff_five_example.vcf (the first few lines of chr10 annotations). 

We then organized the results using awk and simple bash commands, as demonstrated in plof_mis_chr10_example.csv.

---

VEP：
To validate SAIGE results, we changed the annotation method in the case-control enrichment analysis, using VEP to annotate gene mutation types.

Missense variants were scored using the REVEL plugin, with higher scores indicating greater potential impact. These scores were then categorized into four groups: 0-25, 25-50, 50-75, and 75-100. A header of the result file, REVEL_chr15.txt, was provided (REVEL_chr15_example.txt)

---

ANNOVAR：
Common variants were mapped to genes by using ANNOVAR. We provided an example file as the format of input file for ANNOVAR: ukb_wes_chr9_example.avinput ( header of ukb_wes_chr9.avinput)
