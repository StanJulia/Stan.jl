######### Stan batch program example  ###########

using Compat, Stan, Mamba

old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "EightSchools")
cd(ProjDir)

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
  @Compat.Dict("J" => 8,
    "y" => [28,  8, -3,  7, -1,  1, 18, 12],
    "sigma" => [15, 10, 16, 11,  9, 11, 10, 18],
    "tau" => 25
  )
]

stanmodel = Stanmodel(name="schools8", model=eightschools);
sim1 = stan(stanmodel, schools8data, ProjDir, CmdStanDir=CMDSTAN_HOME)

nodesubset = ["lp__", "accept_stat__", "mu", "tau", "theta.1", "theta.2", "theta.3", "theta.4", "theta.5", "theta.6", "theta.7", "theta.8"]

## Subset Sampler Output
sim = sim1[1:size(sim1, 1), nodesubset, 1:size(sim1, 3)]

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
draw(p, nrow=4, ncol=4, filename="$(stanmodel.name)-summaryplot", fmt=:svg)
draw(p, nrow=4, ncol=4, filename="$(stanmodel.name)-summaryplot", fmt=:pdf)

# Below will only work on OSX, please adjust for your environment.
# JULIA_SVG_BROWSER is set from environment variable JULIA_SVG_BROWSER
@osx ? if isdefined(Main, :JULIA_SVG_BROWSER) && length(JULIA_SVG_BROWSER) > 0
        for i in 1:4
          isfile("$(stanmodel.name)-summaryplot-$(i).svg") &&
            run(`open -a $(JULIA_SVG_BROWSER) "$(stanmodel.name)-summaryplot-$(i).svg"`)
        end
      end : println()

cd(old)
