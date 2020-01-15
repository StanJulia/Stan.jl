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

datatheta = joinpath(@__DIR__, "bernoulli.data.R")
inittheta = joinpath(@__DIR__ , "bernoulli.init.R")

sm = SampleModel("init_file", bernoullimodel);

rc = stan_sample(sm, data=datatheta, init=inittheta)

if success(rc)
  chn = read_samples(sm)
  describe(chn)

  df = read_summary(sm)
  @test df[df.parameters .== :theta, :mean][1] ≈ 0.33 rtol=0.2
  
end
