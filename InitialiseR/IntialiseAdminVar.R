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



########################## Functions ##########################

#Get mean, median etc. Good for plotting. This function can be used in conjunction with ddply
#That way you can get the mean, median etc per group/condition. 
SummaryData <- function(df, UseVar, RMNA=FALSE){
  M=mean(df[,UseVar], na.rm=RMNA)
  SD <- sd(df[,UseVar], na.rm=RMNA)
  SE <- SD / sqrt(nrow(df))
  LCI <- M - 1.96*SE
  HCI <- M + 1.96*SE
  NumOfRows <- nrow(df)
  data.frame(Mean=M, SD=SD, SE=SE, LCI=LCI, HCI=HCI, Rows=NumOfRows)
}

#Make a simple function that makes sure that there are no NAs in a data frame. It'll be helpful to check if anything got
#screwed up with all the merging. If there are any NAs in any column, check merge will throw out a 
#message indicating which df contains NAs, along with a df with the row and column numbers where the NA belongs
CheckMerge <- function(df) {
  if(any(sapply(df, function(x) sum(is.na(x))))){
    print(sprintf("********************* %s has an na somewhere*********************", deparse(substitute(df))))
    which(is.na(df), arr.ind=TRUE)
  }
  else if(!(any(sapply(df, function(x) sum(is.na(x)))))){
    print(sprintf("%s looks good", deparse(substitute(df))))
  }
}


#Make a function that will explicitly halt execution is some of the trials are messed up. Pass the checked
#variables here in a list
CheckTrialNumbers <- function(Vars){
  if(!(all(Vars))){
    stop("Something is wrong in the Trial Numbers. INVESTIGATE!!!!")
  }
}