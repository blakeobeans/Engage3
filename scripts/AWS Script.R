remove.packages("rstan")
remove.packages("StanHeaders")
install.packages("rstan", type = "source")
library(rstan)
library(StanHeaders)
rstan_options(auto_write = TRUE) #cache model
options(mc.cores = parallel::detectCores()) #multiple cores for multiple chains
load("~/brms_data.rda")
m1 <- stanc(file = "bmrs_model.stan")
m1 <- stan_model(stanc_ret = m1)
getOption("mc.cores", 1L)
fit1 <- sampling(m1, #use sampling function, rather than stan()
                 warmup=250, #
                 iter=1000, #total iterations including warmup
                 seed=1, #ensures reproducibility 
                 data=stan_data, 
                 chains = 4, #each chain has different initial condition which helps to find pathological neighborhood of posterior
                 cores = getOption("mc.cores", 1L),
                 verbose = FALSE,
                 refresh = 1)
