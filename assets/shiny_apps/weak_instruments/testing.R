library(mvtnorm)
library(ggplot2)

minN <- 50
maxN <- 1000

cor_x1_z <- 0.5
cor_x1_x2 <- -0.5
cor_x2_z <- 0.0

sigma <- matrix(c(1,cor_x1_x2,cor_x1_z,
                  cor_x1_x2,1,cor_x2_z,
                  cor_x1_z,cor_x2_z,1),ncol = 3)

beta_2s <- rep(NA,maxN-minN+1) 
beta    <- rep(NA,maxN-minN+1)

# Loop 
i <- 1
for (n in minN:maxN) {

  X <- rmvnorm(n,mean=c(0,0,0),sigma=sigma, method="eigen")
  x1 <- X[,1]
  x2 <- X[,2]
  z <-  X[,3]
  
  y <- 0.3*x1 - 0.7*x2 + rnorm(n) 
  xhat <- lm(x1 ~ z)$fitted.values
  
  beta[i] <- lm(y ~ x1)$coefficients[2]
  beta_2s[i] <- lm(y ~ xhat)$coefficients[2]
  i <- i+1

}

# Make dfs
df_raw <- data.frame(n=minN:maxN,beta=beta,Version=rep('Unadjusted',maxN-minN+1))
df_2s  <-  data.frame(n=minN:maxN,beta=beta_2s,Version=rep('Two-stage',maxN-minN+1))
df <- rbind(df_raw,df_2s)


# Plot

ggplot(df, aes(x=n,y=beta,color=Version)) + geom_line() + geom_hline(yintercept = 0.3)
# 
# plot(minN:maxN,beta,type = 'l',col='red',
#      ylim = c(  min(  min(beta),min(beta_2s)), max( max(beta),max(beta_2s)  )   ) )
# lines(minN:maxN,beta_2s,col='blue')
