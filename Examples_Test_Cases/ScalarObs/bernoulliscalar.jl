######### Stan program example  ###########

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

bernoullidata = Dict("N" => 1, "y" => [0])

sm = SampleModel("bernoulli", bernoullimodel);

rc = stan_sample(sm, data=bernoullidata);

if success(rc)
  chn = read_samples(sm; output_format=:mcmcchains)
  show(chn)
end
