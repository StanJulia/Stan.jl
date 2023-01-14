######## Stan diagnose example  ###########

using StanSample, Test

ProjDir = @__DIR__

gq = "
  data {
    int<lower=0> N;
    int<lower=0> y[N];
  }
  parameters {
    real<lower=0.00001> Theta;
  }
  model {
    Theta ~ gamma(4, 1000);
    for (n in 1:N)
      y[n] ~ exponential(Theta);
  }
  generated quantities{
    real y_pred;
    y_pred = exponential_rng(Theta);
  }
";

gq_data = Dict(
  "N" => 3,
  "y" => [100, 950, 450]
);

stanmodel = SampleModel("generate_quantities", gq);

rc = stan_sample(stanmodel; data=gq_data)

if success(rc)
  # Convert to an MCMCChains.Chains object
  samples = read_samples(stanmodel)
  
  # Show the same output in DataFrame format
  df = StanSample.read_summary(stanmodel)
  
  df1 = stan_generate_quantities(stanmodel, 1)
  @test sum(df1[!, :y_pred])/size(df1, 1) ≈ 412.0 rtol=0.3
end


