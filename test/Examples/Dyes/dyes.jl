######### Stan batch program example  ###########

using StanSample, Test
ProjDir = @__DIR__

dyes ="
data {
  int BATCHES; 
  int SAMPLES; 
  real y[BATCHES, SAMPLES]; 
  // vector[SAMPLES] y[BATCHES]; 
} 

parameters {
  real<lower=0> tau_between;
  real<lower=0> tau_within; 
  real theta;
  real mu[BATCHES]; 
} 

transformed parameters {
  real sigma_between; 
  real sigma_within;
  sigma_between <- 1/sqrt(tau_between); 
  sigma_within <- 1/sqrt(tau_within); 
} 

model {
  theta ~ normal(0.0, 1E5); 
  tau_between ~ gamma(.001, .001); 
  tau_within ~ gamma(.001, .001); 

  mu ~ normal(theta, sigma_between);
  for (n in 1:BATCHES)  
    y[n] ~ normal(mu[n], sigma_within);
}

generated quantities {
  real sigmasq_between;
  real sigmasq_within;

  sigmasq_between <- 1 / tau_between;
  sigmasq_within <- 1 / tau_within;
}
"

data = joinpath(ProjDir, "dyes.json")
sm = SampleModel("dyes", dyes);
rc = stan_sample(sm; data)

if success(rc)
  samples = read_samples(sm)

  # Fetch cmdstan summary data frame.
  df = read_summary(sm)
  @test df[df.parameters .== :theta, :mean][1] ≈ 1527.5 atol=50.0
  @test df[df.parameters .== Symbol("mu[1]"), :mean][1] ≈ 1512.5 rtol=0.1
  @test df[df.parameters .== Symbol("mu[2]"), :mean][1] ≈ 1528.1 rtol=0.1
  @test df[df.parameters .== Symbol("mu[3]"), :mean][1] ≈ 1553.8 rtol=0.1
  @test df[df.parameters .== Symbol("mu[4]"), :mean][1] ≈ 1507.2 rtol=0.1
  @test df[df.parameters .== Symbol("mu[5]"), :mean][1] ≈ 1578.7 rtol=0.1
  @test df[df.parameters .== Symbol("mu[6]"), :mean][1] ≈ 1487.3 rtol=0.1
  
end
