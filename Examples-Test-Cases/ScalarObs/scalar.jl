######### Stan program example  ###########

using StanSample, MCMCChains

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

sm = SampleModel("bernoulli", bernoullimodel);

rc = stan_sample(sm, data=bernoullidata);

if success(rc)
  chn = read_samples(sm, :mcmcchains)
  chn |> display
end
