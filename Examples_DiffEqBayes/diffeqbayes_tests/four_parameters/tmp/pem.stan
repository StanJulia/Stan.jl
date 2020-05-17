functions {
      int bin_search(real x, int min_val, int max_val){
    int range = (max_val - min_val + 1) / 2;
    int mid_pt = min_val + range;
    int out;
    while (range > 0) {
        if (x == mid_pt) {
            out = mid_pt;
            range = 0;
        } else {
            range = (range + 1) / 2; 
            mid_pt = x > mid_pt ? mid_pt + range: mid_pt - range; 
        }
    }
    return out;
}

    real[] sho(real t,real[] internal_var___u,real[] internal_var___p,real[] x_r,int[] x_i) {
  real internal_var___du[2];
  internal_var___du[1] = internal_var___u[1] * internal_var___p[1] - internal_var___u[1] * internal_var___u[2] * internal_var___p[2];
  internal_var___du[2] = -1 * internal_var___u[2] * internal_var___p[3] + internal_var___u[1] * internal_var___u[2] * internal_var___p[4];
  return internal_var___du;
}

  }
  data {
    real u0[2];
    int<lower=1> T;
    real internal_var___u[T,2];
    real t0;
    real ts[T];
  }
  transformed data {
    real x_r[0];
    int x_i[0];
  }
  parameters {
    row_vector<lower=0>[2] sigma1;
    real<lower=0.5,upper=2.5> theta1;real<lower=0.0,upper=2.0> theta2;real<lower=1.0,upper=4.0> theta3;real<lower=0.0,upper=2.0> theta4;
  }
  transformed parameters{
    real theta[4];
    theta[1] = theta1;theta[2] = theta2;theta[3] = theta3;theta[4] = theta4;
  }
  model{
    real u_hat[T,2];
    sigma1 ~ inv_gamma(3.0, 3.0);
    theta[1] ~normal(1.5, 0.5) T[0.5,2.5];theta[2] ~normal(1.2, 0.5) T[0.0,2.0];theta[3] ~normal(1.0, 0.5) T[1.0,4.0];theta[4] ~normal(1.0, 0.5) T[0.0,2.0];
    u_hat = integrate_ode_rk45(sho, u0, t0, ts, theta, x_r, x_i, 0.001, 1.0e-6, 100000);
    for (t in 1:T){
      internal_var___u[t,:] ~ normal(u_hat[t,1:2],sigma1);
      }
  }
  generated quantities{
    real u_hat[T,2];
    u_hat = integrate_ode_rk45(sho, u0, t0, ts, theta, x_r, x_i, 0.001, 1.0e-6, 100000);
  }