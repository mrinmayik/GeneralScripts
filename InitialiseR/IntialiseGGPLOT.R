####################################################################################################################################
# This script initialises some common things like ggplot variables 
# Written by Mrinmayi Kulkarni (mrinmayi@uwmm.edu)
####################################################################################################################################

library(openxlsx)
library(plyr)
library(ggplot2)


#Set plotting variables
xaxistheme <- theme(axis.title.x = element_text(face="bold", size=20), axis.text.x = element_text(colour="#000000", size=18)) #, family="Times"
yaxistheme <- theme(axis.title.y = element_text(face="bold", size=20), axis.text.y = element_text(colour="#000000", size=14))
plottitletheme <- theme(plot.title = element_text(face="bold", size=20, hjust=0.5), legend.key.size=unit(1.3, "cm"))
legendtheme <- theme(legend.text=element_text(face="bold", size=10), legend.title=element_text(face="bold", size=16))
bgtheme <- theme(panel.background = element_rect(fill = "white", colour = "black", size = 1, linetype = "solid"),
                 panel.grid.major = element_line(size = 0.5, linetype = 'solid', colour = "#D6D6D6"), 
                 panel.grid.minor = element_line(size = 0.5, linetype = 'solid', colour = "#D6D6D6"))
stdbar <- geom_bar(stat="identity", position="dodge", color="#000000", size=1.5)
