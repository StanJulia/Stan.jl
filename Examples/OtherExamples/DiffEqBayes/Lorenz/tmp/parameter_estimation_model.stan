functions {
    real[] sho(real t,real[] u,real[] theta,real[] x_r,int[] x_i) {
      real du[3];
          du[1] = 10.0 * (u[2] - u[1]);    du[2] = u[1] * (28.0 - u[3]) - u[2];    du[3] = u[1] * u[2] - theta[1] * u[3];
      return du;
      }
    }
  data {
    real u0[3];
    int<lower=1> T;
    real u[T,3];
    real t0;
    real ts[T];
  }
  transformed data {
    real x_r[0];
    int x_i[0];
  }
  parameters {
    vector<lower=0>[3] sigma;
    real theta[1];
  }
  model{
    real u_hat[T,3];
    sigma ~ inv_gamma(2, 3);
    theta[1] ~ normal(2.6666, 1.0) ; 
    u_hat = integrate_ode_rk45(sho, u0, t0, ts, theta, x_r, x_i);
    for (t in 1:T){
      u[t] ~ normal(u_hat[t], sigma);
      }
  }