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

bernoullidata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

inittheta = [
  Dict("theta" => 0.6), Dict("theta" => 0.4), 
  Dict("theta" => 0.2), Dict("theta" => 0.1)]

sm = SampleModel("init_dict_array", bernoullimodel,
  seed=StanSample.RandomSeed(seed=-1));

rc = stan_sample(sm, data=bernoullidata, init=inittheta)
  
if success(rc)
  samples = read_samples(sm)
  
  df = read_summary(sm)
  @test df[df.parameters .== :theta, :mean][1] ≈ 0.33 rtol=0.2
  
end
