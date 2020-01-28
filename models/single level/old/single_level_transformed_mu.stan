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

transformed parameters{
  vector[N_obs] mu = beta_0 + beta_1[upc_id];
}

model {
  //priors
  sigma_e0  ~ exponential(1);
  beta_0 ~ std_normal();
  beta_1 ~ std_normal();
  
  Price_norm ~ normal(mu, sigma_e0);
}
