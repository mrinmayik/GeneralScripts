####################################################################################################################################
# This script initialises some common things like ggplot variables 
# Written by Mrinmayi Kulkarni (mrinmayi@uwmm.edu)
####################################################################################################################################

library(openxlsx)
library(plyr)
library(ggplot2)
library(ez)
library(tidyr)
library(dplyr)


#Set plotting variables
xaxistheme <- theme(axis.title.x = element_text(face="bold", size=25), axis.text.x = element_text(colour="#000000", size=20)) #, family="Times"
yaxistheme <- theme(axis.title.y = element_text(face="bold", size=25), axis.text.y = element_text(colour="#000000", size=22))
basebars <- scale_y_continuous(expand = c(0,0))
plottitletheme <- theme(plot.title = element_text(face="bold", size=20, hjust=0.5), legend.key.size=unit(1.3, "cm"))
legendtheme <- theme(legend.text=element_text(face="bold", size=18), legend.title=element_text(face="bold", size=20))
bgtheme <- theme(panel.background = element_rect(fill = "white", colour = "black", size = 1, linetype = "solid"),
                 panel.grid.major = element_line(size = 0.5, linetype = 'solid', colour = "#D6D6D6"), 
                 panel.grid.minor = element_line(size = 0.5, linetype = 'solid', colour = "#D6D6D6"))
stdbar <- geom_bar(stat="identity", position="dodge", color="#000000", size=1.5)
canvastheme <- theme(plot.margin = margin(1, 0.5, 0.5, 0.5, "cm"), plot.background = element_rect(fill = "white"))
blankbgtheme <- theme(panel.grid.major=element_blank(), panel.grid.minor=element_blank(),
                      panel.background=element_blank(), axis.line = element_line(colour = "black"))
subtitletheme <- theme(plot.subtitle=element_text(size=14, hjust=0.5, face="italic", color="black"))

posterxaxistheme <- theme(axis.title.x = element_text(face="bold", size=30, vjust=-4), axis.text.x = element_text(colour="#000000", size=28)) #, family="Times"
posteryaxistheme <- theme(axis.title.y = element_text(face="bold", size=30), axis.text.y = element_text(colour="#000000", size=24))
posterlegendtheme <- theme(legend.text=element_text(face="bold", size=25), legend.title=element_text(face="bold", size=30))

paperxaxistheme <- theme(axis.text.x = element_text(vjust = -1, size=28), 
                         axis.title.x = element_text(vjust = -2, size=30))
paperxaxistheme_tilt <- theme(axis.text.x = element_text(size=22, angle = 45, hjust = 1), 
                              axis.title.x = element_text(vjust = -2, size=30))
paperyaxistheme <- theme(axis.text.y = element_text(size=30), 
                         axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 10, l = 0),
                                                     size=35))
paperlegendtheme <- theme(legend.text=element_text(face="bold", size=30), legend.title=element_text(face="bold", size=35))
papertickstheme <- theme(axis.ticks.length = unit(.25, "cm"))
papercanvastheme <- theme(plot.margin = margin(1, 0.5, b=1.5, 0.5, "cm"), plot.background = element_rect(fill = "white"))

paperfacetxtheme <- theme(strip.text.x = element_text(size = 22, colour = "black"), 
                          strip.background = element_rect(color="white", fill="white", size=1.5, linetype="solid"),
                          panel.border = element_rect(colour = "black", fill = NA, size=1.5))

RmYGap <- scale_y_continuous(expand = c(0,0))



########################## Functions ##########################

#Get mean, median etc. Good for plotting. This function can be used in conjunction with ddply
#That way you can get the mean, median etc per group/condition. 
SummaryData <- function(df, UseVar, RMNA=FALSE){
  M=mean(df[,UseVar], na.rm=RMNA)
  SD <- sd(df[,UseVar], na.rm=RMNA)
  SE <- SD / sqrt(nrow(df))
  LCI <- M - 1.96*SE
  HCI <- M + 1.96*SE
  MeanPlusSE <- M+SE
  MeanMinusSE <- M-SE
  NumOfRows <- nrow(df)
  data.frame(Mean=M, SD=SD, SE=SE, LCI=LCI, HCI=HCI, MeanPlusSE=MeanPlusSE, MeanMinusSE, Rows=NumOfRows)
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


CheckRepBlock <- function(df, UseCol, OrderBy){
  #Order the rows before you start checking
  df <- df[order(df[, OrderBy]),]
  Rep <- MaxRepet <- 0
  for(i in 2:nrow(df)){
    if(df[i, UseCol]==df[(i-1), UseCol]){
      Rep <- Rep+1
    }else if(df[i, UseCol]!=df[(i-1), UseCol]){
      MaxRepet <- max(MaxRepet, Rep)
      Rep <- 0
    }
  }
  #Adding one because when the values are finally different after a block of being the same, the last trial is not counted
  #so value it returns is 1 less than the max repetitions
  return(MaxRepet+1) 
}


#This function will add a column to df with FDR corrected pvalues. Adding a function so it can be used with ddply
CorrectPVals <- function(df, pvalcol, usemethod="fdr"){
  #Is raw p-value significant?
  df[, "sig"] <- ifelse(df[, pvalcol]<=0.05, "*", "")
  #Do bonferroni for free
  df[, paste(pvalcol, "_BFcorrected", sep="")] <- p.adjust(df[, pvalcol], method="bonferroni")
  #Is BF corrected p significant?
  df[, paste("sig_BFcorrected", sep="")] <- ifelse(df[, paste(pvalcol, "_BFcorrected", sep="")]<=0.05, "*", "")
  
  #Correct p's based on method entered
  df[, paste(pvalcol, "_", usemethod, "corrected", sep="")] <- p.adjust(df[, pvalcol], method=usemethod)
  #Is corrected p significant?
  df[, paste("sig_", usemethod, "corrected", sep="")] <- ifelse(df[, paste(pvalcol, "_", usemethod, "corrected", sep="")]<=0.05, "*", "")
  return(df)
}
