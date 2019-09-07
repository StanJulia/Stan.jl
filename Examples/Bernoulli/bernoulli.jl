######### Stan program example  ###########

using StanSample
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
tmpdir=joinpath(@__DIR__, "tmp")

sm = SampleModel("bernoulli", bernoullimodel,
  method=StanSample.Sample(save_warmup=true, num_warmup=1000, 
  num_samples=1000, thin=1, adapt=StanSample.Adapt(delta=0.85)),
  tmpdir=tmpdir);

(sample_file, log_file) = stan_sample(sm, data=observed_data);

if !isnothing(sample_file)
  chns = read_samples(sm)
  
  # Describe the results
  println()
  show(chns)
  println()
  
  # Optionally, convert to a DataFrame
  DataFrame(chns, showall=true, sorted=true, append_chains=true) |> display
  println()
  
  # Look at effective sample saize
  ess(chns) |> display
  println()
  
  # Check if StatsPlots is available and show basic MCMCChains plots
  if isdefined(Main, :StatsPlots)
    cd(@__DIR__) do
      p1 = plot(chns)
      savefig(p1, "traceplot.pdf")
      p2 = pooleddensity(chns)
      savefig(p2, "pooleddensity.pdf")
    end
  end
  
  # Ceate a ChainDataFrame
  summary_df = read_summary(sm)
  summary_df[:theta, [:mean, :ess]]
end

