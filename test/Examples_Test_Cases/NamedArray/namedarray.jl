######### Stan program example  ###########

using StanSample, Test

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

sm = SampleModel("namedarray", bernoullimodel);

(sample_file, log_file) = stan_sample(sm, data=observeddata);

if !(sample_file == nothing)
  chn = read_samples(sm)
  describe(chn)

  sdf = read_summary(sm)
  @test sdf[:theta, :mean][1] ≈ 0.33 atol=0.2
  
end

