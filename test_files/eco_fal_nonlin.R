########################################################################################################################################
# Ecological regression nonlinearities
#
# <some documentation>
########################################################################################################################################
# Set up workspace and load packages

rm(list=ls())

#Detach all  packages
detachAllPackages <- function() {
  basic.packages <- c("package:stats","package:graphics","package:grDevices","package:utils","package:datasets","package:methods","package:base")
  package.list <- search()[ifelse(unlist(gregexpr("package:",search()))==1,TRUE,FALSE)]
  package.list <- setdiff(package.list,basic.packages)
  if (length(package.list)>0)  for (package in package.list) detach(package, character.only=TRUE)
}
detachAllPackages()
library(tidyverse)
########################################################################################################################################
# 

# Sub territories and main territories
subter <- c(1:10)
mainter <- c(1:100)

n <- 1000 # number of people per main territory

# Define probabilities of subter for each main ter
probs <- matrix(   runif( length(mainter)*length(subter) ), nrow=length(mainter), ncol=length(subter), byrow=T   )
probs <- t(apply(probs,1,function(x) x/sum(x) ))

# Now define each person's exposure level
row <- 1
exp <- rep(NA,n*length(mainter))
sub <- exp[1:length(exp)]
main <- exp[1:length(exp)]
outcome <- exp[1:length(exp)]
for (m in mainter) { # loop over main territories
  for (i in 1:n) { # loop over sub territories
    
    main[row] <- m
    sub[row] <- sample(subter,size=1,prob=probs[m,])
    exp[row] <- (25+(5*sub[row]) + rnorm(1,mean=10,sd=7))/100
    outcome[row] <- 0.4 + (0.3*exp[row] + 0.1*exp[row]^2 + rnorm(1,mean=0,sd=0.1))
    row <- row+1 # increment row counter
  }
}

data <- as.data.frame(cbind(sub,main,exp,outcome))
########################################################################################################################################
# Plots of full data

# Plot of 
data %>%
  ggplot(aes(x=exp,y=outcome,group=sub,color=sub)) + geom_point() + theme_bw()


data %>%
  ggplot(aes(x=exp,y=outcome,group=main,color=main)) + geom_point() +  theme_bw() 

data %>%
  ggplot(aes(x=main,y=outcome,group=sub,color=sub)) + geom_point() +  theme_bw() 


data %>%
  group_by(main) %>%
  mutate(avg_outcome = mean(outcome)) %>%
  mutate(rank = rank(avg_outcome)) %>%
  arrange(avg_outcome) %>%
  ggplot(aes(x=main,y=avg_outcome)) + geom_point() +  theme_bw() 


data %>%
  group_by(main) %>%
  mutate(avg_outcome = mean(outcome)) %>%
  ungroup() %>%
  mutate(rank = dense_rank(avg_outcome)) %>%
  arrange(rank) %>%
  ggplot(aes(x=rank,y=outcome,color=sub)) + geom_point() +  theme_bw() 

# Make collapsed version of data (main)
data %>%
  group_by(main) %>%
  summarise(avg_exp = mean(exp),
            avg_outcome = mean(outcome)) %>%
  ggplot(aes(x=avg_exp,y=avg_outcome)) + geom_point() +  theme_bw() 

# make collapsed version by sub
data %>%
  group_by(sub) %>%
  summarise(avg_exp = mean(exp),
            avg_outcome = mean(outcome)) %>%
  ggplot(aes(x=avg_exp,y=avg_outcome)) + geom_point()  +  theme_bw()  # + geom_smooth(method='lm', formula = y ~ x + I(x^2))

# Revisit the subter version
data %>%
  ggplot(aes(x=exp,y=outcome,group=sub,color=sub)) + geom_point() +  theme_bw() 

####################################################################################################
# Regressions 

data %>%
  lm(outcome ~ exp + I(exp^2), data=.) %>%
  summary()

# make collapsed version by sub
data %>%
  group_by(sub) %>%
  summarise(avg_exp = mean(exp),
            avg_outcome = mean(outcome)) %>%
  lm(avg_outcome ~ avg_exp + I(avg_exp^2), data=.) %>%
  summary()

# make collapsed version by sub
data %>%
  group_by(main) %>%
  summarise(avg_exp = mean(exp),
            avg_outcome = mean(outcome)) %>%
  lm(avg_outcome ~ avg_exp + I(avg_exp^2), data=.) %>%
  summary()





