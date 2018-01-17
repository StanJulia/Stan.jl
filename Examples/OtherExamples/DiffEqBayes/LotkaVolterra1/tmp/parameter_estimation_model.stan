functions {
    real[] sho(real t,real[] internal_var___u,real[] theta,real[] x_r,int[] x_i) {
      real internal_var___du[2];
       # /Users/rob/.julia/v0.6/Stan/Examples/OtherExamples/DiffEqBayes/LotkaVolterra1/LotkaVolterra1.jl, line 18:;
internal_var___du[1] = theta[1] * internal_var___u[1] - 1.0 * internal_var___u[1] * internal_var___u[2];
 # /Users/rob/.julia/v0.6/Stan/Examples/OtherExamples/DiffEqBayes/LotkaVolterra1/LotkaVolterra1.jl, line 19:;
internal_var___du[2] = -3.0 * internal_var___u[2] + 1.0 * internal_var___u[1] * internal_var___u[2];

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
    real<lower=0.0,upper=2.0> theta1;
  }
  transformed parameters{
    real theta[1];
    theta[1] <- theta1;
  }
  model{
    real u_hat[T,2];
    sigma1 ~ inv_gamma(3.0, 2.0);
    theta[1] ~normal(1.5, 0.1) T[0.0,2.0];
    u_hat = integrate_ode_rk45(sho, u0, t0, ts, theta, x_r, x_i, 0.001, 1.0e-6, 100000);
    for (t in 1:T){
      internal_var___u[t,:] ~ normal(u_hat[t,:],sigma1);
      }
  }