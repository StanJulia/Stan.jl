######### StanSample example  ###########

using StanSample, MCMCChains, Random

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

data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])
init = Dict("theta" => 0.60)

sm = SampleModel("bernoulli", bernoullimodel);

#rc = stan_sample(sm, false; data, init)
rc = stan_sample(sm; data, init)

if success(rc)
  chn = read_samples(sm, :mcmcchains)
  show(chn)
end
