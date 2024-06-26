######### Stan program example  ###########

using Statistics
using StanSample
using Test

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

rc = stan_sample(sm, data=schools8data)

if success(rc)

    chns = read_samples(sm, :nesteddataframe)

    chns_eta = chns[:, :eta]
    
    df = read_summary(sm)
    @test df[df.parameters .== :mu, :mean][1] ≈ 7.64 rtol=0.5
    @test df[df.parameters .== :tau, :mean][1] ≈ 6.50 rtol=0.5
    @test df[df.parameters .== Symbol("theta[1]"), :mean][1] ≈ 11.1 rtol=0.5
    @test df[df.parameters .== Symbol("theta[8]"), :mean][1] ≈ 8.3 rtol=0.5
    @test df[df.parameters .== Symbol("eta[1]"), :mean][1] ≈ 0.4 rtol=0.5
    @test df[df.parameters .== Symbol("eta[8]"), :mean][1] ≈ 0.066 atol=0.5

end
