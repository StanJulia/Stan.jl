functions {
  real[] dz_dt(real t,       // time
               real[] z,     // system state {prey, predator}
               real[] theta, // parameters
               real[] x_r,   // unused data
               int[] x_i) {
    real u = z[1];
    real v = z[2];
    
    real alpha = theta[1];
    real beta = theta[2];
    real gamma = theta[3];
    real delta = theta[4];
    
    real du_dt = (alpha - beta * v) * u;
    real dv_dt = (-gamma + delta * u) * v;
    
    return { du_dt, dv_dt };
  }
}

data {
  int<lower = 0> N;
  real t0;
  real ts[N];
  real y_init[2];
  real y[N, 2];
}

transformed data {
  real beta = 1.0;
  real gamma = 3.0;
  real delta = 1.0;
}

parameters {
  real alpha;
  real z_init[2];
  real<lower = 0> sigma[2];
}

transformed parameters {
  real theta[4] = { alpha, beta, gamma, delta };
  real z[N, 2]
  = integrate_ode_rk45(dz_dt, z_init, t0, ts, theta,
                       rep_array(0.0, 0), rep_array(0, 0),
                       1e-5, 1e-3, 500);
}

model {
  alpha ~ normal(1.5, 0.01);
  
  sigma ~ inv_gamma(3, 3);
  z_init ~ normal(1, 0.01);
  
  for (k in 1:2) {
    y_init[k] ~ normal(z_init[k], sigma[k]);
    y[ , k] ~ normal(z[, k], sigma[k]);
  }
}