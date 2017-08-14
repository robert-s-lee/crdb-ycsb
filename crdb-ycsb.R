
require(ggplot2)
require(data.table)

DT = read.csv("results.csv")

x = melt(DT, id=c("db","workload","replica","time","scenario"))

ggplot(subset(x,scenario=="run"))+
  geom_point(aes(x=workload,y=value,color=as.factor(replica)))+
  facet_grid (variable ~ db,scales="free_y")

ggsave("crdb-ycsb.pdf")

