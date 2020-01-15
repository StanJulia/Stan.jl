######### Stan program example  ###########

using StanSample, MCMCChains, Test

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

rc = stan_sample(sm, data=observeddata);

if success(rc)
  
  # Create MCMCChains object
  df = read_summary(sm);
  @test df[df.parameters .== :theta, :mean][1] ≈ 0.34 rtol=0.1

end

