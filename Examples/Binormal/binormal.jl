######### Stan program example  ###########

using Stan, Mamba

old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Binormal")
cd(ProjDir)

binorm = "
transformed data {
    matrix[2,2] Sigma;
    vector[2] mu;

    mu[1] <- 0.0;
    mu[2] <- 0.0;
    Sigma[1,1] <- 1.0;
    Sigma[2,2] <- 1.0;
    Sigma[1,2] <- 0.10;
    Sigma[2,1] <- 0.10;
}
parameters {
    vector[2] y;
}
model {
      y ~ multi_normal(mu,Sigma);
}
"
binormalmodel = Stanmodel(name="binormal", model=binorm);

sim1 = stan(binormalmodel)

## Subset Sampler Output
sim = sim1[1:1000, ["lp__", "y.1", "y.2"], :]
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
draw(p, ncol=4, filename="$(stanmodel.name)-summaryplot", fmt=:svg)
draw(p, ncol=4, filename="$(stanmodel.name)-summaryplot", fmt=:pdf)

# Below will only work on OSX, please adjust for your environment.
@osx ? for i in 1:4
  isfile("$(stanmodel.name)-summaryplot-$(i).svg") &&
    run(`open -a "Google Chrome.app" "$(stanmodel.name)-summaryplot-$(i).svg"`)
end : println()

cd(old)
