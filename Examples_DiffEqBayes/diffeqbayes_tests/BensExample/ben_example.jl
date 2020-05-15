# This script will usually fail as Stan gives up when the integration fails.

using StanSample, StatsPlots

ProjDir = @__DIR__

ben_model = "
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
";

sm = SampleModel("Ben", ben_model, tmpdir="$(@__DIR__)/tmp")

obs = reshape([
    2.75487369287842, 6.77861583902452, 0.977380864533721, 
    1.87996617432547,6.10484970865812, 1.38241825210688, 1.32745986436496, 
    4.35128045090906, 3.28082272129074, 1.02627964892546,
    0.252582832985904, 2.01848763447693, 1.91654508055532, 
    0.33796473710305, 0.621805831293324, 3.47392930294277, 0.512736737236118,
    0.304559407399392, 4.56901766791213, 0.91966250277948], (10,2))

ben_data = Dict(
  :N => 10,
  :t0 => 0,
  :ts => 1:10,
  :y => obs,
  :y_init => [1.01789244983237, 0.994539126829031]
)

t = ben_data[:ts]

plot(xlab="t", ylab="prey and pred")
plot!(t, obs[:,1], lab="prey")
plot!(t, obs[:, 2], lab="pred")
savefig("$(ProjDir)/observations.png")

rc = stan_sample(sm; data=ben_data)

if success(rc)
  p = read_samples(sm, output_format=:particles)
  display(p)
end



