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
  real beta_1[N_upc];
  // Level-1 errors
  real<lower=0> sigma_e0;

}
generated quantities {

  vector[N_obs] log_lik;

  for (n in 1:N_obs) {

      real mu = beta_0 + beta_1[upc_id][n]; 

      log_lik[n] = normal_lpdf(Price_norm[n] | mu, sigma_e0);

  }

}
