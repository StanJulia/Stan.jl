######### Stan program example  ###########

using StanSample, MCMCChains
using StatsPlots

bernoullimodel = "
data { 
  int<lower=1> N; 
  int<lower=0,upper=1> y[N];
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

sm = SampleModel("bernoulli", bernoullimodel,
  tmpdir=tmpdir);

rc = stan_sample(sm, data=observed_data);

if success(rc)
  chns = read_samples(sm; output_format=:mcmcchains)
  
  # Describe the results
  chns
  
  # Optionally, read samples as a a DataFrame
  df=read_samples(sm, output_format=:dataframe)
  first(df, 5)
  println()
  
  # Look at effective sample saize
  ess(chns) |> display
  println()
  
  # Check if StatsPlots is available and show basic MCMCChains plots
  if isdefined(Main, :StatsPlots)
    cd(@__DIR__) do
      p1 = plot(chns)
      savefig(p1, joinpath(tmpdir, "traceplot.pdf"))
      p2 = pooleddensity(chns)
      savefig(p2, joinpath(tmpdir, "pooleddensity.pdf"))
    end
  end
  
  df = read_summary(sm)
  df[df.parameters .== :theta, [:mean, :ess]]
end

