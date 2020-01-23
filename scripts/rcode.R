library(rstan)
library(tidyverse)
library(here)

model_data <- read.csv("model_data.csv")
str(model_data)
colnames(model_data)
colnames(model_data) <- c("Price", "store_id", "UPC", "banner_id", "region_id")

## Create a vector of school IDs where j-th element gives school ID for class ID j
#schoolLookupVec <- unique(classroom[c("classid","schoolid")])[,"schoolid"]
#upper_level_lookup <- unique(d[c("lower_id", "upper_id")])[,"upper_id"]
banner_level_lookup <- unique(model_data[c("store_id", "banner_id")])[,"banner_id"]
region_level_lookup <- unique(model_data[c("banner_id", "region_id")])[,"region_id"]
region_level_lookup
as.numeric(region_level_lookup)
###get ready
#fileName <- "./two_level_model.stan"
#stan_code <- readChar(fileName, file.info(fileName)$size)
#cat(stan_code)

ret2 <- stanc(file = "stan_model_ver2.stan") # Check Stan file
ret_sm2 <- stan_model(stanc_ret = ret2) # Compile Stan code

fit <- sampling(ret_sm, warmup=100, iter=1000, seed=1, data=data, chains = 1)
fit2 <- sampling(ret_sm2, warmup=100, iter=1000, seed=1, data=data, chains = 1)

#resStan2 <- stan(model_code = stan_code, data = data, chains = 1, iter = 10000, warmup = 1000, thin = 10)


list_of_draws <- rstan::extract(fit2)
print(names(list_of_draws))
print(fit2, c("beta_0",  "u_0j"))
names(resStan2)

library(loo)
fit1 <- loo(fit)
log_lik_1 <- extract_log_lik(resStan, merge_chains = FALSE)
fit2 <- loo(fit2)
# Compare
comp <- loo_compare(fit1, fit2)
print(comp)

