library(dplyr)
setwd("E:/YJT/Exome/AIDs/Rare")
library(data.table)

Total <- as.data.frame(fread("Total.csv"))
Total <- Total |> filter(Group!="Cauchy"&Group!="missense;lof;synonymous"&Group!="missense")%>%arrange(Pheno,Region,Group,max_MAF)%>%
  mutate(Category=case_when(Pheno%in%c("Asthma","AR")~"Respiratory",
                            Pheno%in%c("Psoriatic","Gout","OA","Behcet","PR","AS","NV","Sicca","Myositis")~"Musculoskeletal",
                            Pheno%in%c("AD","SLE","Psoriasis","Lichen","Bullouse","AA","Scleroderma","Vitiligo","ACD","AU")~"Dermatologic",
                            Pheno%in%c("UC","Crohn","Celiec","PBC","Hepatitis","ADGC")~"Digestive",
                            Pheno%in%c("Diabetes","Hypothyroidism","Graves")~"Endocrine",
                            Pheno%in%c("MG","MS","GB","Narcolepsy")~"Nerves",
                            Pheno%in%c("ITP","PA","Sarcoidosis","AP","ID")~"Hematopoietic",
                            Pheno=="RF"~"Cardiovascular"),
         class=dense_rank(pick(Category,Pheno)),
         rank = dense_rank(pick(Category,Pheno,Region)))%>% group_by(rank) %>%
  distinct(BETA_Burden,SE_Burden,Pvalue_Burden,Pvalue,Pvalue_SKAT,MAC,.keep_all = T)%>%
  mutate(logp=-log10(Pvalue_SKAT),rank=rank+(class-1)*1000,
         type=case_when(Group=="lof"&max_MAF<=1e-4~"lof/UR",
                        Group=="lof"&max_MAF>1e-4~"lof/R",
                        Group=="missense;lof"&max_MAF<=1e-4~"lof+mis/UR",
                        Group=="missense;lof"&max_MAF>1e-4~"lof+mis/R",))%>% 
  group_by(class)%>% mutate(N=mean(rank))

###### visualize ######
library(ggplot2);library(ggrepel);library(ggbreak)
Total0 <- Total[which(Total$Pvalue_SKAT<2.5e-6),]
Total0 <- as.data.frame(fread("SAIGE_Cooked.csv"))
Total$Pheno <- factor(Total$Pheno,levels = unique(Total$Pheno))
test1 <- Total[which(Total$p<0.05),]
size_function <- function(data){
  p <- as.list(data[13])
  p <- as.numeric(p[[1]])
  if (p <0.02){
    size=3
  }else{
    size=1.75
  }
  return(size)
}
#对FDRP = 0.02的横线做个简单的线性插值：
x1 <- 2.284995e-06
y1 <- 1.952594e-02
x2 <- 2.534583e-06
y2 <- 2.117946e-02
y <- 0.02
x <- x1 + (y - y1) * (x2 - x1) / (y2 - y1)
print(x)
#正式绘图
p1 <- ggplot(data=test1)+
  geom_hline(yintercept = c(-log10(2.356551e-06),6), color = c('grey','grey25'),linewidth = 0.8,linetype = "dotted") +
  geom_point(aes(x=rank,y=logp,color=Pheno,shape=type),
             size=apply(test1,1,size_function),alpha=0.8)+
  scale_color_manual(values = c("indianred3",rep(c("skyblue3","steelblue"),5),
                                rep(c("darkseagreen4","darkseagreen"),3),
                                "mediumpurple4","thistle4","mediumpurple4",
                                rep(c("lightpink3","rosybrown2"),2),"lightpink3",
                                rep(c("lightsteelblue3","slategray"),4),"lightsteelblue3",
                                rep(c("plum4","thistle3"),2),
                                "khaki","goldenrod"))+
  scale_shape_manual(values = c(17,16,13,9))+
  geom_text_repel(data=subset(test1,logp>-log10(1e-6)),ylim = c(3,10),max.overlaps = 70,
                  aes(x=rank,y=logp,label=Region),size=4,fontface="italic")+
  scale_x_continuous(breaks =unique(test1$N),labels=unique(test1$Pheno),expand = c(0.01,0.01))+
  scale_y_continuous(expand = c(0,0),limits = c(2,15.5),
                     breaks = c(2,4,-log10(2.356551e-06),6,8,10,15,15.5),labels = c(2,4,"FDR 0.02",6,8,10,15,15.5))+
  scale_y_break(c(10,15),space=0.001)+
  labs(y="-log10(P)",x="")+
  theme_bw() + 
  theme(
    panel.border = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.grid.major.y = element_line(linewidth = 0.2),
    axis.text.x = element_text(angle=45,hjust = 1,vjust=0.5,
                               color="black",size=12,margin = margin(0, unit="cm")),
    axis.line.x = element_line(linetype = "solid"),
    axis.line.y.left =element_line(linetype = "solid"),
    axis.text.y.right = element_blank(),
    axis.text.y.left = element_text(size=12),
    axis.ticks.y.right = element_blank(),
    legend.text = element_text(size=14),
    legend.position = "None")
p1

"lightsteelblue3","powderblue","lightskyblue2","steelblue4","lightblue3","steelblue","lightsteelblue4"
"skyblue3","steelblue2","lightsteelblue1","cornflowerblue","slategray3","lightsteelblue"
"paleturquoise3","darkslategray","darkolivegreen","cyan4","darkseagreen","paleturquoise4",
"darkseagreen3","azure4","azure2","darkseagreen4","lightcyan4","cadetblue"
"cornsilk2","moccasin",,"papayawhip","seashell3","lightgoldenrod","khaki3","wheat","palegoldenrod"
"rosybrown2","mistyrose1","lightpink2","lavenderblush3","lavenderblush4","rosybrown"
"mistyrose2","pink3","maroon","lightpink3","mistyrose3","palevioletred3"
"thistle","mediumpurple4",,"thistle4",,"plum4","thistle3","plum3"


#colours <- Categories and Phenotype
labelfunction <- function(x){unlist(strsplit(x,0))}
p <- ggplot(Gene_pos_lof, aes(x=Poscum, y=-log10(Pvalue_SKAT))) +
  geom_point(aes(color=as.factor(Category),shape=as.factor(Shape)),alpha=0.5,size=apply(Gene_pos_lof,1,size_function))+
  scale_color_manual(values = c("slategray3",rep(c("coral","chocolate3"),4),rep(c("dodgerblue2","dodgerblue3"),3),"indianred2","indianred3","indianred2",rep(c("steelblue2","steelblue3"),2),"steelblue2",rep(c("aquamarine3","aquamarine4"),4),"aquamarine3",rep(c("plum3","plum4"),2),"darkgoldenrod2","darkgoldenrod3"),breaks = lof_pos$Category,labels=labelfunction(lof_pos$Category)) +
geom_hline(yintercept = c(6, -log10(2.5e-6)), color = c("#4876FF", 'black'),size = 1.2, linetype = c("twodash","dotted")) +
theme_bw() + 
  theme(
    panel.border = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.text.x = element_blank()
  )

# + labels
X_axis <-  Gene_pos_lof %>% group_by(Pheno) %>% summarize(center=( max(Poscum) +min(Poscum) ) / 2 )
p <- p+ labs(x = "Phenotype",y="-log10(P)",colour="Category") +
  geom_text(aes(label = Pheno, x= center,y=-1),data = X_axis,angle=90,vjust=0.5,hjust=1)

# + significant nodes
data <- Gene_pos_lof %>% mutate(is_annotate=ifelse(Pvalue_SKAT<2.5e-6, "yes", "no"))
p <- p + geom_label_repel( data=subset(data, is_annotate=="yes"), aes(label=Region), size=2,max.overlaps = 40)
p

scales::hue_pal()(4)

