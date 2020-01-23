 data {
   // Define variables in data
   // Number of level-1 observations (an integer)
   int<lower=0> N_obs;
   // Number of level-2 clusters
   int<lower=0> N_stores;
   // Number of level-3 clusters
   int<lower=0> N_banners;
 
   // Cluster IDs (for all levels)
   int<lower=1> store_id[N_obs];
   int<lower=1> banner_id[N_obs];
 
   // Level 3 look up vector for level 2
   int<lower=1> banner_level_lookup[N_stores];
 
   // Continuous outcome
   real Price[N_obs];
   
   // Continuous predictor
   // real X_1ijk[Ni];
 }
 
 parameters {
   // Define parameters to estimate
   // Population intercept (a real number)
   real beta_0;
   // Population slope
   // real beta_1;
 
   // Level-1 errors
   real<lower=0> sigma_e0;
 
   // Level-2 random effect
   real u_0jk[N_stores];
   real<lower=0> sigma_u0jk;
 
   // Level-3 random effect
   real u_0k[N_banners];
   real<lower=0> sigma_u0k;
 }
 
 transformed parameters  {
   // Varying intercepts
   real beta_0jk[N_stores];
   real beta_0k[N_banners];
 
   // Individual mean
   real mu[N_obs];
 
   // Varying intercepts definition
   // Level-3 (10 level-3 random intercepts)
   for (k in 1:N_banners) {
     beta_0k[k] = beta_0 + u_0k[k];
   }
   // Level-2 (100 level-2 random intercepts)
   for (j in 1:N_stores) {
     beta_0jk[j] = beta_0k[banner_level_lookup[j]] + u_0jk[j];
   }
   // Individual mean
   for (i in 1:N_obs) {
     mu[i] = beta_0jk[store_id[i]];
   }
 }
 
 model {
   // Prior part of Bayesian inference
   // Flat prior for mu (no need to specify if non-informative)
 
   // Random effects distribution
   u_0k  ~ normal(0, sigma_u0k);
   u_0jk ~ normal(0, sigma_u0jk);
 
   // Likelihood part of Bayesian inference
   // Outcome model N(mu, sigma^2) (use SD rather than Var)
   for (i in 1:N_obs) {
     Price[i] ~ normal(mu[i], sigma_e0);
   }
 }
