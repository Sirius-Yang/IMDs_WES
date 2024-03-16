library(data.table);library(dplyr)
library(ggplot2);library(ggh4x)
setwd("E:/YJT/Exome/AIDs/protein/Proteomic/")
Rare <- as.data.frame(fread("RareProteomic.csv"))
Rare$FDRP<-p.adjust(Rare$p,method = "fdr")
RareSig <- Rare[which(Rare$FDRP<0.05),]
Pheno <- as.data.frame(fread("E:/YJT/Exome/AIDs/Rare/STABLE_SAIGE.csv"))
RareSig$Pheno <- Pheno$Pheno[match(RareSig$gene,Pheno$Region)]
RareSig$Positons <- cumsum(abs(RareSig$t))-abs(RareSig$t)
positions <- RareSig %>%arrange(Pheno,gene)%>%ungroup()%>%
  mutate(Position=cumsum(abs(t))-abs(t),Positions=cumsum(abs(t)))%>%
  group_by(Pheno)%>%mutate(startp=min(Position),endp=max(Positions))
RareSig$PhePos_min <- positions$startp[match(RareSig$Pheno,positions$Pheno)]
RareSig$PhePos_max <- positions$endp[match(RareSig$Pheno,positions$Pheno)]
positions2 <- RareSig %>%arrange(Pheno,gene)%>%ungroup()%>%
  mutate(Position=cumsum(abs(t))-abs(t),Positions=cumsum(abs(t)))%>%
  group_by(gene)%>%mutate(startp=min(Position),endp=max(Positions))
RareSig$GenePos_min <- positions2$startp[match(RareSig$gene,positions2$gene)]
RareSig$GenePos_max <- positions2$endp[match(RareSig$gene,positions2$gene)]
RareSig %>% arrange(Pheno,gene)%>%mutate(ProPos_min=cumsum(abs(t))-abs(t),
                                         ProPos_max=cumsum(abs(t)))->RareSig

colors <- c("slategray","steelblue","steelblue3","steelblue2","skyblue3",
            "skyblue2","lightblue3","paleturquoise4","aquamarine4","darkseagreen",
            "khaki3","darkgoldenrod1","goldenrod","darksalmon","rosybrown3",
            "pink3","palevioletred3","hotpink4","mediumorchid4","mediumpurple4",
            "plum4","thistle3")
color_mapping <- data.frame(Color=colors, Pheno=unique(RareSig$Pheno))
color_function <- function(data){
  p <- as.list(data[8])
  p <- as.character(p[[1]])
  q <- color_mapping$Color[match(p,color_mapping$Pheno)]
  return(q)
}
RareSig$colors <- color_mapping$Color[match(RareSig$Pheno,color_mapping$Pheno)]
color_mapping2 <- RareSig %>% select(colors,gene) %>% distinct(gene,.keep_all = T)
color_function2 <- function(data){
  p <- as.list(data[5])
  p <- as.character(p[[1]])
  q <- color_mapping2$Color[match(p,color_mapping2$gene)]
  return(q)
}
RareSig$meanpos <- rowSums(RareSig[,14:15])/2
RareSig$forhalf <- rowSums(RareSig[,14:15]) #为了让图形聚集在半圆里，之后会设置一个NA的文字
genedata <- distinct(RareSig,gene,.keep_all = T)
Angle_Function <- function(data){
  pos <- as.list(data[17])
  pos <- as.numeric(pos[[1]])
  if(pos<=260){
    angle=-90-180/520 * pos 
  }else{
    angle=90-180/520 * pos
  }
  return(angle)
}
hjust_Function <- 
  function(data){
    pos <- as.list(data[17])
    pos <- as.numeric(pos[[1]])
    if(pos<=260){
      hjust=1
    }else{
      hjust=0
    }
    return(hjust)
  }

p2 <- ggplot(RareSig)+
  geom_rect(aes(xmin=PhePos_min,xmax=PhePos_max),fill=apply(RareSig,1,color_function),
            ymax=2,ymin=1,color="black")+
  scale_y_continuous(limits = c(0,5))+
  geom_rect(data=genedata,aes(xmin=GenePos_min,xmax=GenePos_max),
            fill=genedata$colors,ymax=3,ymin=2,
            color="black",alpha=rep(c(0.6,0.8),20))+
  theme_void()+coord_polar(theta = "x")+
  theme(legend.position = "right")+
  geom_rect(aes(xmin = ProPos_min, xmax = ProPos_max, fill = t),
            ymax = 4, ymin = 3, color = "black",alpha=0.8)+
  scale_fill_gradient2(low="steelblue", high="firebrick",midpoint = 0)+
  geom_text(aes(x=meanpos,label=ifelse(meanpos<260,paste(RareSig$protein,RareSig$gene,sep=":"),
                                       paste(RareSig$gene,RareSig$protein,sep=":")),y=4.25,
            angle=apply(RareSig,1,Angle_Function),hjust=apply(RareSig,1,hjust_Function)),size=5)+
  geom_text(aes(x=forhalf),y=5,label=NA)
p2
figurelegend <- ggplot(RareSig)+
  geom_rect(aes(xmin=PhePos_min,xmax=PhePos_max,fill=Pheno),
            ymax=2,ymin=1,color="black")+
  scale_fill_manual(values = color_mapping$Color)+
  theme(legend.position = "top")
figurelegend
