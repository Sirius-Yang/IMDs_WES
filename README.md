# IMDs_WES
This repository contains code of the main steps for quality control, annotation of VEP, association test for common (logisitic) and rare (SKAT) variants, and post analyses.

The complete analysis workflow begins with quality control (QC) from Step1 to Step4. 

Following QC, annotation starts; the primary analysis utilizes SnpEff for annotations, while case-control enrichment employs VEP annotations. 

Subsequently, variant and gene-based association tests are conducted separately for common and rare variants, and sensitivity analysis were further adopted to validate their robustness.

Finally, various post-analyses are performed, including BHR heritage analysis and correlation analysis, Cox survival analysis, Gene expression, MR analysis, annotating amino acid alterations, Proteomic-wide analysis, and PheWAS analysis. 
