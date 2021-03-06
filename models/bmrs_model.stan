// generated with brms 2.11.1
functions {
}
data {
  int<lower=1> N;  // number of observations
  vector[N] Y;  // response variable
  int<lower=1> K;  // number of population-level effects
  matrix[N, K] X;  // population-level design matrix
  // data for group-level effects of ID 1
  int<lower=1> N_1;  // number of grouping levels
  int<lower=1> M_1;  // number of coefficients per level
  int<lower=1> J_1[N];  // grouping indicator per observation
  // group-level predictor values
  vector[N] Z_1_1;
  // data for group-level effects of ID 2
  int<lower=1> N_2;  // number of grouping levels
  int<lower=1> M_2;  // number of coefficients per level
  int<lower=1> J_2[N];  // grouping indicator per observation
  // group-level predictor values
  vector[N] Z_2_1;
  int prior_only;  // should the likelihood be ignored?
}
transformed data {
}
parameters {
  vector[K] b;  // population-level effects
  real<lower=0> sigma;  // residual SD
  vector<lower=0>[M_1] sd_1;  // group-level standard deviations
  // standardized group-level effects
  vector[N_1] z_1[M_1];
  vector<lower=0>[M_2] sd_2;  // group-level standard deviations
  // standardized group-level effects
  vector[N_2] z_2[M_2];
}
transformed parameters {
  // actual group-level effects
  vector[N_1] r_1_1 = (sd_1[1] * (z_1[1]));
  // actual group-level effects
  vector[N_2] r_2_1 = (sd_2[1] * (z_2[1]));
}
model {
  // initialize linear predictor term
  vector[N] mu = X * b;
  for (n in 1:N) {
    // add more terms to the linear predictor
    mu[n] += r_1_1[J_1[n]] * Z_1_1[n] + r_2_1[J_2[n]] * Z_2_1[n];
  }
  // priors including all constants
  target += normal_lpdf(b | 0,1);
  target += exponential_lpdf(sigma | 1);
  target += exponential_lpdf(sd_1 | 1);
  target += normal_lpdf(z_1[1] | 0, 1);
  target += exponential_lpdf(sd_2 | 1);
  target += normal_lpdf(z_2[1] | 0, 1);
  // likelihood including all constants
  if (!prior_only) {
    target += normal_lpdf(Y | mu, sigma);
  }
}
generated quantities {
}
