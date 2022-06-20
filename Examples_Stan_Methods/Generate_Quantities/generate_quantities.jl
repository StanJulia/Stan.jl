using StanSample

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

data = Dict(
  "N" => 3,
  "y" => [100, 950, 450]
);

stanmodel = SampleModel("Generate_quantities", gq);

rc = stan_sample(stanmodel; data,
  use_cpp_chains=true, check_num_chains=false,
  num_cpp_chains=2, num_julia_chains=2)

if success(rc)
  # Convert to an MCMCChains.Chains object
  chns = read_samples(stanmodel)

  # Show the same output in DataFrame format
  df = StanSample.read_summary(stanmodel)
  
  available_chains(stanmodel) |> display
  println()
  
  gq_df = stan_generate_quantities(stanmodel, 1, "2_3")
end


