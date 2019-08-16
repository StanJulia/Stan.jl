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

observeddata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

sm = SampleModel("bernoulli", bernoullimodel);

(sample_file, log_file) = stan_sample(sm, data=observeddata);

if !(sample_file == nothing)
  chn = read_samples(sm)
  describe(chn)
end
