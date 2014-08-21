######### Stan batch program example  ###########

using Stan
#using Distributions, MCMC, Gadfly

old = pwd()
path = @windows ? "\\Examples\\EightSchools" : "/Examples/EightSchools"
ProjDir = Pkg.dir("Stan")*path
cd(ProjDir)

eightschools ="
data {
  int<lower=0> J; // number of schools 
  real y[J]; // estimated treatment effects
  real<lower=0> sigma[J]; // s.e. of effect estimates 
}
parameters {
  real mu; 
  real<lower=0> tau;
  real eta[J];
}
transformed parameters {
  real theta[J];
  for (j in 1:J)
    theta[j] <- mu + tau * eta[j];
}
model {
  eta ~ normal(0, 1);
  y ~ normal(theta, sigma);
}
"

data = [
  [ "J" => 8,
    "y" => [28,  8, -3,  7, -1,  1, 18, 12],
    "sigma" => [15, 10, 16, 11,  9, 11, 10, 18],
    "tau" => 25
  ]
]

stanmodel = Stanmodel(name="schools8", model=eightschools);
chains = stan(stanmodel, data, ProjDir)

println()
chains[1]["samples"] |> display
println()

cd(old)
