######### Stan batch program example  ###########

using Stan
#using Distributions, MCMC, Gadfly

old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "EightSchools")
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
sim1 = stan(stanmodel, data, ProjDir)

nodesubset = ["lp__", "accept_stat__", "mu", "tau", "theta.1", "theta.2", "theta.3", "theta.4", "theta.5", "theta.6", "theta.7", "theta.8"]

## Subset Sampler Output
sim = sim1[1:1000, nodesubset, :]
describe(sim)
println()


## Brooks, Gelman and Rubin Convergence Diagnostic
try
  gelmandiag(sim1, mpsrf=true, transform=true) |> display
catch e
  #println(e)
  gelmandiag(sim, mpsrf=false, transform=true) |> display
end

## Geweke Convergence Diagnostic
gewekediag(sim) |> display

## Highest Posterior Density Intervals
hpd(sim) |> display

## Cross-Correlations
cor(sim) |> display

## Lag-Autocorrelations
autocor(sim) |> display

## Deviance Information Criterion
#dic(sim) |> display


## Plotting

p = plot(sim, [:trace, :mean, :density, :autocor], legend=true);
draw(p, nrow=4, ncol=4, filename="mutauplot", fmt=:svg)
draw(p, nrow=4, ncol=4, filename="mutauplot", fmt=:pdf)

for i in 1:3
  isfile("mutauplot-$(i).svg") &&
    run(`open -a "Google Chrome.app" "mutauplot-$(i).svg"`)
end

cd(old)
