# copied from 
# https://github.com/betanalpha/knitr_case_studies/blob/master/rstan_workflow/stan_utility.R
# modified to work with models fit using rstanarm 

# Tidybayes to extract model parameters and stuff
library(tidybayes) # Tested on tidybayes version 1.0.3
library(tidyverse)
library(rstanarm)

# Check transitions that ended with a divergence
check_div <- function(fit, quiet=FALSE) {
  sampler_params <- fit %>% tidy_draws()
  divergent <- sampler_params[['divergent__']]
  n = sum(divergent)
  N = length(divergent)
  
  if (!quiet) print(sprintf('%s of %s iterations ended with a divergence (%s%%)',
                            n, N, 100 * n / N))
  if (n > 0) {
    if (!quiet) print('  Try running with larger adapt_delta to remove the divergences')
    if (quiet) return(FALSE)
  } else {
    if (quiet) return(TRUE)
  }
}

# Check transitions that ended prematurely due to maximum tree depth limit
check_treedepth <- function(fit, max_depth = 15, quiet=FALSE) {
  sampler_params <- fit %>% tidy_draws()
  treedepths <- sampler_params[['treedepth__']]
  print(paste('Max treedepths reached is',max(treedepths)))
  n = length(treedepths[sapply(treedepths, function(x) x == max_depth)])
  N = length(treedepths)
  
  if (!quiet)
    print(sprintf('%s of %s iterations saturated the maximum tree depth of %s (%s%%)',
                  n, N, max_depth, 100 * n / N))
  
  if (n > 0) {
    if (!quiet) print('  Run again with max_treedepth set to a larger value to avoid saturation')
    if (quiet) return(FALSE)
  } else {
    if (quiet) return(TRUE)
  }
}

# Checks the energy fraction of missing information (E-FMI)
check_energy <- function(fit, quiet=FALSE) {
  sampler_params <- fit %>% tidy_draws()
  no_warning <- TRUE
  
  energies = sampler_params[['energy__']]
  numer = sum(diff(energies)**2) / length(energies)
  denom = var(energies)
  print(paste('Energy is ',numer / denom)) 
  if (numer / denom > 0.2) {
    if (!quiet) print('E-BFMI indicated no pathological behavior')
    if (quiet) return(TRUE)
  } else {
    if (!quiet) print('  E-BFMI below 0.2 indicates you may need to reparameterize your model')
    if (quiet) return(FALSE)
  }
}

# Checks the effective sample size per iteration
check_n_eff <- function(fit, quiet=FALSE) {
  fit_summary <- fit$stan_summary
  N <- dim(fit_summary)[[1]]
  
  iter <- prod(dim(fit$stanfit)[1:2])
  
  no_warning <- TRUE
  ratvals = c()
  for (n in 1:N) {
    ratio <- fit_summary[n,'n_eff'] / iter
    ratvals[n] = ratio
    if (ratio < 0.001) {
      if (!quiet) print(sprintf('n_eff / iter for parameter %s is %s!',
                                rownames(fit_summary)[n], ratio))
      no_warning <- FALSE
    }
  }
  print(paste('lowest n_eff is ',min(ratvals))) 
  if (no_warning) {
    if (!quiet) print('n_eff / iter looks reasonable for all parameters')
    if (quiet) return(TRUE)
  }
  else {
    if (!quiet) print('  n_eff / iter below 0.001 indicates that the effective sample size has likely been overestimated')
    if (quiet) return(FALSE)
  }
}

# Checks the potential scale reduction factors
check_rhat <- function(fit, quiet=FALSE) {
  fit_summary <- fit$stan_summary
  N <- dim(fit_summary)[[1]]
  
  ratvals = c()
  no_warning <- TRUE
  for (n in 1:N) {
    rhat <- fit_summary[n,'Rhat']
    ratvals[n] = rhat
    if (rhat > 1.1 || is.infinite(rhat) || is.nan(rhat)) {
      if (!quiet) print(sprintf('Rhat for parameter %s is %s!',
                                rownames(fit_summary)[n], rhat))
      no_warning <- FALSE
    }
  }
  print(paste('highest rhat is ',max(ratvals))) 
  if (no_warning) {
    if (!quiet) print('Rhat looks reasonable for all parameters')
    if (quiet) return(TRUE)
  } else {
    if (!quiet) print('  Rhat above 1.1 indicates that the chains very likely have not mixed')
    if (quiet) return(FALSE)
  }
}