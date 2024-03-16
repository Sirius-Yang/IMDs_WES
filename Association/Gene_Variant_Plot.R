library(data.table)
library(ggraph)
library(igraph)
setwd("E:/YJT/Exome/AIDs/Common/Significant")
Common <- as.data.frame(fread("CommonSignificant.csv"))
rsID <- as.data.frame(fread("AIDs_Common_rsID_pos.csv",header = F))
Common$rsID <- rsID$V1[match(Common$POS,rsID$V3)]
Common <- Common[,c(9,12:14,17)]
Respiratory <- c("Asthma","AR")
Musculoskeletal <- c("Psoriatic","Gout","OA","Behcet","PR","AS","NV","Sicca","Myositis")
Dermatologic <- c("AD","SLE","Psoriasis","Lichen","Bullouse","AA","Scleroderma","Vitiligo","ACD","AU")
Digestive <- c("UC","Crohn","Celiec","PBC","Hepatitis","ADGC")
Endocrine_Metabolic <- c("Diabetes","Hypothyroidism","Graves")
Nerves <- c("MG","MS","GB","Narcolepsy")
Blood <- c("ITP","PA","SD","AP","ID")
Common$Category <- NA
Common$Category[which(Common$Pheno%in%Dermatologic)]<-"Dermatologic"
Common$Category[which(Common$Pheno%in%Respiratory)]<-"Respiratory"
Common$Category[which(Common$Pheno%in%Musculoskeletal)]<-"Musculoskeletal"
Common$Category[which(Common$Pheno%in%Endocrine_Metabolic)]<-"Endocrine"
Common$Category[which(Common$Pheno%in%Digestive)]<-"Digestive"
Common$Category[which(Common$Pheno%in%Nerves)]<-"Nerves"
Common$Category[which(Common$Pheno%in%Blood)]<-"Haematologic"
Common$Category[which(Common$Pheno=="RF")]<-"Cardiovascular"
library(dplyr)
Common <- Common %>% mutate(Beta=abs(BETA),Shape=ifelse(BETA>0,"Increase","Decrease")) %>% select(-BETA)
Common <- Common[order(Common$Category,Common$Pheno),]
Common$pos <- seq(1,127)
Common$ID1 <- paste(Common$Pheno,Common$Gene,sep="_")
Common$ID2 <- paste(Common$rsID,Common$pos,sep="_")

edges_level1_2 <- Common %>% select(Category, Pheno) %>% unique %>% rename(from=Category, to=Pheno)
edges_level2_3 <- Common %>% select(Pheno, ID1)  %>% unique %>% rename(from=Pheno, to=ID1)
edges_level3_4 <- Common %>% select(ID1,ID2) %>% unique %>% rename(from=ID1, to=ID2)
edge_list=rbind(edges_level1_2,edges_level2_3, edges_level3_4)
edge_list <- rbind(edge_list,c("origin","Dermatologic"),c("origin","Respiratory"),c("origin","Musculoskeletal"),
                   c("origin","Endocrine"),c("origin","Digestive"),c("origin","Nerves"),c("origin","Haematologic"))

vertices = data.frame(
   name = unique(c(as.character(edge_list$from), as.character(edge_list$to)))
 )
vertices$value <- exp(Common$Beta[match(vertices$name,Common$ID2)])-0.5
vertices$shape <- Common$Shape[match(vertices$name,Common$ID2)]
vertices$group <- Common$Category[match(vertices$name,Common$ID2)]
vertices$originname <- Common$rsID[match(vertices$name,Common$ID2)]
vertices[1:7,4]<-vertices[1:7,1]
vertices[1:27,5]<-vertices[1:27,1]
vertices$id<-NA
vertices$angle<-NA
vertices3 <- vertices[144:270,]
nleaves3=length(vertices3$name)
vertices3$id <- seq(1:nleaves3)
vertices3$angle= -360 * vertices3$id / nleaves3+90

vertices1 <- vertices[28:142,]
nleaves1=length(vertices1$name)
vertices1$id <- seq(1:nleaves1)
Common$angle <- vertices3$angle[match(Common$ID2,vertices3$name)]
Common %>% group_by(ID1)%>%summarise(angle=mean(angle))->angle1
vertices1$angle <- angle1$angle[match(vertices1$name,angle1$ID1)]
vertices1$group <- Common$Category[match(vertices1$name,Common$ID1)]
vertices1$originname <- Common$Gene[match(vertices1$name,Common$ID1)]
vertices2 <- vertices[8:27,]
vertices2$group <- Common$Category[match(vertices2$name,Common$Pheno)]
vertices2$id= seq(1:20)
Common %>% group_by(Pheno)%>%summarise(angle=mean(angle-90))->angle2
vertices2$angle <- angle2$angle[match(vertices2$name,angle2$Pheno)]
vertices0 <- vertices[c(1:7,143),]

#设置每个类别独特的字体，基因用斜体，大类用粗体
vertices1$font_face<-1
vertices0$font_face<-2
vertices3$font_face<-0
vertices2$font_face<-2

vertices <- rbind(vertices0,vertices2,vertices1,vertices3)
vertices[1:143,3]<-"types"
vertices[1:26,2]<-1
vertices[27:143,2]<-1
vertices[1:7,7]<-0

vertices$hjust<-ifelse(vertices$angle < -90 & vertices$angle > -270, 1, 0)
vertices$angle<-ifelse(vertices$angle < -90 & vertices$angle > -270, vertices$angle+180, vertices$angle)
commongraph<- graph_from_data_frame(edge_list,vertices = vertices)

p1 <- ggraph(commongraph, layout = 'dendrogram', circular = TRUE) + 
  geom_edge_diagonal(aes(x=x*1.1,y=y*1.1,xend=0.97*xend,yend=0.97*yend,),color="grey85") +
  geom_node_point(aes(color=group,size=value,shape=shape)) +
  geom_node_text(aes(x = x*1.025, y=y*1.025,label=originname,angle=angle,hjust=hjust),
                 size=ifelse(vertices$font_face==2,5,4.5),vjust=0.5,
                 family= "sans",fontface=case_when(vertices$font_face==1~"italic",
                                                   vertices$font_face==0~"plain",
                                                   vertices$font_face==2~"bold"))+
  scale_color_manual(values =c("steelblue","darkseagreen4","mediumpurple4","lightpink3",
                               "lightsteelblue3","plum4","goldenrod"))+
  scale_shape_manual(values = c(5,1,16))+
  theme_void()+
  theme(legend.position="none")
p1

#pdf: 10.5*10