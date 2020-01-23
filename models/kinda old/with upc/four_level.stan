 data {
   // Define variables in data
   // Number of level-1 observations (an integer)
   int<lower=0> N_obs;
   // level 1 categorial predictor
   int upc_id[N_obs];
   //Number of Level 1 categorial predictors
   int<lower=0> N_upc;
   // Continuous outcome
   real Price[N_obs];
   // Number of level-2 clusters
   int<lower=0> N_stores;
   // Number of level-3 clusters
   int<lower=0> N_banners;
   // Number of level-4 clusters
   int<lower=0> N_regions;
   // Cluster IDs (for all levels)
   int<lower=1> store_id[N_obs];
   int<lower=1> banner_id[N_obs];
   int<lower=1> region_id[N_obs];
   // Level 3 look up vector for level 2
   int<lower=1> banner_level_lookup[N_stores];
   // Level 4 look up vector for level 3
   int<lower=1> region_level_lookup[N_banners];
 }

parameters {
  // Population intercept
  real beta_0;

  // Population Slope- a different slope for each factor
  //vector[N_upc] beta_1;

  // Level-1 errors
  real<lower=0> sigma_e0;
  // Note that the subscripts changed between the two_level and 3 level model, not _j represents the 3rd level not the 2nd
  
  // Level-2 random effect
  vector[N_stores] u_0ijk;
  real<lower=0> sigma_u0ijk;

  // Level-3 random effect
  vector[N_banners] u_0jk;
  real<lower=0> sigma_u0jk;
  
  // Level-4 random effect
  vector[N_regions] u_0k;
  real<lower=0> sigma_u0k;
}

transformed parameters  {

  // Varying intercepts
  vector[N_stores] beta_0ijk;
  vector[N_banners] beta_0jk;
  vector[N_regions] beta_0k;

  // Level-2- start from the population and work your way down (inverse)!
  beta_0k = beta_0 + u_0k; //population -> regions

  // Level-3 //regions -> banners
  beta_0jk = beta_0k[region_level_lookup] + u_0jk;
  
  // Level-4 //banners -> stores
  beta_0ijk = beta_0jk[banner_level_lookup] + u_0ijk;

}

model {
  // Prior part of Bayesian inference

  // Random effects distribution
  u_0k  ~ normal(0, sigma_u0k);
  u_0jk ~ normal(0, sigma_u0jk);
  u_0ijk ~ normal(0, sigma_u0ijk);

  // Likelihood part of Bayesian inference
   Price ~ normal(beta_0ijk[store_id], sigma_e0);
}

generated quantities {
  vector[N_obs] log_lik;
  for (n in 1:N_obs) log_lik[n] = normal_lpdf(Price[n] | beta_0ijk[store_id][n], sigma_e0);
}
