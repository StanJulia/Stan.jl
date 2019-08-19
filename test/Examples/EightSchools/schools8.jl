######### Stan program example  ###########

using StanSample, Test

eightschools ="
data {
  int<lower=0> J; // number of schools
  real y[J]; // estimated treatment effects
  real<lower=0> sigma[J]; // s.e. of effect estimates
}
parameters {
  real mu;
  real<lower=0> tau;
  real eta[J];
}
transformed parameters {
  real theta[J];
  for (j in 1:J)
    theta[j] <- mu + tau * eta[j];
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

(sample_file, log_file) = stan_sample(sm, data=schools8data)

if !(sample_file == nothing)
  chns = read_samples(sm)
  
  chn = set_section(chns, Dict(
    :parameters => ["mu", "tau"],
    :thetas => ["theta.$i" for i in 1:8],
    :etas => ["eta.$i" for i in 1:8],
    :internals => ["lp__", "accept_stat__", "stepsize__", "treedepth__", "n_leapfrog__",
      "divergent__", "energy__"]
    )
  )
  
  describe(chn)
  describe(chn, sections=[:thetas])
  
  # Ceate a ChainDataFrame
  summary_df = read_summary(sm)
  @test summary_df[:mu, :mean][1] ≈ 7.64 atol=10.0
  @test summary_df[:tau, :mean][1] ≈ 6.50 atol=10.0
  @test summary_df[Symbol("theta[1]"), :mean][1] ≈ 11.1 atol=16.0
  @test summary_df[Symbol("theta[8]"), :mean][1] ≈ 8.3 atol=16.0
  @test summary_df[Symbol("eta[1]"), :mean][1] ≈ 0.4 atol=2.0
  @test summary_df[Symbol("eta[8]"), :mean][1] ≈ 0.066 atol=2.0

end
