The central script used for Step1 is `genotype.py`. Among this script, two steps were carried out, include:

1, Split multi-allelic sites to represent separate bi-allelic sites (the mttransfer function)

2, Genotype quality control (the genotypeqc function)

• For homozygous reference calls: Genotype Quality < 20; Genotype Depth < 10; Genotype Depth > 200
• For heterozygous calls: (A1 Depth + A2 Depth)/Total Depth < 0.9; A2 Depth/Total Depth < 0.2; Genotype likelihood[ref/ref] < 20; Genotype Depth < 10; Genotype Depth > 200
• For homozygous alternative calls: (A1 Depth + A2 Depth)/Total Depth < 0.9; A2 Depth/Total Depth < 0.9; Genotype likelihood[ref/ref] < 20; Genotype Depth < 10; Genotype Depth > 20; Genotype Depth > 200

