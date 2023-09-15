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

observeddata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

sm = SampleModel("bernoulli", bernoullimodel);

rc = stan_sample(sm, data=observeddata);

if success(rc)
  chn = read_samples(sm, :mcmcchains)
  chn |> display
end
