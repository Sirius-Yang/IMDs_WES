Large-scale whole exome sequencing of immune-mediated diseases in 350770 adults 
---
This repository contains code of the main steps for quality control, annotation, association test for common (logisitic) and rare (SKAT) variants, and post analyses.

The complete analysis workflow begins with quality control (QC) from Step1 to Step4. 

Following QC, annotation starts; the primary analysis utilizes SnpEff for annotations, while case-control enrichment employs VEP annotations. 

Subsequently, variant and gene-based association tests are conducted separately for common and rare variants, and sensitivity analysis were further adopted to validate their robustness.

Finally, various post-analyses are performed, including BHR heritage analysis and correlation analysis, Cox survival analysis, Gene expression, MR analysis, annotating amino acid alterations, Proteomic-wide analysis, and PheWAS analysis. We have uploaded important codes for this section.


---
Workflow: QC -> Annotation -> Association -> PostAnalysis

In each directory, we have included a README.txt file that provides more detailed information. We further provided important input or result files (excluding those in bed/bim/fam formats) to facilitate better visualization.

---
Plot1 : Study Design. Crafted by Adobe, no analysis, no code.

Plot2 : 

· (A) Result of gene-based collapse analysis for rare vairants, main result 1. All codes are provided (QC, Annotation, and performing GRM.sh, SAIGE.sh)

· (B) Result of case-control enrichment. 

Plot3 :

· (A) Result of variant level association test for common variants. All codes are provided (QC, and common.sh, clump.sh)

· (B) Convergence of GWAS signals. Main code to perform GWAS association test is provided (GWAS.sh)

· (C) Pleiotropy effect of common variants.

Plot4 :

· (A) Burden heritability. All codes are provided (Heritage.R)

· (B) Genetic correlations of IMDs. All codes are provided (Correlation.R)

Plot 5 :

· (A) Protein expression levels between mutation carriers and non-carriers. A very simple t-test.

· (B) MR analysis. All codes provided. 

· (C) Annotation of amino acid alterations. 

Plot 6 :

· (A) PheWAS analysis of rare variants. It is also performed by SAIGE, very similar to Plot2 (A) so no codes provided.

· (B) PheWAS analysis of common variants. It is also performed by plink, very similar to Plot3 (A) so no codes provided.

· (C) PPI and clusters performed by STRING. This is a web-based API, and no code is used here.

· (D) Single-cell expression analysis.

