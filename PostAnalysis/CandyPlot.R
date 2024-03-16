setwd("E:/YJT/Exome/AIDs/BHR/Single")
Single <- as.data.frame(fread("SingleBHR.csv"))
Aggregate <- Single[grep("Aggregate",Single$Type),]
bins <- Single[-grep("Aggregate",Single$Type),]
bins$Significant <- 0
bins$Significant[which(bins$Heritability-bins$Se>0)]<-1
library(dplyr)
bins %>% group_by(Pheno) %>% filter(Significant==1) %>%
  reframe(Beta=max(Heritability),Se=Se,Type=Type) %>% 
  distinct(Pheno,.keep_all = T)->bins
Aggregate$Type <- "Aggregate"
Aggregate %>% rename(Beta=Heritability)%>%select(4,2,3,1)->Aggregate
Total <- rbind(Aggregate,bins)
d2 <- data.frame(Category=c(rep("Respiratory",2),
                            rep("Musculoskeletal",9),
                            rep("Dermatologic",10),
                            rep("Digestive",6),
                            rep("Endocrine",3),
                            rep("Nerves",4),
                            rep("Hematopoietic",5),
                            "Cardiovascular"),
                 Pheno=c("Asthma","AR","Psoriatic","Gout","OA","Behcet","PR","AS","NV","Sicca","Myositis",
                         "AD","SLE","Psoriasis","Lichen","Bullouse","AA","Scleroderma","Vitiligo","ACD","AU",
                         "UC","Crohn","Celiec","PBC","Hepatitis","ADGC",
                         "Diabetes","Hypothyroidism","Graves",
                         "MG","MS","GB","Narcolepsy",
                         "ITP","PA","SD","AP","ID",
                         "RF"))


Total$Category <- NA
Total$Category <- d2$Category[match(Total$Pheno,d2$Pheno)]
Total$Type <- as.factor(Total$Type)

Aggregate <- Aggregate[order(Aggregate$Beta,decreasing = T),]
Aggregate$pos <- seq(1,length(Aggregate$Pheno))
Total$seq <- Aggregate$pos[match(Total$Pheno,Aggregate$Pheno)]
Total <- Total[order(Total$seq,Total$Type),]
Total$seq <- seq(1,length(Total$Pheno))
library(ggplot2)
p2 <- ggplot(data=Total)+
  geom_segment(aes(yend=Beta,color=Category,xend=seq,x=seq),y=0,linetype=ifelse(Total$Type=="Aggregate","solid","dotdash"))+
  geom_point(size=4.5,aes(color=Category,x=seq,y=Beta,shape=Type))+
  scale_color_manual(values = c("indianred3","steelblue","darkseagreen4","mediumpurple4",
                                "lightpink3","lightsteelblue3","plum4","goldenrod"))+
  scale_shape_manual(values= c(19,17,18,15))+
  theme_void()+
theme(axis.title.x = element_text(),
      axis.title.y = element_text(angle = 90),
      axis.text.y = element_text(),
      legend.position = "None",
      axis.text.x = element_text(angle=45,hjust=1,vjust = 0.5),
      axis.ticks.y = element_line(colour = "black"),
      axis.line.x = element_line(linetype = "solid"),
      axis.line.y = element_line(inherit.blank=FALSE,arrow = arrow(length = unit(0.1, "inches"),type = "closed",angle=30)),
      panel.grid.major.y = element_line(linewidth =0.25,colour = "grey90"))+
  labs(y="BHR",x="Pheno",size=5,shape="BHR Type")+
  scale_x_continuous(expand=c(0.03,0.05),breaks = seq(1.5,60,2),labels = unique(Total$Pheno))+
  scale_y_continuous(limits = c(0,0.25),expand = c(0,0))

p2