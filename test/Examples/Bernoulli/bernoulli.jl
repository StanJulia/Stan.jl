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
";

observeddata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

sm = SampleModel("bernoulli", bernoullimodel);

rc = stan_sample(sm, data=observeddata);

if success(rc)
  
  # Fetch cmdstan summary data frame
  df = read_summary(sm);
  @test df[df.parameters .== :theta, :mean][1] ≈ 0.34 rtol=0.1

end
