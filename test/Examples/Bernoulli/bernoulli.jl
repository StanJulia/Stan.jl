######### Stan program example  ###########

using StanSample, Test

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

observeddata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

sm = SampleModel("bernoulli", bernoullimodel,
  method=StanSample.Sample(save_warmup=true, num_warmup=1000, 
  num_samples=1000, thin=1));

(sample_file, log_file) = stan_sample(sm, data=observeddata);

if !(sample_file == nothing)
  
  # Create MCMCChains object
  chns = read_samples(sm);
  
  # Ceate a summary ChainDataFrame
  summary_df = read_summary(sm);
  @test summary_df[:theta, :mean][1] ≈ 0.34 atol=0.1

end

