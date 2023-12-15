######### Stan program example  ###########

using StanSample, MCMCChains

eightschools ="
data {
  int<lower=0> J; // number of schools
  array[J] real y; // estimated treatment effects
  array[J] real<lower=0> sigma; // s.e. of effect estimates
}
parameters {
  real mu;
  real<lower=0> tau;
  array[J] real eta;
}
transformed parameters {
  array[J] real theta;
  for (j in 1:J)
    theta[j] = mu + tau * eta[j];
}
model {
  eta ~ normal(0, 1);
  y ~ normal(theta, sigma);
}
"

schools8data = Dict("J" => 8,
  "y" => [28,  8, -3,  7, -1,  1, 18, 12],
  "sigma" => [15, 10, 16, 11,  9, 11, 10, 18],
  "tau" => 25
)

sm = SampleModel("schools8", eightschools)

rc = stan_sample(sm; data=schools8data)

if success(rc)
  chns = read_samples(sm, :mcmcchains)
end

if success(rc)
  ndf = read_samples(sm, :nesteddataframe)
end
