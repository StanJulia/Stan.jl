######### Stan program example  ###########

using MCMCChains
using AxisKeys
using MonteCarloMeasurements
using StanSample
#using StatsPlots

bernoullimodel = "
data { 
  int<lower=1> N; 
  array[N] int<lower=0,upper=1> y;
} 
parameters {
  real<lower=0,upper=1> theta;
} 
model {
  theta ~ beta(1,1);
  y ~ bernoulli(theta);
}
";

observed_data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

# Default for tmpdir is to create a new tmpdir location
# To prevent recompilation of a Stan progam, choose a fixed location,
tmpdir=mktempdir()

sm = SampleModel("bernoulli", bernoullimodel, tmpdir);

rc = stan_sample(sm, data=observed_data);

if success(rc)
  chns = read_samples(sm, :mcmcchains)
  
  # Describe the results
  chns |> display
  
  # Optionally, read samples as a a DataFrame
  df=read_samples(sm, :dataframe)
  first(df, 5)
  
  df = read_summary(sm)
  df[df.parameters .== :theta, [:mean, :ess]]
end

