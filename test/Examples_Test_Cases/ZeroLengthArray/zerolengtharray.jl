using StanSample, MCMCChains, Test

bernoullimodel = "
data { 
  int<lower=1> N; 
  int<lower=0,upper=1> y[N];
  real empty[0];
} 
parameters {
  real<lower=0,upper=1> theta;
} 
model {
  theta ~ beta(1,1);
  y ~ bernoulli(theta);
}
"

observeddata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1],"empty"=>Float64[])

sm = SampleModel("zerolengtharray", bernoullimodel);

rc = stan_sample(sm, data=observeddata);

if success(rc)
  chn = read_samples(sm)
  describe(chn)

  df = read_summary(sm)
  @test df[df.parameters .== :theta, :mean][1] ≈ 0.33 atol=0.2
  
end
