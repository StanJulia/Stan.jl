######### StanSample program example  ###########

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

observeddata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

sm = SampleModel("bernoulli", bernoullimodel);

rc = stan_sample(sm, data=observeddata);

if success(rc)
  chn = read_samples(sm; output_format=:mcmcchains)
  show(chn)
end
