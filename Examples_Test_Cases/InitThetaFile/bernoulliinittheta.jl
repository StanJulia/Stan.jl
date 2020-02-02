######### Stan program example  ###########

using StanSample, MCMCChains

ProjDir = @__DIR__

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

datatheta = joinpath(ProjDir, "bernoulli.data.R")
inittheta = joinpath(ProjDir , "bernoulli.init.R")

sm = SampleModel("bernoulli", bernoullimodel);

rc = stan_sample(sm, data=datatheta, init=inittheta)

if success(rc)
  chn = read_samples(sm; output_format=:mcmcchains)
  show(chn)
end
