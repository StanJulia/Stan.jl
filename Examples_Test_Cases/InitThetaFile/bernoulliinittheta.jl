######### Stan program example  ###########

using StanSample

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

datatheta = joinpath(@__DIR__, "bernoulli.data.R")
inittheta = joinpath(@__DIR__ , "bernoulli.init.R")[]
println([datatheta, inittheta])

sm = SampleModel("bernoulli", bernoullimodel);

(sample_file, log_file) = stan_sample(sm, data=datatheta, init=inittheta)

if !(sample_file == nothing)
  chn = read_samples(sm)
  describe(chn)
end
