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

}


model {
  vector[N_obs] mu;
  mu = beta_0 + beta_1[upc_id];
  Price_norm ~ normal(mu, sigma_e0);
  //priors
  sigma_e0  ~ exponential(1);
  beta_0 ~ normal(0, 1);
  beta_1 ~ normal(0, 1);
}

generated quantities {
  vector[N_obs] log_lik;
  vector[N_obs] y_pred;
  vector[N_obs] mu;
  for (n in 1:N_obs) mu[n] = beta_0 + beta_1[upc_id][n]; 
  for (n in 1:N_obs) log_lik[n] = normal_lpdf(Price_norm[n] | beta_0 + beta_1[upc_id][n] , sigma_e0);
  for (n in 1:N_obs) y_pred[n] = normal_rng(mu[n] , sigma_e0);
}
