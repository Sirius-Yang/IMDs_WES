setwd("E:/YJT/Exome/AIDs/BHR/Correlation")
library(data.table)
library(dplyr)
Correlation <- as.data.frame(fread("CorrelationBHR.csv"))
Correlation <- Correlation[which(Correlation$Significant==1),]
Correlation %>% group_by(Phenos) %>% summarise(maxR=max(abs(R)),posR=max(R))-> Correlation0
Correlation0$maxR <- ifelse(Correlation0$maxR==Correlation0$posR,Correlation0$maxR*1,Correlation0$maxR*(-1))
phenos <- unlist(strsplit(Correlation0$Phenos,"_"))
apheno <- phenos[seq(1,length(phenos),2)]
bpheno <- phenos[seq(2,length(phenos),2)]
Correlation0$apheno <- apheno
Correlation0$bpheno <- bpheno
Respiratory <- c("Asthma","AR")
Musculoskeletal <- c("Psoriatic","Gout","OA","Behcet","PR","AS","NV","Sicca","Myositis")
Dermatologic <- c("AD","SLE","Psoriasis","Lichen","Bullouse","AA","SD","Vitiligo","ACD","AU")
Digestive <- c("UC","Crohn","Celiec","PBC","Hepatitis","ADGC")
Endocrine_Metabolic <- c("Diabetes","Hypothyroidism","Graves")
Nerves <- c("MG","MS","GB","Narcolepsy")
Hematopoietic <- c("ITP","PA","SD","AP","ID")
Correlation0 <- Correlation0[,c(4,5,2)]
Correlation0$group <- NA
Correlation0$group <- d2$Category[match(Correlation0$apheno,d2$Pheno)]
Correlation0 <- Correlation0[order(Correlation0$group,Correlation0$apheno,decreasing = T),]
Counting <- data.frame(pheno=c(Correlation0$apheno,Correlation0$bpheno),R=rep(Correlation0$maxR,2))
Counting %>% filter(abs(R)>0.3)%>%group_by(pheno)%>%summarise(N=n()/2+2)->Counting1
Counting0 <- Counting[which(!duplicated(Counting$pheno)),]
Counting0 <- Counting0[which(!Counting0$pheno%in%Counting1$pheno),]
colnames(Counting0)<-c("pheno","N")
Counting1 <- as.data.frame(Counting1)
Counting0$N<-2
Counting <- rbind(Counting0,Counting1)
mynodes <- data.frame(name=unique(c(Correlation0$apheno,Correlation0$bpheno)))
mynodes$group <- d2$Category[match(mynodes$name,d2$Pheno)]
mynodes <- mynodes[order(mynodes$group,decreasing = T),]
mynodes <- left_join(mynodes,Counting,by=c("name"="pheno"))
library(ggraph)
library(igraph)
mygraph <- graph_from_data_frame(Correlation0,vertices = mynodes)#verticies决定点的映射
p3 <-  ggraph(mygraph, layout="linear",circular=T) + 
     geom_edge_arc(edge_width=1,aes(edge_colour=maxR,edge_alpha=ifelse(abs(maxR)>0.3,abs(maxR)/3+0.2,0.1))) +
     geom_node_point( aes(color=group,size=N)) +
     geom_node_text(aes(label=name), repel = FALSE, size=4.5, color="black",nudge_y = c(rep(0.1,8),rep(-0.1,17),rep(0.1,9))) +
     scale_edge_colour_distiller(palette = "RdBu")+
     scale_color_manual(values =c("indianred","steelblue","darkseagreen4","mediumpurple4",
                                  "lightpink3","lightsteelblue3","plum4","goldenrod"))+
     theme_void() +
     theme(
         plot.margin=unit(rep(2,4), "cm"),
         legend.position = "None"
       ) 
p3
#size: 7*7
