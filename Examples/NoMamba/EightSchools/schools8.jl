######### Stan batch program example  ###########

using Compat, Stan, Base.Test

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

const eightschools ="
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

const schools8data = [
  Dict("J" => 8,
    "y" => [28,  8, -3,  7, -1,  1, 18, 12],
    "sigma" => [15, 10, 16, 11,  9, 11, 10, 18],
    "tau" => 25
  )
]

stanmodel = Stanmodel(name="schools8", model=eightschools, useMamba=false);
sim = stan(stanmodel, schools8data, ProjDir, CmdStanDir=CMDSTAN_HOME)

println("Mean of mu: $(mean(sim[:,8,:]))")
@test round(mean(sim[:,8,:]), 0) ≈ 8.0

end # cd
