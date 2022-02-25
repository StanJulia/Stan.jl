######### Stan batch program example  ###########

using StanSample, MCMCChains

ProjDir = @__DIR__

dyes ="
data {
  int BATCHES; 
  int SAMPLES; 
  real y[BATCHES, SAMPLES]; 
  //vector[SAMPLES] y[BATCHES]; 
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

dyesdata = Dict(:BATCHES => 6,
    :SAMPLES => 5,
    :y => [
      1545  1520  1630  1595  1510  1495;
      1540  1440  1455  1515  1465  1560;
      1595  1555  1440  1450  1635  1545;
      1445  1550  1490  1520  1480  1625;
      1595  1440  1605  1560  1580  1445;
    ]
  )

data = (BATCHES=6, SAMPLES=5, y=dyesdata[:y])
#data = joinpath(ProjDir, "dyes.json")

tmpdir = joinpath(@__DIR__, "tmp")
sm = SampleModel("dyes", dyes, tmpdir);
  
rc = stan_sample(sm; use_json=true, data)
#rc = stan_sample(sm; use_json=false, data)

if success(rc)
  chns = read_samples(sm, :mcmcchains; include_internals=true)
  
  chn = set_section(chns, 
    Dict(
      :parameters => ["theta", 
        "tau_between", "tau_within", 
        "sigma_between", "sigma_within",
        "sigmasq_between", "sigmasq_within"],
      :mu => ["mu.$i" for i in 1:6],
      :internals => names(chns, [:internals])
    )
  )
  show(chn)
  println()
  describe(chn, sections=[:mu]) |> display
  println()
  describe(chn, sections=[:internals]) |> display
end