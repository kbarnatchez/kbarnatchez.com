N <- 1e2
size<-0.9
var <- 0.3
E <- 5e3

library(ggplot2)

gen_ests <- function(N,size,var) {
  
  # Case 1: Potential outcomes
  tmt <- sample.int(2,N,replace=T)-1 # tmnt indicator
  y <- rnorm(N) # baseline
  y1 <- y + size + var*rnorm(N) # with treatment
  y0 <- y + var*rnorm(N) # without
  diff <- y1-y0
  
  po <- mean(diff)

  # Case 2:
  y_obs <- tmt*y1 + (1-tmt)*y0
  avg_t <- lm(y_obs ~ tmt)$coefficients[2]
  
  return(c(po,avg_t))
}


sim <- function(E,N,size,var) {
  
  est_data <- gen_ests(1,size,var)
  for (e in 2:E) {
    est_data <- rbind(est_data,gen_ests(e,size,var))
  }
  return(est_data)
}

ests <- sim(E,N,size,var)

po <- cbind(ests[,1],rep('Potential outcomes',E),as.numeric(1:E))
at <- cbind(ests[,2],rep('Average treatment effect',E),as.numeric(1:E))
at <- at[10:nrow(at),]
po <- po[10:nrow(po),]

plot_data <- data.frame(rbind(po,at),row.names = NULL)
colnames(plot_data) <- c('Estimate','Method','N')

plot_data$Estimate <- as.numeric(plot_data$Estimate)
plot_data$N <- as.numeric(plot_data$N)



ggplot(plot_data, aes(x=N,y=Estimate,group=Method,color=Method)) + geom_line(size=1) +
  geom_hline(yintercept = size) +
  labs(x='Sample Size',
       y='Estimate',
       title='Average treatment effects are unbiased but less efficient',
       subtitle='Results for treatment effect with strong signal') +
  theme_bw() +
  theme(plot.title = element_text(face = "bold"), legend.position = c(0.8, 0.2))