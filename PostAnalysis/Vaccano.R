library(data.table);library(ggplot2);library(ggh4x)
setwd("E:/YJT/Exome/AIDs/protein/Proteomic/")
Origin <- as.data.frame(fread("E:/YJT/Exome/AIDs/PheWAS/Common/Disease/CommonAnnotation.csv"))
Origin$seq <- seq(1,142)
rsID <- as.data.frame(fread("E:/YJT/Exome/AIDs/Common/Significant/AIDs_Common_rsID_pos.csv",header = F))
rsID$pos<- paste("chr",rsID$V2,":",rsID$V3,":",rsID$V5,":",rsID$V6,sep="")
Origin <- Origin[which(Origin$ID%in%rsID$pos),]
Common <- as.data.frame(fread("Common_Proteomic.csv"))
Common <- Common[which(Common$Seq%in%Origin$seq),]
Common <- Common[which(Common$Estimate!="Estimate"),]
Common$pos<-Origin$ID[match(Common$Seq,Origin$seq)]
Common$rsID<-rsID$V1[match(Common$pos,rsID$pos)]
Common %>% mutate_at(vars(1:4), as.numeric)%>%select(-"pos")%>%
  mutate(rank=paste(rsID,Protein,sep="_"))%>%distinct(rank,.keep_all = T)%>%
  mutate(FDRP=p.adjust(`Pr(>|t|)`,method = "fdr"))->Common
Common$logp <- -log10(Common$FDRP)
Sigc <- Common %>% filter(FDRP<0.05)
fwrite(Sigc,"STABLE_C_Proteomic.csv")
SigcN <-Common %>% filter(FDRP<0.05) %>%group_by(rsID)%>%summarise(N=n())%>%
  arrange(desc(N))%>%mutate(label = if_else(row_number() <= 20, 1, 0)) %>%filter(label==1)
library(dplyr)
Common <- Common[which(Common$rsID%in%SigcN$rsID),]
Common %>%arrange(rsID, Estimate) %>%
  group_by(rsID) %>%
  mutate(dec = if_else(row_number() <= 2, 1, 0)) %>%
  ungroup()->Common
Common %>%arrange(rsID, desc(Estimate)) %>%
  group_by(rsID) %>%
  mutate(inc = if_else(row_number() <= 2, 1, 0)) %>%
  ungroup()->Common
u <- list()
C <- list()
for (i in 1:4){
  u[[i]] <- unique(Common$rsID)[((i-1)*5+1):((i-1)*5+5)]
  C[[i]] <- Common[which(Common$rsID%in%u[[i]]),]
}
p <- list()
fourth_trans <- function(x) {ifelse(x >= 0, x^0.25, -(-x)^0.25)}
fourth_inv <- function(x) {ifelse(x >= 0, x^4, -(-x)^4)}
library(scales)
vacanno_trans <- trans_new(
  name = "customSqrt",
  transform = fourth_trans,
  inverse = fourth_inv
)
library(ggrepel)
library(RColorBrewer)
for (i in 1:4){
  p[[i]] <- ggplot(C[[i]])+
    geom_point(data=subset(C[[i]],FDRP<0.05),aes(x=Estimate,y=logp,color=Estimate),size=1)+
    geom_point(data=subset(C[[i]],FDRP>0.05),aes(x=Estimate,y=logp,color=Estimate),size=0.5,alpha=0.5)+
    geom_hline(yintercept = -log10(0.05),linetype="dotted")+
    geom_text_repel(data=subset(C[[i]],dec==1),aes(x=Estimate,y=logp,label=Protein),size=4)+
    geom_text_repel(data=subset(C[[i]],inc==1),aes(x=Estimate,y=logp,label=Protein),size=4)+
    scale_colour_gradient2(low="steelblue",high="firebrick",midpoint = 0, trans=vacanno_trans)+
    scale_y_log10(guide = "axis_logticks") +
    facet_grid2(vars(rsID),scales = "free", independent = "x",switch = "y")+
    theme_void()+
    theme(axis.line.x = element_line(colour = "black"),
          axis.text.x = element_text(size=7),
          axis.ticks.length.x = unit(.2,"lines"),
          axis.ticks.x = element_line(color="black"),
          axis.ticks.y = element_line(color="black"),
          axis.ticks.length.y = unit(0.3, "cm"),
          axis.text.y = element_text(size=7),
          strip.text.y = element_text(size=9, hjust=1,face="bold"), 
          strip.placement = "outside", 
          legend.position = "None"
    )
}
library(patchwork)
p[[1]] | p[[2]] | p[[3]] | p[[4]] 
