options(scipen = 10)

library(ggplot2)
library(scales)
library(dplyr)
library(gridExtra)
library(scales)
library(colorspace)


get_legend<-function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)}

##### get data in for each BehaviourSpace experiment #####

exp1_df = read.csv("Summative-experiment-1-1-table_all.csv",stringsAsFactors = FALSE, header = TRUE)
exp2_df = read.csv("Summative-experiment-4-1-table_all.csv",stringsAsFactors = FALSE, header = TRUE)


#Names for plots
market_name = "Market shape"
firm_name = "Number of firms"
val_name = "Total value"

poss_os_name = "Proportion of possible code open sourced"
poss_title = "Possible OS code"
val_firm_name = "Value per firm"


##### Market allocations ####

market_df = read.csv("Market_allocations.csv",stringsAsFactors = FALSE, header = TRUE)
market_df <- within(market_df,
                    Strategy <- factor(Strategy,
                                       levels = c("Ideal",
                                                  "Early",
                                                  "Trend",
                                                  "Skeptic",
                                                  "Holdout")))

get_plot = function(name, colour){
  data = market_df[market_df$Market == name,]
  
  ggplot(data = data,aes(x = data$Strategy,y = data$Number)) +
    geom_bar(stat = "identity",
             colour = colour,
             fill = colour) +
    ggtitle(name) +
    scale_y_continuous(breaks = seq(2,10,2),limits = c(0,11))+
    theme(text = element_text(size=8),
          plot.title = element_text(size=10),
          axis.title = element_text(size = 8),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text = element_text(size=6),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line.y = element_blank(),
          axis.line.x = element_line(colour = "black"))
}

plot_colors = pal(7)

b = get_plot("Balanced",pal(7)[1])
c = get_plot("C",pal(7)[2])
d = get_plot("D",pal(7)[3])
o = get_plot("Optimistic",pal(7)[4])
p = get_plot("Pessimistic",pal(7)[5])
s = get_plot("S",pal(7)[6])
t = get_plot("S-1",pal(7)[7])


market_plot = grid.arrange(c,d,o,p,s,t,b,
                           ncol = 2)
ggsave("market_plot.png",market_plot, units = "cm",width = 12, height = 12)


#### Experiment 1 ####

#summary
ex1_val_sum <- aggregate(exp1_df$total_value, list(exp1_df$market_shape), FUN=mean)
colnames(ex1_val_sum) = c(market_name,val_name)
ex1_poss_os <- aggregate(exp1_df$round_prop_os_poss, list(exp1_df$market_shape), FUN=mean)
colnames(ex1_poss_os) = c(market_name,poss_title)
ex1_summary = cbind.data.frame(ex1_val_sum,ex1_poss_os$`Possible OS code`)
colnames(ex1_summary) <- c(market_name,val_name,poss_title)

write.csv(ex1_summary, "ex1-1_all_summary.csv")

#plots
ex1_tot_plot = ggplot(exp1_df,aes(exp1_df$market_shape,
                                  exp1_df$total_value,
                                  color = exp1_df$market_shape)) +
  geom_boxplot() +
  xlab(market_name) +
  ylab(val_name) +
  ggtitle(val_name) +
  scale_color_viridis_d(name = "Market",option = "A",begin = 0.2,end = 0.8)+
  theme(text = element_text(size=8),
        plot.title = element_text(size=10),
        axis.title = element_text(size = 8),
        axis.text = element_text(angle = 90,size=6),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.title.x = element_blank())


# Proportion of possible
ex1_poss_plot = ggplot(exp1_df,aes(exp1_df$market_shape,
                                   exp1_df$round_prop_os_poss,
                                   color = exp1_df$market_shape)) +
  scale_color_viridis_d(name = "Market",option = "A",begin = 0.2,end = 0.8)+
  geom_boxplot() +
  xlab(market_name) +
  ylab(poss_os_name) +
  ggtitle(poss_title) +
  theme(text = element_text(size=8),
        plot.title = element_text(size=10),
        axis.title = element_text(size = 8),
        axis.text = element_text(angle = 90,size=6),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.title.x = element_blank())

exp1_plot = grid.arrange(ex1_tot_plot + theme(legend.position = "None"),
                         ex1_poss_plot+ theme(legend.position = "None"),
                         ncol = 2)

ggsave("exp1_all_plot.png",exp1_plot, units = "cm",width = 12, height = 8)


#### Experiment 2 ####

#summaries
exp2_val_sum <- aggregate(exp2_df$total_value, list(exp2_df$market_shape,exp2_df$num_firms), FUN=mean)
exp2_val_firm <- aggregate(exp2_df$value_firm, list(exp2_df$market_shape,exp2_df$num_firms), FUN=mean)
exp2_poss_os <- aggregate(exp2_df$round_prop_os_poss, list(exp2_df$market_shape,exp2_df$num_firms), FUN=mean)

exp2_summary = cbind.data.frame(exp2_val_sum,exp2_val_firm$x,exp2_poss_os$x)

colnames(exp2_summary) <- c(market_name,firm_name,val_name,val_firm_name,poss_title)

write.csv(exp2_summary, "exp2_summary.csv")


#plot total value

exp2_tot_plot = ggplot(exp2_df,aes(x=exp2_df$num_firms,
                                  y=exp2_df$total_value,
                                  color = exp2_df$market_shape)) +
  geom_point(size = 0.25,alpha = 0.25) + 
  scale_color_viridis_d(name = "Market",option = "A",begin = 0.2,end = 1)+
  xlab(firm_name) +
  ylab(val_name) +
  ggtitle(val_name) +
  scale_x_continuous(breaks = c(25,50,75,100,125,150))+
  theme(text = element_text(size=8),
        plot.title = element_text(size=10),
        axis.title = element_text(size = 8),
        axis.text = element_text(size=6),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black")) +
  geom_smooth(method = 'loess',
              se = F,
              size = 0.75)


#plot possible os code

exp2_poss_plot = ggplot(exp2_df,aes(x=exp2_df$num_firms,
                                   y=exp2_df$round_prop_os_poss,
                                   color = exp2_df$market_shape)) +
  geom_point(size = 0.25,alpha = 0.25) + 
  scale_color_viridis_d(name = "Market",option = "A",begin = 0.2,end = 1)+
  xlab(firm_name) +
  ylab(poss_os_name) +
  ggtitle(poss_title) +
  scale_x_continuous(breaks = c(25,50,75,100,125,150))+
  theme(text = element_text(size=8),
        plot.title = element_text(size=10),
        axis.title = element_text(size = 8),
        axis.text = element_text(size=6),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        legend.position = "bottom") +
  geom_smooth(method = 'loess',
              se = F,
              size = 0.75)

#plot possible os code

exp2_firm_val_plot = ggplot(exp2_df,aes(x=exp2_df$num_firms,
                                       y=exp2_df$value_firm,
                                       color = exp2_df$market_shape)) +
  geom_point(size = 0.25,alpha = 0.25) + 
  scale_color_viridis_d(name = "Market",option = "A",begin = 0.2,end = 1)+
  xlab(firm_name) +
  ylab(val_firm_name) +
  ggtitle(val_firm_name) +
  scale_x_continuous(breaks = c(25,50,75,100,125,150))+
  theme(text = element_text(size=8),
        plot.title = element_text(size=10),
        axis.title = element_text(size = 8),
        axis.text = element_text(size=6),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black")) + 
  geom_smooth(method = 'loess',
              se = F,
              size = 0.75)

ledge = get_legend(exp2_firm_val_plot)

exp2_plot = grid.arrange(exp2_tot_plot + theme(legend.position="none"),
                        exp2_firm_val_plot+ theme(legend.position="none"),ledge,
                        exp2_poss_plot + theme(legend.position="none"),
                        ncol = 2)
ggsave("exp2_plot.png",exp2_plot, units = "cm",width = 12, height = 12)



