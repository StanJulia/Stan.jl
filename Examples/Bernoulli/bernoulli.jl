######### Stan program example  ###########

using Mamba, Stan, Compat

old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Bernoulli")
cd(ProjDir)

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

bernoullidata = [
  @Compat.Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]),
  @Compat.Dict("N" => 10, "y" => [0, 1, 0, 0, 0, 0, 1, 0, 0, 1]),
  @Compat.Dict("N" => 10, "y" => [0, 0, 0, 0, 0, 0, 1, 0, 1, 1]),
  @Compat.Dict("N" => 10, "y" => [0, 0, 0, 1, 0, 0, 0, 1, 0, 1])
]

monitor = ["theta", "lp__", "accept_stat__"]

#stanmodel = Stanmodel(name="bernoulli", model=bernoullimodel, monitors=monitor);
stanmodel = Stanmodel(update=1200, thin=2, name="bernoulli", model=bernoullimodel);

println("\nStanmodel that will be used:")
stanmodel |> display
println("Input observed data dictionary:")
bernoullidata |> display
println()

sim1 = stan(stanmodel, bernoullidata, ProjDir, diagnostics=false, CmdStanDir=CMDSTAN_HOME);

## Subset Sampler Output to variables suitable for describe().
sim = sim1[:, monitor, :]
describe(sim)
println()

## Brooks, Gelman and Rubin Convergence Diagnostic
try
  gelmandiag(sim, mpsrf=true, transform=true) |> display
catch e
  #println(e)
  gelmandiag(sim, mpsrf=false, transform=true) |> display
end
println()

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
# JULIA_SVG_BROWSER is set from environment variable JULIA_SVG_BROWSER
@osx ? if isdefined(Main, :JULIA_SVG_BROWSER) && length(JULIA_SVG_BROWSER) > 0
        for i in 1:4
          isfile("$(stanmodel.name)-summaryplot-$(i).svg") &&
            run(`open -a $(JULIA_SVG_BROWSER) "$(stanmodel.name)-summaryplot-$(i).svg"`)
        end
      end : println()

cd(old)
