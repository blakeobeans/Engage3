 data {
   // Define variables in data
   // Number of level-1 observations (an integer)
   int<lower=0> N_obs;
   // Number of level-2 clusters
   int<lower=0> N_stores;

   // Cluster IDs (for all levels)
   int<lower=1> store_id[N_obs];
 
   // Continuous outcome
   real Price[N_obs];
   
   // Continuous predictor
   // real X_1ijk[Ni];
 }

parameters {
  // Population intercept
  real beta_0;

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
  // Prior part of Bayesian inference

  // Random effects distribution
  u_0j ~ normal(0, sigma_u0j);

  // Likelihood part of Bayesian inference
   Price ~ normal(beta_0j[store_id], sigma_e0);
}

generated quantities {
  vector[N_obs] log_lik;
  for (n in 1:N_obs) log_lik[n] = normal_lpdf(Price[n] | beta_0j[store_id][n], sigma_e0);
  //log_lik += normal_lpdf(Price | beta_0j[store_id], sigma_e0);
}
