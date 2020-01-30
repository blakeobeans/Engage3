 data {
   // Define variables in data
   // Number of level-1 observations (an integer)
   int<lower=0> N_obs;
   // level 1 categorial predictor
   int upc_id[N_obs];
   //Number of Level 1 categorial predictors
   int<lower=0> N_upc;
   // Continuous outcome
   vector[N_obs] Price;
   // Number of level-2 clusters
   int<lower=0> N_stores;
   // Number of level-3 clusters
   int<lower=0> N_banners;
   // Number of level-4 clusters
   int<lower=0> N_regions;
   // Interaction for banners & regions
   // Cluster IDs (for all levels)
   int<lower=1> store_id[N_obs];
   int<lower=1> banner_id[N_obs];
   int<lower=1> region_id[N_obs];
   // Level 3 look up vector for level 2
   int<lower=1> banner_level_lookup[N_stores];
   // Level 4 look up vector for level 3
   int<lower=1> region_level_lookup[N_stores];
 }
 
  transformed data{
    vector[N_obs] Price_norm;
    Price_norm = (Price-mean(Price))/sd(Price);
    
 }

parameters {
  // Population intercept
  real beta_0;

  // Population Slope- a different slope for each factor
  vector[N_upc] beta_1;

  // Level-1 errors
  real<lower=0> sigma_e0;
  // Note that the subscripts changed between the two_level and 3 level model, not _j represents the 3rd level not the 2nd
  
  // Level-2 random effect
  vector[N_stores] u_0jki;
  real<lower=0> sigma_u0jki;

  // Level-3 random effect
  vector[N_banners] u_0jk;
  real<lower=0> sigma_u0jk;
  
  // Level-4 random effect
  vector[N_regions] u_0j;
  real<lower=0> sigma_u0j;
}

transformed parameters  {

  // Varying intercepts
  vector[N_stores] beta_0jki;
  vector[N_banners] beta_0jk;
  vector[N_regions] beta_0j;

  // Level-4 //regions -> population
  beta_0j = beta_0 + u_0j * sigma_u0j;

  // Level-3- banners to regions
  beta_0jk = beta_0j[region_id] + u_0jk * sigma_u0jk; //population -> banners

  //Level 2- start from the bottom and work your way up... stores to banners
  beta_0jki = beta_0jk[banner_id] + u_0jki * sigma_u0jki;
}

model {
  vector[N_obs] mu = beta_0jki[store_id] + beta_1[upc_id];
  // Prior part of Bayesian inference
  beta_0 ~ std_normal();
  beta_1 ~ std_normal();
  // Random effects distribution
  u_0j  ~ normal(0,1);
  u_0jk ~ normal(0,1);
  u_0jki ~ normal(0,1);
  //priors on variance
  sigma_e0  ~ exponential(1);

  // Likelihood part of Bayesian inference
   Price_norm ~ normal(mu, sigma_e0);
}
