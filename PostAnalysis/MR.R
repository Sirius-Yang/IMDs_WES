library(data.table);library(TwoSampleMR);library(dplyr)
# example of formatting expousre
LTA <- as.data.frame(fread("GWAS_LTA.csv"))
LTA <- LTA[which(LTA$P<1e-5),]
LTA <- rename(LTA,SNP=ID,beta=BETA,pval=P,se=SE,effect_allele=A1,other_allele=REF,eaf=A1_FREQ)
LTA <-  format_data(LTA,type = "exposure")
LTA <- clump_data(LTA,clump_r2=0.01,clump_kb=5000)

# example of formatting outcome
Graves <- as.data.frame(fread("finngen_R8_GRAVES"))
Graves <- Graves[which(Graves$rsids%in%LTA$SNP),]
Graves <- format_data(Graves,type="outcome",snp_col = "rsids",beta_col = "beta",
                      se_col = "sebeta",
                      eaf_col = "af_alt",
                      effect_allele_col = "alt",
                      other_allele_col = "ref",
                      pval_col = "pval")

# Main functions
MR_function <- function (exposure.data,outcome.data){
  final.data = harmonise_data(exposure.data, outcome.data) 
  final.data = final.data[which(!duplicated(final.data)),]
  results = mr(final.data,method_list= c("mr_wald_ratio","mr_ivw_mre","mr_egger_regression","mr_weighted_median","mr_weighted_mode","mr_ivw_fe","mr_simple_median"))
  results$SNPs = dim(final.data)[1]
  results <- generate_odds_ratios(results) 
  heterogeneity = mr_heterogeneity(final.data) #heterogeneity test
  pleiotropy = mr_pleiotropy_test(final.data)
  results$IVW.Qpval <- heterogeneity$Q_pval[2]
  results$IVW.Q <- heterogeneity$Q[2]
  results$pleiotropy.pval<- pleiotropy$pval#pleiotropy test 1
  results$pleiotropy.intercept <- pleiotropy$egger_intercept
  results$pleiotropy.se <- pleiotropy$se
  return(list(results = results,fdata=final.data))
}
Result <- MR_function(LTA,Graves)
# If no heterogeneity or pleiotropy exists, save the results
fwrite(Result,"Hypothyroidism_CDSN_MRRes.csv")

# If heterogeneity or pleiotropy exists, try removing outliers first
final = harmonise_data(LTA, coeliac) 
results = mr(final,method_list= c("mr_wald_ratio","mr_ivw_mre","mr_ivw_fe"))
results$SNPs = dim(final.data)[1])
radial_data<-format_radial(final$beta.exposure,final$beta.outcome,
                           final$se.exposure,final$se.outcome,
                           final$SNP)
ivw.model<-ivw_radial(radial_data,0.05/nrow(radial_data),3,0.0001)
ivw.model$outliers
LTA <- LTA[which(!LTA$SNP%in%ivw.model$outliers$SNP),]

# Perform main function again after excluding outliers
