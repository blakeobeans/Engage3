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

   // Cluster IDs (for all levels)
   int<lower=1> store_id[N_obs];
 
 }

parameters {
  // Population intercept
  real beta_0;

  // Population Slope- a different slope for each factor
  //vector[N_upc] beta_1;

  // Level-1 errors
  real<lower=0> sigma_e0;

  // Level-2 random effect
  vector[N_stores] u_0j;
  real<lower=0> sigma_u0j;

}

transformed parameters  {

  // Varying intercepts
  vector[N_stores] beta_0j;

  // Level-2
  beta_0j = beta_0 + u_0j;
}

model {
  
  //vector[N_obs] mu;
  //mu = beta_0j[store_id] + beta_1[upc_id];
 
  // Likelihood part of Bayesian inference
   Price ~ normal(beta_0j[store_id], sigma_e0);

  // Prior part of Bayesian inference

  // Random effects distribution
  u_0j ~ normal(0, sigma_u0j);

}

generated quantities {
  vector[N_obs] log_lik;
  for (n in 1:N_obs) log_lik[n] = normal_lpdf(Price[n] | beta_0j[store_id][n] , sigma_e0); //+ beta_1[upc_id]
}
