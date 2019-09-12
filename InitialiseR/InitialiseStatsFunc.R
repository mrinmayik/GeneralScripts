####################################################################################################################################
# This script will generate some functions to conduct simple stats like t-tests etc
# This script was written by Mrinmayi Kulkarni (mrinmayi@uwm.edu)
####################################################################################################################################



onesample_ttest <- function(dat, chance=0.5){
  #One sample t-test to check if mean is different from chance
  #http://www.sthda.com/english/wiki/one-sample-t-test-in-r
  #Check for normal distribution
  print("Test for normal distribution (These should NOT be significant)")
  ttest_list <- list()
  ttest_list$shapiro <- shapiro.test(dat) #These should NOT be significant
  #t-test
  ttest_list$ttest <- t.test(dat, mu = chance)
  return(ttest_list)
}

twosample_ttest <- function(grp1, grp2, paired=TRUE){
  print("Test for normal distribution (These should NOT be significant)")
  ttest_list <- list()
  ttest_list$shapiro1 <- shapiro.test(grp1) #These should NOT be significant
  ttest_list$shapiro2 <- shapiro.test(grp2) #These should NOT be significant
  #t-test
  ttest_list$ttest <- t.test(grp1, grp2, paired=paired)
  return(ttest_list)
}
  
  
  