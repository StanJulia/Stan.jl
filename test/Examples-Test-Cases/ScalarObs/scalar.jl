######### Stan program example  ###########

using StanSample, Test

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
"

bernoullidata = Dict("N" => 1, "y" => [0])

sm = SampleModel("scalar", bernoullimodel);

rc = stan_sample(sm; data=bernoullidata);

if success(rc)
  samples = read_samples(sm)

  df = read_summary(sm)
  @test df[df.parameters .== :theta, :mean][1] ≈ 0.33 rtol=0.2
  
end
