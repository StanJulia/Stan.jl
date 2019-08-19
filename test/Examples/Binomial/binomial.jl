using StanSample, Test

binom_model = "
// Inferring a Rate
data {
  int<lower=1> n;
  int<lower=0> k;
}
parameters {
  real<lower=0,upper=1> theta;
  real<lower=0,upper=1> thetaprior;
}
model {
  // Prior Distribution for Rate Theta
  theta ~ beta(1, 1);
  thetaprior ~ beta(1, 1);

  // Observed Counts
  k ~ binomial(n, theta);
}
generated quantities {
  int<lower=0> postpredk;
  int<lower=0> priorpredk;

  postpredk <- binomial_rng(n, theta);
  priorpredk <- binomial_rng(n, thetaprior);
}
"

sm = SampleModel("binomial", binom_model)

binom_data = Dict("n" => 10, "k" => 5)

(sample_file, log_file) = stan_sample(sm, data=binom_data)

if !(sample_file == nothing)
  chn = read_samples(sm)
  describe(chn)
  
  # Ceate a ChainDataFrame
  summary_df = read_summary(sm)
  @test summary_df[:theta, :mean][1] ≈ 0.24 atol=0.8
  
end
