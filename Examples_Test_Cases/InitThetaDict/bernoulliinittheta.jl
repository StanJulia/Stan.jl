######### StanSample example  ###########

using StanSample, MCMCChains

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
"

bernoullidata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])
inittheta = Dict("theta" => 0.60)

sm = SampleModel("bernoulli", bernoullimodel,
  seed=StanSample.RandomSeed(seed=-1));

rc = stan_sample(sm, data=bernoullidata, init=inittheta)

if success(rc)
  chn = read_samples(sm; output_format=:mcmcchains)
  show(chn)
end
  